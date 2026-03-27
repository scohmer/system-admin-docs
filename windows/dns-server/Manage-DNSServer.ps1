#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Windows DNS server zones and resource records.
.NOTES
    Requires the DnsServer module (DNS Server role or RSAT).
    See README.md for prerequisites and usage examples.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('ListZones','ListRecords','AddRecord','RemoveRecord','AddZone','RemoveZone')]
    [string]$Action,

    [Parameter()] [string]$ZoneName,
    [Parameter()] [string]$RecordName,
    [Parameter()] [ValidateSet('A','AAAA','CNAME','MX','PTR','TXT','NS')] [string]$RecordType = 'A',
    [Parameter()] [string]$RecordData,
    [Parameter()] [TimeSpan]$TTL = [TimeSpan]::FromHours(1),
    [Parameter()] [string]$ComputerName = $env:COMPUTERNAME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

if (-not (Get-Module -ListAvailable DnsServer)) {
    throw "DnsServer module not found. See README.md for installation instructions."
}
Import-Module DnsServer -ErrorAction Stop

$serverParam = @{ ComputerName = $ComputerName }

switch ($Action) {

    'ListZones' {
        Write-Status "Zones on $ComputerName:"
        Get-DnsServerZone @serverParam | Select-Object ZoneName, ZoneType, IsDsIntegrated, IsAutoCreated, DynamicUpdate |
            Format-Table -AutoSize
    }

    'ListRecords' {
        if (-not $ZoneName) { throw "-ZoneName required." }
        Write-Status "Records in zone '$ZoneName':"
        Get-DnsServerResourceRecord @serverParam -ZoneName $ZoneName |
            Select-Object HostName, RecordType, TimeToLive,
                @{N='RecordData';E={$_.RecordData.IPv4Address ?? $_.RecordData.HostNameAlias ?? $_.RecordData.DomainName ?? $_.RecordData.DescriptiveText ?? '(see raw)'}} |
            Sort-Object RecordType, HostName | Format-Table -AutoSize
    }

    'AddRecord' {
        if (-not $ZoneName)    { throw "-ZoneName required." }
        if (-not $RecordName)  { throw "-RecordName required." }
        if (-not $RecordData)  { throw "-RecordData required." }
        if ($PSCmdlet.ShouldProcess("$RecordName.$ZoneName", "Add $RecordType record -> $RecordData")) {
            $params = @{
                ZoneName = $ZoneName
                Name     = $RecordName
                TimeToLive = $TTL
            } + $serverParam
            switch ($RecordType) {
                'A'     { Add-DnsServerResourceRecordA     @params -IPv4Address $RecordData }
                'AAAA'  { Add-DnsServerResourceRecordAAAA  @params -IPv6Address $RecordData }
                'CNAME' { Add-DnsServerResourceRecordCName @params -HostNameAlias $RecordData }
                'TXT'   { Add-DnsServerResourceRecordTxt   @params -DescriptiveText $RecordData }
                'PTR'   { Add-DnsServerResourceRecordPtr   @params -PtrDomainName $RecordData }
                default { throw "RecordType '$RecordType' not yet supported by this script. Use the DNS console." }
            }
            Write-Status "Added $RecordType record: $RecordName.$ZoneName -> $RecordData" 'SUCCESS'
        }
    }

    'RemoveRecord' {
        if (-not $ZoneName)   { throw "-ZoneName required." }
        if (-not $RecordName) { throw "-RecordName required." }
        if ($PSCmdlet.ShouldProcess("$RecordName.$ZoneName", "Remove $RecordType record")) {
            Remove-DnsServerResourceRecord @serverParam -ZoneName $ZoneName `
                -Name $RecordName -RRType $RecordType -Force
            Write-Status "Removed $RecordType record: $RecordName.$ZoneName" 'SUCCESS'
        }
    }

    'AddZone' {
        if (-not $ZoneName) { throw "-ZoneName required." }
        if ($PSCmdlet.ShouldProcess($ZoneName, 'Add DNS zone')) {
            Add-DnsServerPrimaryZone @serverParam -Name $ZoneName -ReplicationScope Domain -ErrorAction Stop
            Write-Status "Zone '$ZoneName' created." 'SUCCESS'
        }
    }

    'RemoveZone' {
        if (-not $ZoneName) { throw "-ZoneName required." }
        Write-Status "Removing zone '$ZoneName'..." 'WARN'
        if ($PSCmdlet.ShouldProcess($ZoneName, 'Remove DNS zone')) {
            Remove-DnsServerZone @serverParam -Name $ZoneName -Force
            Write-Status "Zone '$ZoneName' removed." 'SUCCESS'
        }
    }
}
