<#
.SYNOPSIS
    Collect and report Windows performance metrics: CPU, memory, disk, network, top processes.
.NOTES
    See README.md for usage and remote query requirements.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('All','CPU','Memory','Disk','Network','Top')]
    [string]$Action,

    [Parameter()] [int]$SampleCount = 3,
    [Parameter()] [int]$SampleInterval = 2,
    [Parameter()] [int]$TopN = 10,
    [Parameter()] [string]$ExportCsv,
    [Parameter()] [string]$ComputerName = $env:COMPUTERNAME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

function Get-FriendlySize {
    param([long]$Bytes)
    switch ($Bytes) {
        { $_ -ge 1GB } { return '{0:N1} GB' -f ($_ / 1GB) }
        { $_ -ge 1MB } { return '{0:N1} MB' -f ($_ / 1MB) }
        default        { return '{0:N1} KB' -f ($_ / 1KB) }
    }
}

$results = [System.Collections.Generic.List[PSObject]]::new()
$timestamp = Get-Date

function Get-CPUMetrics {
    Write-Status "Collecting CPU metrics ($SampleCount samples, ${SampleInterval}s interval)..."
    $counters = Get-Counter '\Processor(_Total)\% Processor Time' `
        -SampleInterval $SampleInterval -MaxSamples $SampleCount -ComputerName $ComputerName
    $avgCPU = ($counters.CounterSamples.CookedValue | Measure-Object -Average).Average
    $obj = [PSCustomObject]@{
        Metric    = 'CPU Usage %'
        Value     = [math]::Round($avgCPU, 1)
        Detail    = "Average of $SampleCount samples"
        Timestamp = $timestamp
    }
    Write-Host "`n  CPU Usage (avg): $($obj.Value)%"
    $results.Add($obj)
}

function Get-MemoryMetrics {
    Write-Status "Collecting memory metrics..."
    $os = Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName
    $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeGB  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedGB  = [math]::Round($totalGB - $freeGB, 2)
    $pctUsed = [math]::Round(($usedGB / $totalGB) * 100, 1)

    Write-Host "`n  Total RAM: ${totalGB} GB"
    Write-Host "  Used:      ${usedGB} GB ($pctUsed%)"
    Write-Host "  Free:      ${freeGB} GB"

    $results.Add([PSCustomObject]@{ Metric='Memory Total GB'; Value=$totalGB; Detail=''; Timestamp=$timestamp })
    $results.Add([PSCustomObject]@{ Metric='Memory Used GB';  Value=$usedGB;  Detail="$pctUsed% used"; Timestamp=$timestamp })
    $results.Add([PSCustomObject]@{ Metric='Memory Free GB';  Value=$freeGB;  Detail=''; Timestamp=$timestamp })
}

function Get-DiskMetrics {
    Write-Status "Collecting disk metrics..."
    $disks = Get-CimInstance Win32_LogicalDisk -ComputerName $ComputerName -Filter "DriveType=3"
    Write-Host ""
    foreach ($d in $disks) {
        $totalGB = [math]::Round($d.Size / 1GB, 1)
        $freeGB  = [math]::Round($d.FreeSpace / 1GB, 1)
        $usedPct = [math]::Round((($d.Size - $d.FreeSpace) / $d.Size) * 100, 1)
        $level   = if ($usedPct -ge 90) { 'ERROR' } elseif ($usedPct -ge 80) { 'WARN' } else { 'INFO' }
        Write-Status "  $($d.DeviceID) — ${usedPct}% used ($freeGB GB free of $totalGB GB)" $level
        $results.Add([PSCustomObject]@{ Metric="Disk $($d.DeviceID) Used%"; Value=$usedPct; Detail="$freeGB/$totalGB GB free"; Timestamp=$timestamp })
    }
}

function Get-NetworkMetrics {
    Write-Status "Collecting network metrics..."
    $adapters = Get-NetAdapterStatistics -ErrorAction SilentlyContinue
    Write-Host ""
    $adapters | ForEach-Object {
        Write-Host ("  {0,-30} Sent: {1,-12} Recv: {2}" -f $_.Name, (Get-FriendlySize $_.SentBytes), (Get-FriendlySize $_.ReceivedBytes))
        $results.Add([PSCustomObject]@{ Metric="NIC $($_.Name) Sent"; Value=$_.SentBytes; Detail='bytes'; Timestamp=$timestamp })
    }
}

function Get-TopProcesses {
    Write-Status "Top $TopN processes by CPU:"
    $procs = if ($ComputerName -eq $env:COMPUTERNAME) {
        Get-Process -ErrorAction SilentlyContinue
    } else {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-Process -ErrorAction SilentlyContinue }
    }
    $procs = $procs | Sort-Object CPU -Descending | Select-Object -First $TopN
    $procs | Select-Object @{N='Process';E={$_.Name}}, Id,
        @{N='CPU(s)';E={[math]::Round($_.CPU, 1)}},
        @{N='Memory MB';E={[math]::Round($_.WorkingSet64 / 1MB, 1)}} |
        Format-Table -AutoSize
}

switch ($Action) {
    'CPU'     { Get-CPUMetrics }
    'Memory'  { Get-MemoryMetrics }
    'Disk'    { Get-DiskMetrics }
    'Network' { Get-NetworkMetrics }
    'Top'     { Get-TopProcesses }
    'All' {
        Get-CPUMetrics
        Get-MemoryMetrics
        Get-DiskMetrics
        Get-NetworkMetrics
        Get-TopProcesses
    }
}

if ($ExportCsv -and $results.Count -gt 0) {
    $results | Export-Csv -Path $ExportCsv -NoTypeInformation -Encoding UTF8
    Write-Status "Metrics exported to: $ExportCsv" 'SUCCESS'
}
