#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage SSL/TLS certificates in the Windows certificate store.
.NOTES
    See README.md for usage examples and notes on self-signed vs production certs.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','ListExpiring','CreateSelfSigned','ExportPFX','ExportCER','ImportPFX','Delete')]
    [string]$Action,

    [Parameter()] [string]$Thumbprint,
    [Parameter()] [string]$Subject,
    [Parameter()] [string[]]$SANs = @(),
    [Parameter()] [string]$ExportPath,
    [Parameter()] [int]$DaysWarning = 30,
    [Parameter()] [ValidateSet('LocalMachine','CurrentUser')] [string]$StoreLocation = 'LocalMachine',
    [Parameter()] [string]$StoreName = 'My'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

$storePath = "Cert:\$StoreLocation\$StoreName"

switch ($Action) {

    'List' {
        Write-Status "Certificates in $storePath:"
        Get-ChildItem $storePath | Select-Object @{N='Subject';E={$_.Subject}},
            @{N='Thumbprint';E={$_.Thumbprint}},
            @{N='Expiry';E={$_.NotAfter.ToString('yyyy-MM-dd')}},
            @{N='DaysLeft';E={([math]::Round(($_.NotAfter - (Get-Date)).TotalDays))}},
            @{N='Issuer';E={$_.Issuer}} |
            Sort-Object DaysLeft | Format-Table -AutoSize
    }

    'ListExpiring' {
        Write-Status "Certificates expiring within $DaysWarning days:"
        $cutoff = (Get-Date).AddDays($DaysWarning)
        $certs = Get-ChildItem $storePath | Where-Object { $_.NotAfter -lt $cutoff }
        if (-not $certs) {
            Write-Status "No certificates expiring within $DaysWarning days." 'SUCCESS'
        } else {
            $certs | Select-Object Subject, Thumbprint,
                @{N='Expiry';E={$_.NotAfter.ToString('yyyy-MM-dd')}},
                @{N='DaysLeft';E={[math]::Round(($_.NotAfter - (Get-Date)).TotalDays)}} |
                Sort-Object DaysLeft | Format-Table -AutoSize
        }
    }

    'CreateSelfSigned' {
        if (-not $Subject) { throw "-Subject required (e.g., CN=server.corp.local)." }
        $dnsNames = $SANs | Where-Object { $_ -notmatch '^\d' }
        $ipAddrs  = $SANs | Where-Object { $_ -match '^\d' }
        if ($PSCmdlet.ShouldProcess($Subject, 'Create self-signed certificate')) {
            $params = @{
                Subject           = $Subject
                CertStoreLocation = $storePath
                NotAfter          = (Get-Date).AddYears(2)
                KeyAlgorithm      = 'RSA'
                KeyLength         = 2048
                HashAlgorithm     = 'SHA256'
            }
            if ($dnsNames) { $params['DnsName'] = $dnsNames }
            $cert = New-SelfSignedCertificate @params
            Write-Status "Self-signed certificate created:" 'SUCCESS'
            Write-Host "  Subject:    $($cert.Subject)"
            Write-Host "  Thumbprint: $($cert.Thumbprint)"
            Write-Host "  Expiry:     $($cert.NotAfter.ToString('yyyy-MM-dd'))"
        }
    }

    'ExportPFX' {
        if (-not $Thumbprint) { throw "-Thumbprint required." }
        if (-not $ExportPath) { throw "-ExportPath required." }
        $cert = Get-Item "$storePath\$Thumbprint" -ErrorAction Stop
        $password = Read-Host "PFX password" -AsSecureString
        if ($PSCmdlet.ShouldProcess($Thumbprint, "Export PFX to $ExportPath")) {
            Export-PfxCertificate -Cert $cert -FilePath $ExportPath -Password $password | Out-Null
            Write-Status "Certificate exported to: $ExportPath" 'SUCCESS'
        }
    }

    'ExportCER' {
        if (-not $Thumbprint) { throw "-Thumbprint required." }
        if (-not $ExportPath) { throw "-ExportPath required." }
        $cert = Get-Item "$storePath\$Thumbprint" -ErrorAction Stop
        if ($PSCmdlet.ShouldProcess($Thumbprint, "Export CER to $ExportPath")) {
            Export-Certificate -Cert $cert -FilePath $ExportPath -Type CERT | Out-Null
            Write-Status "Certificate (public key only) exported to: $ExportPath" 'SUCCESS'
        }
    }

    'ImportPFX' {
        if (-not $ExportPath) { throw "-ExportPath required." }
        $password = Read-Host "PFX password" -AsSecureString
        if ($PSCmdlet.ShouldProcess($ExportPath, "Import PFX to $storePath")) {
            $cert = Import-PfxCertificate -FilePath $ExportPath -CertStoreLocation $storePath -Password $password
            Write-Status "Certificate imported: $($cert.Subject)" 'SUCCESS'
            Write-Host "  Thumbprint: $($cert.Thumbprint)"
        }
    }

    'Delete' {
        if (-not $Thumbprint) { throw "-Thumbprint required." }
        $cert = Get-Item "$storePath\$Thumbprint" -ErrorAction Stop
        Write-Status "Deleting: $($cert.Subject)" 'WARN'
        if ($PSCmdlet.ShouldProcess($cert.Subject, 'Delete certificate')) {
            Remove-Item "$storePath\$Thumbprint" -Force
            Write-Status "Certificate deleted." 'SUCCESS'
        }
    }
}
