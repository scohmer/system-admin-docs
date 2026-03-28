<#
.SYNOPSIS
    Query Windows Event Logs with flexible filters and optional CSV export.

.NOTES
    Querying the Security log requires Administrator privileges.
    See README.md for usage examples, common Event IDs, and full parameter documentation.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$LogName,

    [Parameter()]
    [int]$Count = 100,

    [Parameter()]
    [ValidateSet('Information','Warning','Error','Critical')]
    [string[]]$Level,

    [Parameter()]
    [int]$EventId,

    [Parameter()]
    [string]$Source,

    [Parameter()]
    [int]$HoursBack,

    [Parameter()]
    [string]$ExportCsv,

    [Parameter()]
    [string]$ComputerName = $env:COMPUTERNAME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Get-EventLogEntries'

# Map level names to Get-WinEvent level values
$levelMap = @{
    'Information' = 4
    'Warning'     = 3
    'Error'       = 2
    'Critical'    = 1
}

Write-Status "Querying '$LogName' log on '$ComputerName'..."

# Build hash filter
$filter = @{ LogName = $LogName }

if ($HoursBack) {
    $filter['StartTime'] = (Get-Date).AddHours(-$HoursBack)
    Write-Status "Filtering: last $HoursBack hours"
}

if ($EventId) {
    $filter['Id'] = $EventId
    Write-Status "Filtering: Event ID $EventId"
}

if ($Level) {
    $filter['Level'] = $Level | ForEach-Object { $levelMap[$_] }
    Write-Status "Filtering: levels $($Level -join ', ')"
}

if ($Source) {
    $filter['ProviderName'] = $Source
    Write-Status "Filtering: source '$Source'"
}

try {
    $queryParams = @{
        FilterHashtable = $filter
        MaxEvents       = $Count
        ErrorAction     = 'Stop'
    }
    if ($ComputerName -ne $env:COMPUTERNAME) {
        $queryParams['ComputerName'] = $ComputerName
    }

    $events = Get-WinEvent @queryParams
} catch [System.Exception] {
    if ($_.Exception.Message -match 'No events were found') {
        Write-Status "No events matched the specified filters." 'WARN'
        exit 0
    }
    throw
}

# Format output
$results = $events | Select-Object @{N='TimeCreated';E={$_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')}},
    Id,
    @{N='Level';E={$_.LevelDisplayName}},
    ProviderName,
    @{N='Message';E={$_.Message -replace "`r`n",' ' | ForEach-Object { if ($_.Length -gt 120) { $_.Substring(0,120) + '...' } else { $_ } }}}

Write-Status "Found $($results.Count) event(s)."
$results | Format-Table -AutoSize -Wrap

if ($ExportCsv) {
    $exportDir = Split-Path $ExportCsv -Parent
    if ($exportDir -and -not (Test-Path $exportDir)) {
        New-Item -ItemType Directory -Path $exportDir -Force | Out-Null
    }
    # Export full messages without truncation
    $events | Select-Object @{N='TimeCreated';E={$_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')}},
        Id, LevelDisplayName, ProviderName, Message |
        Export-Csv -Path $ExportCsv -NoTypeInformation -Encoding UTF8
    Write-Status "Exported to: $ExportCsv" 'SUCCESS'
}
Close-Log
