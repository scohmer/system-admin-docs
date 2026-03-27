<#
.SYNOPSIS
    List, add, and remove stored credentials in Windows Credential Manager.
.NOTES
    See README.md for usage. Uses cmdkey.exe for add/remove operations.
    Does not require elevation — operates on the current user's credential store.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Add','Remove','RemoveAll')]
    [string]$Action,

    [Parameter()] [string]$Target,
    [Parameter()] [string]$UserName,
    [Parameter()] [ValidateSet('Windows','Generic')] [string]$Type = 'Generic',
    [Parameter()] [string]$PasswordPlain
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

switch ($Action) {

    'List' {
        Write-Status "Stored credentials (cmdkey /list):"
        $output = & cmdkey /list 2>&1
        if ($Type -eq 'Windows') {
            $output | Select-String -Pattern 'Windows|TERMSRV|MicrosoftOffice' -Context 0,3
        } elseif ($Type -eq 'Generic') {
            $output | Select-String -Pattern 'Generic' -Context 0,3
        } else {
            $output | ForEach-Object { Write-Host $_ }
        }
    }

    'Add' {
        if (-not $Target)   { throw "-Target required." }
        if (-not $UserName) { throw "-UserName required." }
        if ($PSCmdlet.ShouldProcess($Target, "Store credential for $UserName")) {
            if ($PasswordPlain) {
                & cmdkey /add:$Target /user:$UserName /pass:$PasswordPlain
            } else {
                $cred = Get-Credential -UserName $UserName -Message "Enter password to store for '$Target'"
                $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.Password)
                try {
                    $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
                    & cmdkey /add:$Target /user:$UserName /pass:$plain
                } finally {
                    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
                }
            }
            Write-Status "Credential stored for '$Target' as '$UserName'." 'SUCCESS'
        }
    }

    'Remove' {
        if (-not $Target) { throw "-Target required." }
        if ($PSCmdlet.ShouldProcess($Target, 'Remove credential')) {
            $result = & cmdkey /delete:$Target 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Status "Credential for '$Target' removed." 'SUCCESS'
            } else {
                Write-Status "Could not remove credential for '$Target'. It may not exist.`n$result" 'WARN'
            }
        }
    }

    'RemoveAll' {
        Write-Status "This will remove ALL stored credentials for the current user." 'WARN'
        if ($PSCmdlet.ShouldProcess('All stored credentials', 'Remove')) {
            $output = & cmdkey /list 2>&1
            $targets = $output | Select-String 'Target:\s+(.+)' | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() }
            if (-not $targets) {
                Write-Status "No credentials found to remove." 'WARN'
                return
            }
            foreach ($t in $targets) {
                & cmdkey /delete:$t 2>&1 | Out-Null
                Write-Host "  Removed: $t"
            }
            Write-Status "All credentials removed ($($targets.Count) total)." 'SUCCESS'
        }
    }
}
