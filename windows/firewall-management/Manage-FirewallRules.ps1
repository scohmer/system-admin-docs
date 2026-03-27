#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Windows Firewall rules: list, add, enable, disable, remove.

.NOTES
    See README.md for usage examples and full parameter documentation.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Show','Add','Enable','Disable','Remove')]
    [string]$Action,

    [Parameter()]
    [string]$RuleName,

    [Parameter()]
    [ValidateSet('Inbound','Outbound')]
    [string]$Direction = 'Inbound',

    [Parameter()]
    [ValidateSet('TCP','UDP','Any')]
    [string]$Protocol = 'Any',

    [Parameter()]
    [string]$LocalPort,

    [Parameter()]
    [string]$RemoteAddress,

    [Parameter()]
    [ValidateSet('Allow','Block')]
    [string]$RuleAction = 'Allow',

    [Parameter()]
    [ValidateSet('True','False','')]
    [string]$Enabled = ''
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
        Write-Status "Listing firewall rules..."
        $rules = Get-NetFirewallRule
        if ($Enabled -ne '') {
            $enabledBool = $Enabled -eq 'True'
            $rules = $rules | Where-Object { $_.Enabled -eq $enabledBool }
        }
        if ($Direction) {
            $rules = $rules | Where-Object { $_.Direction -eq $Direction }
        }
        $rules | Select-Object DisplayName, Direction, Action, Enabled, Profile |
            Sort-Object Direction, DisplayName | Format-Table -AutoSize
        Write-Status "Total: $($rules.Count) rule(s) shown."
    }

    'Show' {
        if (-not $RuleName) { throw "-RuleName is required." }
        $rule = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction Stop
        $rule | Format-List DisplayName, Description, Direction, Action, Enabled, Profile
        $portFilter    = $rule | Get-NetFirewallPortFilter
        $addressFilter = $rule | Get-NetFirewallAddressFilter
        Write-Host "`n  Protocol:      $($portFilter.Protocol)"
        Write-Host "  LocalPort:     $($portFilter.LocalPort)"
        Write-Host "  RemotePort:    $($portFilter.RemotePort)"
        Write-Host "  LocalAddress:  $($addressFilter.LocalAddress)"
        Write-Host "  RemoteAddress: $($addressFilter.RemoteAddress)"
    }

    'Add' {
        if (-not $RuleName) { throw "-RuleName is required." }

        # Check for duplicate
        if (Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue) {
            throw "A rule named '$RuleName' already exists. Use -Action Show to inspect it."
        }

        $params = @{
            DisplayName = $RuleName
            Direction   = $Direction
            Action      = $RuleAction
            Protocol    = $Protocol
            Enabled     = 'True'
        }
        if ($LocalPort)     { $params['LocalPort']     = $LocalPort }
        if ($RemoteAddress) { $params['RemoteAddress'] = $RemoteAddress }

        if ($PSCmdlet.ShouldProcess($RuleName, "Add firewall rule ($Direction/$RuleAction)")) {
            New-NetFirewallRule @params | Out-Null
            Write-Status "Rule '$RuleName' created ($Direction, $RuleAction)." 'SUCCESS'
        }
    }

    'Enable' {
        if (-not $RuleName) { throw "-RuleName is required." }
        if ($PSCmdlet.ShouldProcess($RuleName, 'Enable firewall rule')) {
            Enable-NetFirewallRule -DisplayName $RuleName
            Write-Status "Rule '$RuleName' enabled." 'SUCCESS'
        }
    }

    'Disable' {
        if (-not $RuleName) { throw "-RuleName is required." }
        if ($PSCmdlet.ShouldProcess($RuleName, 'Disable firewall rule')) {
            Disable-NetFirewallRule -DisplayName $RuleName
            Write-Status "Rule '$RuleName' disabled." 'SUCCESS'
        }
    }

    'Remove' {
        if (-not $RuleName) { throw "-RuleName is required." }
        Write-Status "Removing rule '$RuleName'..." 'WARN'
        if ($PSCmdlet.ShouldProcess($RuleName, 'Remove firewall rule')) {
            Remove-NetFirewallRule -DisplayName $RuleName
            Write-Status "Rule '$RuleName' removed." 'SUCCESS'
        }
    }
}
