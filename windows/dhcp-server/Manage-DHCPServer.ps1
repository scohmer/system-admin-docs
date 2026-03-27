#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Windows DHCP server scopes, leases, and reservations.
.NOTES
    Requires the DhcpServer module. See README.md for prerequisites.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('ListScopes','GetLeases','ListReservations','AddReservation','RemoveReservation','ActivateScope','DeactivateScope')]
    [string]$Action,

    [Parameter()] [string]$ScopeId,
    [Parameter()] [string]$IPAddress,
    [Parameter()] [string]$MACAddress,
    [Parameter()] [string]$ClientName = '',
    [Parameter()] [string]$ComputerName = $env:COMPUTERNAME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

if (-not (Get-Module -ListAvailable DhcpServer)) {
    throw "DhcpServer module not found. See README.md for installation instructions."
}
Import-Module DhcpServer -ErrorAction Stop

$s = @{ ComputerName = $ComputerName }

switch ($Action) {

    'ListScopes' {
        Write-Status "DHCP scopes on $ComputerName:"
        Get-DhcpServerv4Scope @s | Select-Object ScopeId, Name, State, StartRange, EndRange, SubnetMask |
            Format-Table -AutoSize
    }

    'GetLeases' {
        if (-not $ScopeId) { throw "-ScopeId required." }
        Write-Status "Active leases in scope $ScopeId:"
        Get-DhcpServerv4Lease @s -ScopeId $ScopeId |
            Select-Object IPAddress, ClientId, HostName, AddressState, LeaseExpiryTime |
            Format-Table -AutoSize
    }

    'ListReservations' {
        if (-not $ScopeId) { throw "-ScopeId required." }
        Write-Status "Reservations in scope $ScopeId:"
        Get-DhcpServerv4Reservation @s -ScopeId $ScopeId |
            Select-Object IPAddress, ClientId, Name, Description | Format-Table -AutoSize
    }

    'AddReservation' {
        if (-not $ScopeId)    { throw "-ScopeId required." }
        if (-not $IPAddress)  { throw "-IPAddress required." }
        if (-not $MACAddress) { throw "-MACAddress required." }
        # Normalize MAC to XX-XX-XX-XX-XX-XX
        $mac = $MACAddress -replace '[:\.\s]','' -replace '(..)(..)(..)(..)(..)(..)', '$1-$2-$3-$4-$5-$6'
        if ($PSCmdlet.ShouldProcess($IPAddress, "Add DHCP reservation for $mac")) {
            Add-DhcpServerv4Reservation @s -ScopeId $ScopeId -IPAddress $IPAddress `
                -ClientId $mac -Name $ClientName -ErrorAction Stop
            Write-Status "Reservation added: $IPAddress -> $mac ($ClientName)" 'SUCCESS'
        }
    }

    'RemoveReservation' {
        if (-not $ScopeId)   { throw "-ScopeId required." }
        if (-not $IPAddress) { throw "-IPAddress required." }
        if ($PSCmdlet.ShouldProcess($IPAddress, 'Remove DHCP reservation')) {
            Remove-DhcpServerv4Reservation @s -ScopeId $ScopeId -IPAddress $IPAddress -Force
            Write-Status "Reservation $IPAddress removed." 'SUCCESS'
        }
    }

    'ActivateScope' {
        if (-not $ScopeId) { throw "-ScopeId required." }
        if ($PSCmdlet.ShouldProcess($ScopeId, 'Activate DHCP scope')) {
            Set-DhcpServerv4Scope @s -ScopeId $ScopeId -State Active
            Write-Status "Scope $ScopeId activated." 'SUCCESS'
        }
    }

    'DeactivateScope' {
        if (-not $ScopeId) { throw "-ScopeId required." }
        if ($PSCmdlet.ShouldProcess($ScopeId, 'Deactivate DHCP scope')) {
            Set-DhcpServerv4Scope @s -ScopeId $ScopeId -State InActive
            Write-Status "Scope $ScopeId deactivated." 'WARN'
        }
    }
}
