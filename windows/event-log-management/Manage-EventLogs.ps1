#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Clear, resize, export, and manage Windows Event Logs.
.NOTES
    See README.md for usage. Always export before clearing.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','GetInfo','SetSize','Export','Clear','ClearAll','SetRetention')]
    [string]$Action,

    [Parameter()] [string]$LogName,
    [Parameter()] [long]$MaxSizeKB,
    [Parameter()] [string]$ExportPath,
    [Parameter()] [int]$RetentionDays,
    [Parameter()] [string]$ComputerName = $env:COMPUTERNAME
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
        Write-Status "Event logs on $ComputerName:"
        Get-WinEvent -ListLog * -ComputerName $ComputerName -ErrorAction SilentlyContinue |
            Where-Object { $_.RecordCount -gt 0 -or $_.LogName -in 'System','Application','Security' } |
            Select-Object LogName,
                @{N='MaxMB';E={[math]::Round($_.MaximumSizeInBytes / 1MB, 1)}},
                @{N='CurrentMB';E={[math]::Round($_.FileSize / 1MB, 1)}},
                RecordCount, IsEnabled, LogMode |
            Sort-Object CurrentMB -Descending | Format-Table -AutoSize
    }

    'GetInfo' {
        if (-not $LogName) { throw "-LogName required." }
        $log = Get-WinEvent -ListLog $LogName -ComputerName $ComputerName -ErrorAction Stop
        [PSCustomObject]@{
            'Log Name'      = $log.LogName
            'Log File'      = $log.LogFilePath
            'Max Size (MB)' = [math]::Round($log.MaximumSizeInBytes / 1MB, 1)
            'Current (MB)'  = [math]::Round($log.FileSize / 1MB, 1)
            'Record Count'  = $log.RecordCount
            'Log Mode'      = $log.LogMode
            'Enabled'       = $log.IsEnabled
        } | Format-List
    }

    'SetSize' {
        if (-not $LogName)   { throw "-LogName required." }
        if (-not $MaxSizeKB) { throw "-MaxSizeKB required." }
        if ($PSCmdlet.ShouldProcess($LogName, "Set max size to $MaxSizeKB KB")) {
            & wevtutil sl $LogName /ms:($MaxSizeKB * 1024) /r:$ComputerName
            Write-Status "Log '$LogName' max size set to $($MaxSizeKB/1024) MB." 'SUCCESS'
        }
    }

    'Export' {
        if (-not $LogName)    { throw "-LogName required." }
        if (-not $ExportPath) { throw "-ExportPath required." }
        $exportDir = Split-Path $ExportPath -Parent
        if ($exportDir -and -not (Test-Path $exportDir)) {
            New-Item -ItemType Directory -Path $exportDir -Force | Out-Null
        }
        if ($PSCmdlet.ShouldProcess($LogName, "Export to $ExportPath")) {
            & wevtutil epl $LogName $ExportPath /r:$ComputerName
            Write-Status "Log '$LogName' exported to: $ExportPath" 'SUCCESS'
        }
    }

    'Clear' {
        if (-not $LogName) { throw "-LogName required." }
        Write-Status "Clearing log '$LogName'. Export first with -Action Export." 'WARN'
        if ($PSCmdlet.ShouldProcess($LogName, 'Clear event log')) {
            Clear-WinEvent -LogName $LogName -ComputerName $ComputerName
            Write-Status "Log '$LogName' cleared." 'SUCCESS'
        }
    }

    'ClearAll' {
        foreach ($log in @('Application','System','Security')) {
            Write-Status "Clearing $log log..." 'WARN'
            if ($PSCmdlet.ShouldProcess($log, 'Clear event log')) {
                Clear-WinEvent -LogName $log -ComputerName $ComputerName -ErrorAction SilentlyContinue
                Write-Status "$log log cleared." 'SUCCESS'
            }
        }
    }

    'SetRetention' {
        if (-not $LogName) { throw "-LogName required." }
        if ($PSCmdlet.ShouldProcess($LogName, "Set retention to $RetentionDays days")) {
            $ms = if ($RetentionDays -gt 0) { $RetentionDays * 86400000 } else { 0 }
            & wevtutil sl $LogName /rt:false /r:$ComputerName  # Set overwrite-as-needed mode
            Write-Status "Retention policy updated for '$LogName'." 'SUCCESS'
        }
    }
}
