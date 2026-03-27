#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Windows certificate stores.

.DESCRIPTION
    List, export (PFX or CER), import, delete, check expiry, and create
    self-signed certificates using the PowerShell Cert: provider.

.PARAMETER Action
    The operation to perform.

.PARAMETER StoreLocation
    Certificate store location: LocalMachine or CurrentUser.

.PARAMETER StoreName
    Certificate store name: My, Root, CA, TrustedPublisher, etc.

.PARAMETER Thumbprint
    Certificate thumbprint (hex string, no spaces).

.PARAMETER ExportPath
    File path for export output or import source (.pfx or .cer).

.PARAMETER Password
    Secure string password for PFX operations.

.PARAMETER DaysWarning
    Number of days ahead to warn about expiring certificates.

.PARAMETER SubjectName
    Subject name for self-signed certificate (e.g. CN=server.domain.com).

.EXAMPLE
    .\Manage-Certificates.ps1 -Action List -StoreLocation LocalMachine -StoreName My
    .\Manage-Certificates.ps1 -Action CheckExpiry -DaysWarning 60
    .\Manage-Certificates.ps1 -Action Request -SubjectName "CN=dev.local"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List', 'Export', 'Import', 'Delete', 'CheckExpiry', 'Request')]
    [string]$Action,

    [ValidateSet('LocalMachine', 'CurrentUser')]
    [string]$StoreLocation = 'LocalMachine',

    [string]$StoreName = 'My',
    [string]$Thumbprint,
    [string]$ExportPath,
    [System.Security.SecureString]$Password,
    [int]$DaysWarning = 30,
    [string]$SubjectName
)

$ErrorActionPreference = 'Stop'

# ─── Helper: coloured timestamped output ────────────────────────────────────
function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

function Assert-Param {
    param([string]$Value, [string]$ParamName)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Write-Status "-$ParamName is required for this action." 'ERROR'
        exit 1
    }
}

# ─── Build the certificate store path ────────────────────────────────────────
$storePath = "Cert:\$StoreLocation\$StoreName"

switch ($Action) {

    'List' {
        Write-Status "Listing certificates in '$storePath'..."
        $certs = Get-ChildItem -Path $storePath -ErrorAction Stop
        if ($certs.Count -eq 0) { Write-Status "No certificates found." 'WARN'; return }

        $certs | Select-Object @{N='Subject';E={$_.Subject}},
                               @{N='Thumbprint';E={$_.Thumbprint}},
                               @{N='Expiry';E={$_.NotAfter}},
                               @{N='Issuer';E={$_.Issuer}},
                               @{N='HasPrivateKey';E={$_.HasPrivateKey}} |
            Sort-Object Expiry |
            Format-Table -AutoSize -Wrap
        Write-Status "Total: $($certs.Count) certificate(s)." 'SUCCESS'
    }

    'CheckExpiry' {
        Write-Status "Checking for certificates expiring within $DaysWarning days in '$storePath'..."
        $warningDate = (Get-Date).AddDays($DaysWarning)
        $certs = Get-ChildItem -Path $storePath -ErrorAction Stop
        $expiring = $certs | Where-Object { $_.NotAfter -lt $warningDate }
        $expired  = $expiring | Where-Object { $_.NotAfter -lt (Get-Date) }
        $soonExp  = $expiring | Where-Object { $_.NotAfter -ge (Get-Date) }

        if ($expired.Count -gt 0) {
            Write-Status "$($expired.Count) EXPIRED certificate(s):" 'ERROR'
            $expired | Select-Object Subject, Thumbprint, NotAfter | Format-Table -AutoSize
        }
        if ($soonExp.Count -gt 0) {
            Write-Status "$($soonExp.Count) certificate(s) expiring within $DaysWarning days:" 'WARN'
            $soonExp | Select-Object Subject, Thumbprint, NotAfter | Format-Table -AutoSize
        }
        if ($expiring.Count -eq 0) {
            Write-Status "All certificates are valid beyond $DaysWarning days." 'SUCCESS'
        }
    }

    'Export' {
        Assert-Param $Thumbprint 'Thumbprint'
        Assert-Param $ExportPath 'ExportPath'

        $cert = Get-ChildItem -Path $storePath | Where-Object { $_.Thumbprint -eq $Thumbprint }
        if (-not $cert) { Write-Status "Certificate with thumbprint '$Thumbprint' not found." 'ERROR'; exit 1 }

        $exportDir = Split-Path $ExportPath -Parent
        if (-not (Test-Path $exportDir)) { New-Item -ItemType Directory -Path $exportDir -Force | Out-Null }

        if ($PSCmdlet.ShouldProcess($Thumbprint, "Export to $ExportPath")) {
            if ($ExportPath -match '\.pfx$') {
                # PFX export includes the private key; password is required
                if (-not $Password) {
                    Write-Status "PFX export requires -Password." 'ERROR'; exit 1
                }
                $certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $Password)
                [System.IO.File]::WriteAllBytes($ExportPath, $certBytes)
                Write-Status "PFX exported to '$ExportPath'." 'SUCCESS'
            }
            else {
                # CER export is public key only
                $certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
                [System.IO.File]::WriteAllBytes($ExportPath, $certBytes)
                Write-Status "CER exported to '$ExportPath'." 'SUCCESS'
            }
        }
    }

    'Import' {
        Assert-Param $ExportPath 'ExportPath'
        if (-not (Test-Path $ExportPath)) { Write-Status "File not found: $ExportPath" 'ERROR'; exit 1 }

        if ($PSCmdlet.ShouldProcess($ExportPath, "Import to $storePath")) {
            if ($ExportPath -match '\.pfx$') {
                if (-not $Password) {
                    $Password = Read-Host "Enter PFX password" -AsSecureString
                }
                Import-PfxCertificate -FilePath $ExportPath -CertStoreLocation $storePath -Password $Password
            }
            else {
                Import-Certificate -FilePath $ExportPath -CertStoreLocation $storePath
            }
            Write-Status "Certificate imported to '$storePath'." 'SUCCESS'
        }
    }

    'Delete' {
        Assert-Param $Thumbprint 'Thumbprint'
        $cert = Get-ChildItem -Path $storePath | Where-Object { $_.Thumbprint -eq $Thumbprint }
        if (-not $cert) { Write-Status "Certificate with thumbprint '$Thumbprint' not found." 'ERROR'; exit 1 }

        Write-Status "Found: $($cert.Subject)"
        if ($PSCmdlet.ShouldProcess($Thumbprint, 'Delete certificate')) {
            Remove-Item -Path "$storePath\$Thumbprint" -Force
            Write-Status "Certificate deleted." 'SUCCESS'
        }
    }

    'Request' {
        Assert-Param $SubjectName 'SubjectName'
        Write-Status "Creating self-signed certificate for '$SubjectName'..."
        if ($PSCmdlet.ShouldProcess($SubjectName, "Create self-signed certificate in $storePath")) {
            $cert = New-SelfSignedCertificate `
                -Subject $SubjectName `
                -CertStoreLocation $storePath `
                -KeyExportPolicy Exportable `
                -KeySpec Signature `
                -KeyLength 2048 `
                -KeyAlgorithm RSA `
                -HashAlgorithm SHA256 `
                -NotAfter (Get-Date).AddYears(2)

            Write-Status "Self-signed certificate created." 'SUCCESS'
            [PSCustomObject]@{
                Subject    = $cert.Subject
                Thumbprint = $cert.Thumbprint
                NotBefore  = $cert.NotBefore
                NotAfter   = $cert.NotAfter
                StorePath  = $storePath
            } | Format-List
        }
    }
}
