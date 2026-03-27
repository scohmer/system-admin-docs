#Requires -RunAsAdministrator
<#
.SYNOPSIS
    View and configure local security policy: password policy, account lockout, and user rights.
.NOTES
    See README.md for usage. Uses secedit.exe and net.exe for policy management.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Export','Import','GetPasswordPolicy','SetPasswordPolicy','GetLockoutPolicy','SetLockoutPolicy','GetUserRights')]
    [string]$Action,

    [Parameter()] [string]$ExportPath,
    [Parameter()] [string]$ImportPath,
    [Parameter()] [int]$MinPasswordLength = -1,
    [Parameter()] [int]$MaxPasswordAge    = -1,
    [Parameter()] [int]$PasswordComplexity = -1,
    [Parameter()] [int]$LockoutThreshold  = -1,
    [Parameter()] [int]$LockoutDuration   = -1,
    [Parameter()] [int]$LockoutWindow     = -1,
    [Parameter()] [string]$Right
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

switch ($Action) {

    'Export' {
        if (-not $ExportPath) { throw "-ExportPath required." }
        if ($PSCmdlet.ShouldProcess($ExportPath, 'Export security policy')) {
            secedit.exe /export /cfg $ExportPath /quiet
            Write-Status "Security policy exported to: $ExportPath" 'SUCCESS'
        }
    }

    'Import' {
        if (-not $ImportPath) { throw "-ImportPath required." }
        if (-not (Test-Path $ImportPath)) { throw "Import file not found: $ImportPath" }
        Write-Status "Importing security policy from $ImportPath. This will overwrite current settings." 'WARN'
        if ($PSCmdlet.ShouldProcess($ImportPath, 'Import security policy')) {
            $db = "$env:TEMP\secedit_import.sdb"
            secedit.exe /configure /db $db /cfg $ImportPath /quiet
            Remove-Item $db -ErrorAction SilentlyContinue
            Write-Status "Security policy imported." 'SUCCESS'
        }
    }

    'GetPasswordPolicy' {
        Write-Status "Password policy (net accounts):"
        net accounts
        Write-Host ""
        Write-Status "Detail from secedit:"
        $tmpCfg = "$env:TEMP\secpol_query.cfg"
        secedit.exe /export /cfg $tmpCfg /areas SECURITYPOLICY /quiet
        $content = Get-Content $tmpCfg
        $content | Where-Object { $_ -match 'Password|MinimumPasswordLength|MaximumPasswordAge|PasswordComplexity|PasswordHistorySize' } |
            ForEach-Object { Write-Host "  $_" }
        Remove-Item $tmpCfg -ErrorAction SilentlyContinue
    }

    'SetPasswordPolicy' {
        $cmds = @()
        if ($MinPasswordLength -ge 0) { $cmds += "net accounts /minpwlen:$MinPasswordLength" }
        if ($MaxPasswordAge -ge 0)    { $cmds += "net accounts /maxpwage:$(if ($MaxPasswordAge -eq 0) { 'unlimited' } else { $MaxPasswordAge })" }

        if ($cmds.Count -eq 0 -and $PasswordComplexity -lt 0) {
            throw "Specify at least one of: -MinPasswordLength, -MaxPasswordAge, -PasswordComplexity"
        }

        if ($PSCmdlet.ShouldProcess('Local password policy', 'Update')) {
            foreach ($cmd in $cmds) {
                Invoke-Expression $cmd
            }
            if ($PasswordComplexity -ge 0) {
                $tmpCfg = "$env:TEMP\secpol_complexity.cfg"
                $tmpDb  = "$env:TEMP\secpol_complexity.sdb"
                "[System Access]`r`nPasswordComplexity = $PasswordComplexity" | Set-Content $tmpCfg
                secedit.exe /configure /db $tmpDb /cfg $tmpCfg /areas SECURITYPOLICY /quiet
                Remove-Item $tmpCfg, $tmpDb -ErrorAction SilentlyContinue
                Write-Status "Password complexity set to $(if ($PasswordComplexity) { 'Enabled' } else { 'Disabled' })." 'SUCCESS'
            }
            Write-Status "Password policy updated." 'SUCCESS'
        }
    }

    'GetLockoutPolicy' {
        Write-Status "Account lockout policy:"
        net accounts | Select-String -Pattern 'lockout'
    }

    'SetLockoutPolicy' {
        $cmds = @()
        if ($LockoutThreshold -ge 0) { $cmds += "net accounts /lockoutthreshold:$LockoutThreshold" }
        if ($LockoutDuration -ge 0)  { $cmds += "net accounts /lockoutduration:$(if ($LockoutDuration -eq 0) { 'unlimited' } else { $LockoutDuration })" }
        if ($LockoutWindow -ge 0)    { $cmds += "net accounts /lockoutwindow:$LockoutWindow" }
        if ($cmds.Count -eq 0) { throw "Specify at least one lockout parameter." }
        if ($PSCmdlet.ShouldProcess('Account lockout policy', 'Update')) {
            foreach ($cmd in $cmds) { Invoke-Expression $cmd }
            Write-Status "Account lockout policy updated." 'SUCCESS'
        }
    }

    'GetUserRights' {
        if (-not $Right) { throw "-Right required (e.g., SeInteractiveLogonRight)." }
        $tmpCfg = "$env:TEMP\secpol_rights.cfg"
        secedit.exe /export /cfg $tmpCfg /areas USER_RIGHTS /quiet
        $content = Get-Content $tmpCfg
        $line = $content | Where-Object { $_ -match "^$Right\s*=" }
        Remove-Item $tmpCfg -ErrorAction SilentlyContinue
        if ($line) {
            Write-Host "  $line"
        } else {
            Write-Status "Right '$Right' not found or has no entries." 'WARN'
        }
    }
}
