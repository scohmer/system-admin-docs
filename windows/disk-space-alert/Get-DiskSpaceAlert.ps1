#Requires -Version 5.1
<#
.SYNOPSIS
    Monitor disk space on local or remote systems and alert when thresholds are exceeded.
.DESCRIPTION
    Checks all fixed drives and reports usage. Writes WARN when usage >= WarnPercent,
    ALERT when >= AlertPercent. ALERT entries are written to the network alert log and
    Windows Application Event Log via the shared Write-Log module.
.PARAMETER Action
    Check  — Report disk usage for all drives.
    Report — Same as Check with a formatted summary table.
.PARAMETER ComputerName
    One or more target computers. Defaults to the local machine.
.PARAMETER WarnPercent
    Usage percentage at which to issue a WARN. Default: 80.
.PARAMETER AlertPercent
    Usage percentage at which to issue an ALERT. Default: 90.
.PARAMETER LocalLogPath
    Local directory for log files.
.PARAMETER NetworkLogPath
    UNC path to write a full log copy to a network share.
.PARAMETER AlertLogPath
    UNC path to write alert-only entries (WARN and ALERT levels).
.NOTES
    See README.md for usage and scheduling examples.
    Requires the shared Write-Log module at ..\shared\Write-Log.ps1
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Check','Report')]
    [string]$Action,

    [Parameter()]
    [string[]]$ComputerName = @($env:COMPUTERNAME),

    [Parameter()]
    [ValidateRange(1,99)]
    [int]$WarnPercent = 80,

    [Parameter()]
    [ValidateRange(1,99)]
    [int]$AlertPercent = 90,

    [Parameter()]
    [string]$LocalLogPath   = "$env:SystemDrive\Logs\SysAdmin",

    [Parameter()]
    [string]$NetworkLogPath = '',

    [Parameter()]
    [string]$AlertLogPath   = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Get-DiskSpaceAlert' `
    -LocalLogPath   $LocalLogPath `
    -NetworkLogPath $NetworkLogPath `
    -AlertLogPath   $AlertLogPath

function Get-FriendlySize {
    param([long]$Bytes)
    if ($Bytes -ge 1TB) { return '{0:N1} TB' -f ($Bytes / 1TB) }
    if ($Bytes -ge 1GB) { return '{0:N1} GB' -f ($Bytes / 1GB) }
    return '{0:N1} MB' -f ($Bytes / 1MB)
}

$alertCount = 0
$warnCount  = 0
$results    = [System.Collections.Generic.List[PSObject]]::new()

foreach ($computer in $ComputerName) {
    Write-Log "Checking disk space on: $computer"
    try {
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk `
            -ComputerName $computer `
            -Filter 'DriveType=3' `
            -ErrorAction Stop

        foreach ($disk in $disks) {
            if (-not $disk.Size -or $disk.Size -eq 0) { continue }

            $usedPct  = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 1)
            $freeStr  = Get-FriendlySize $disk.FreeSpace
            $totalStr = Get-FriendlySize $disk.Size
            $msg      = "$computer $($disk.DeviceID) — ${usedPct}% used ($freeStr free of $totalStr)"

            $level = if ($usedPct -ge $AlertPercent) {
                $alertCount++
                'ALERT'
            } elseif ($usedPct -ge $WarnPercent) {
                $warnCount++
                'WARN'
            } else {
                'INFO'
            }

            Write-Log $msg $level

            $results.Add([PSCustomObject]@{
                Computer  = $computer
                Drive     = $disk.DeviceID
                UsedPct   = $usedPct
                FreeSpace = $freeStr
                TotalSize = $totalStr
                Level     = $level
            })
        }
    } catch {
        Write-Log "Failed to query disk info on ${computer}: $($_.Exception.Message)" 'ERROR'
    }
}

Write-Log "Scan complete — $($results.Count) drives checked, $warnCount warning(s), $alertCount alert(s)."

if ($Action -eq 'Report') {
    Write-Host "`n=== Disk Space Report ===" -ForegroundColor White
    $results | Sort-Object UsedPct -Descending | Format-Table -AutoSize
}

Close-Log -ExitCode $(if ($alertCount -gt 0) { 2 } elseif ($warnCount -gt 0) { 1 } else { 0 })
