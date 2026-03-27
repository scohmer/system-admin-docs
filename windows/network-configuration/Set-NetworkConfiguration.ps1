#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Configure Windows network adapters: static IP, DHCP, DNS settings.

.NOTES
    See README.md for usage examples and full parameter documentation.
    WARNING: Changing network settings on a remote session may disconnect you.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Show','SetStatic','SetDHCP','SetDNS')]
    [string]$Action,

    [Parameter()]
    [string]$AdapterName,

    [Parameter()]
    [string]$IPAddress,

    [Parameter()]
    [int]$PrefixLength = 24,

    [Parameter()]
    [string]$DefaultGateway,

    [Parameter()]
    [string[]]$DNSServers
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

function Get-Adapter {
    $adapter = Get-NetAdapter -Name $AdapterName -ErrorAction SilentlyContinue
    if (-not $adapter) {
        throw "Adapter '$AdapterName' not found. Use -Action List to see available adapters."
    }
    return $adapter
}

switch ($Action) {

    'List' {
        Write-Status "Network adapters on $env:COMPUTERNAME:"
        Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed |
            Format-Table -AutoSize
    }

    'Show' {
        if (-not $AdapterName) { throw "-AdapterName is required." }
        Get-Adapter | Out-Null
        Write-Status "Configuration for adapter '$AdapterName':"
        Write-Host "`n  --- IP Configuration ---"
        Get-NetIPAddress -InterfaceAlias $AdapterName -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Select-Object IPAddress, PrefixLength, PrefixOrigin | Format-List
        Write-Host "  --- Default Gateway ---"
        Get-NetRoute -InterfaceAlias $AdapterName -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
            Select-Object NextHop, RouteMetric | Format-List
        Write-Host "  --- DNS Servers ---"
        (Get-DnsClientServerAddress -InterfaceAlias $AdapterName -AddressFamily IPv4).ServerAddresses |
            ForEach-Object { Write-Host "  $_" }
    }

    'SetStatic' {
        if (-not $AdapterName) { throw "-AdapterName is required." }
        if (-not $IPAddress)   { throw "-IPAddress is required for SetStatic." }
        Get-Adapter | Out-Null

        if ($PSCmdlet.ShouldProcess($AdapterName, "Set static IP $IPAddress/$PrefixLength")) {
            Write-Status "Configuring static IP on '$AdapterName'..." 'WARN'

            # Remove existing IP and gateway
            Remove-NetIPAddress -InterfaceAlias $AdapterName -AddressFamily IPv4 `
                -Confirm:$false -ErrorAction SilentlyContinue
            Remove-NetRoute -InterfaceAlias $AdapterName -DestinationPrefix '0.0.0.0/0' `
                -Confirm:$false -ErrorAction SilentlyContinue

            # Set static IP
            $ipParams = @{
                InterfaceAlias = $AdapterName
                AddressFamily  = 'IPv4'
                IPAddress      = $IPAddress
                PrefixLength   = $PrefixLength
            }
            if ($DefaultGateway) { $ipParams['DefaultGateway'] = $DefaultGateway }
            New-NetIPAddress @ipParams | Out-Null

            # Set DNS if provided
            if ($DNSServers) {
                Set-DnsClientServerAddress -InterfaceAlias $AdapterName -ServerAddresses $DNSServers
                Write-Status "DNS set to: $($DNSServers -join ', ')" 'SUCCESS'
            }

            Write-Status "Static IP configured: $IPAddress/$PrefixLength$(if ($DefaultGateway) { " GW: $DefaultGateway" })" 'SUCCESS'
        }
    }

    'SetDHCP' {
        if (-not $AdapterName) { throw "-AdapterName is required." }
        Get-Adapter | Out-Null

        if ($PSCmdlet.ShouldProcess($AdapterName, 'Switch to DHCP')) {
            Write-Status "Switching '$AdapterName' to DHCP..." 'WARN'
            Set-NetIPInterface -InterfaceAlias $AdapterName -Dhcp Enabled
            Set-DnsClientServerAddress -InterfaceAlias $AdapterName -ResetServerAddresses
            # Remove any lingering static routes
            Remove-NetRoute -InterfaceAlias $AdapterName -DestinationPrefix '0.0.0.0/0' `
                -Confirm:$false -ErrorAction SilentlyContinue
            Write-Status "Adapter '$AdapterName' switched to DHCP." 'SUCCESS'
        }
    }

    'SetDNS' {
        if (-not $AdapterName) { throw "-AdapterName is required." }
        if (-not $DNSServers)  { throw "-DNSServers is required for SetDNS." }
        Get-Adapter | Out-Null

        if ($PSCmdlet.ShouldProcess($AdapterName, "Set DNS to $($DNSServers -join ', ')")) {
            Set-DnsClientServerAddress -InterfaceAlias $AdapterName -ServerAddresses $DNSServers
            Write-Status "DNS servers set to: $($DNSServers -join ', ')" 'SUCCESS'
        }
    }
}
