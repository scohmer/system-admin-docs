#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Enable, disable, and configure Windows Remote Desktop (RDP).
.NOTES
    See README.md for usage examples and security notes.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Status','Enable','Disable','AllowUser','RemoveUser','ListUsers','SetPort')]
    [string]$Action,

    [Parameter()]
    [ValidateSet('Enabled','Disabled')]
    [string]$NLA = 'Enabled',

    [Parameter()]
    [string]$Username,

    [Parameter()]
    [ValidateRange(1, 65535)]
    [int]$Port = 3389
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

$tsRegPath  = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$nlaRegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
$portRegPath = $nlaRegPath

switch ($Action) {

    'Status' {
        $fDenyTS = Get-ItemPropertyValue $tsRegPath -Name fDenyTSConnections
        $nlaVal  = Get-ItemPropertyValue $nlaRegPath -Name UserAuthenticationRequired -ErrorAction SilentlyContinue
        $rdpPort = Get-ItemPropertyValue $portRegPath -Name PortNumber -ErrorAction SilentlyContinue
        Write-Host "`n  RDP Enabled:  $(if ($fDenyTS -eq 0) { 'Yes' } else { 'No' })"
        Write-Host "  NLA Required: $(if ($nlaVal -eq 1) { 'Yes (recommended)' } else { 'No' })"
        Write-Host "  RDP Port:     $rdpPort"
        Write-Host ""
    }

    'Enable' {
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Enable Remote Desktop')) {
            # Enable RDP
            Set-ItemProperty $tsRegPath -Name fDenyTSConnections -Value 0 -Type DWord
            # Configure NLA
            $nlaValue = if ($NLA -eq 'Enabled') { 1 } else { 0 }
            Set-ItemProperty $nlaRegPath -Name UserAuthenticationRequired -Value $nlaValue -Type DWord
            # Enable firewall rule
            Enable-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue
            # Start TermService if not running
            Set-Service -Name TermService -StartupType Automatic
            Start-Service -Name TermService -ErrorAction SilentlyContinue
            Write-Status "RDP enabled. NLA: $NLA. Firewall rule enabled." 'SUCCESS'
        }
    }

    'Disable' {
        Write-Status "Disabling RDP will disconnect all active remote sessions." 'WARN'
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Disable Remote Desktop')) {
            Set-ItemProperty $tsRegPath -Name fDenyTSConnections -Value 1 -Type DWord
            Disable-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue
            Write-Status "RDP disabled." 'SUCCESS'
        }
    }

    'AllowUser' {
        if (-not $Username) { throw "-Username required." }
        if ($PSCmdlet.ShouldProcess($Username, "Add to Remote Desktop Users")) {
            Add-LocalGroupMember -Group 'Remote Desktop Users' -Member $Username -ErrorAction Stop
            Write-Status "$Username added to 'Remote Desktop Users'." 'SUCCESS'
        }
    }

    'RemoveUser' {
        if (-not $Username) { throw "-Username required." }
        if ($PSCmdlet.ShouldProcess($Username, "Remove from Remote Desktop Users")) {
            Remove-LocalGroupMember -Group 'Remote Desktop Users' -Member $Username -ErrorAction Stop
            Write-Status "$Username removed from 'Remote Desktop Users'." 'SUCCESS'
        }
    }

    'ListUsers' {
        Write-Status "Members of 'Remote Desktop Users' on $env:COMPUTERNAME:"
        Get-LocalGroupMember -Group 'Remote Desktop Users' | Select-Object Name, ObjectClass, PrincipalSource | Format-Table -AutoSize
    }

    'SetPort' {
        Write-Status "Changing RDP port to $Port. Update firewall rules and clients before proceeding." 'WARN'
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set RDP port to $Port")) {
            Set-ItemProperty $portRegPath -Name PortNumber -Value $Port -Type DWord
            # Update firewall rule
            $rule = Get-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue |
                    Get-NetFirewallPortFilter
            if ($rule) {
                $rule | Set-NetFirewallPortFilter -LocalPort $Port
            }
            Write-Status "RDP port set to $Port. Restart the TermService to apply: Restart-Service TermService" 'SUCCESS'
        }
    }
}
