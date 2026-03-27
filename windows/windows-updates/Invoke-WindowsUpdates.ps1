#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Check for and install Windows updates using PSWindowsUpdate.

.NOTES
    Requires the PSWindowsUpdate module:
      Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers
    See README.md for usage examples.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Check','Install','InstallSecurityOnly','History')]
    [string]$Action,

    [Parameter()]
    [switch]$AutoReboot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

# Verify PSWindowsUpdate is available
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Status "PSWindowsUpdate module not found." 'ERROR'
    Write-Host "Install it with: Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers"
    exit 1
}
Import-Module PSWindowsUpdate -ErrorAction Stop

switch ($Action) {

    'Check' {
        Write-Status "Checking for available Windows updates..."
        $updates = Get-WindowsUpdate -MicrosoftUpdate -ErrorAction Stop
        if ($updates.Count -eq 0) {
            Write-Status "No updates available. System is up to date." 'SUCCESS'
        } else {
            Write-Status "$($updates.Count) update(s) available:" 'WARN'
            $updates | Select-Object KB, Size, Title | Format-Table -AutoSize -Wrap
        }
    }

    'Install' {
        Write-Status "Checking for and installing all available updates..." 'WARN'
        $installParams = @{
            MicrosoftUpdate = $true
            AcceptAll       = $true
            IgnoreReboot    = (-not $AutoReboot)
        }
        if ($AutoReboot) {
            $installParams['AutoReboot'] = $true
            Write-Status "AutoReboot is enabled — system will reboot automatically if required." 'WARN'
        }
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Install all Windows updates')) {
            Install-WindowsUpdate @installParams
            Write-Status "Update installation complete." 'SUCCESS'
            if (-not $AutoReboot) {
                $rebootRequired = (Get-WURebootStatus -Silent)
                if ($rebootRequired) {
                    Write-Status "A reboot is required to complete installation. Please schedule a reboot." 'WARN'
                }
            }
        }
    }

    'InstallSecurityOnly' {
        Write-Status "Installing security updates only..." 'WARN'
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Install security updates')) {
            Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Category 'Security Updates' `
                -IgnoreReboot:(-not $AutoReboot) -AutoReboot:$AutoReboot
            Write-Status "Security update installation complete." 'SUCCESS'
        }
    }

    'History' {
        Write-Status "Retrieving Windows Update history (last 50 entries)..."
        Get-WUHistory -MaxDate (Get-Date) -Last 50 |
            Select-Object Date, KB, Title, Result |
            Format-Table -AutoSize -Wrap
    }
}
