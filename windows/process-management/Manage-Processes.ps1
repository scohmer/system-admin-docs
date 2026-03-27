<#
.SYNOPSIS
    List, filter, find, and kill Windows processes.
.NOTES
    See README.md for usage examples.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Find','Details','Kill','HighCPU','HighMemory')]
    [string]$Action,

    [Parameter()] [string]$ProcessName,
    [Parameter()] [int]$PID,
    [Parameter()] [int]$TopN = 20,
    [Parameter()] [double]$CPUThreshold = 10,
    [Parameter()] [double]$MemoryMBThreshold = 200
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

function Format-Process {
    param($procs)
    $procs | Select-Object @{N='PID';E={$_.Id}}, Name,
        @{N='CPU(s)';E={[math]::Round($_.CPU, 1)}},
        @{N='Mem(MB)';E={[math]::Round($_.WorkingSet64 / 1MB, 1)}},
        @{N='Threads';E={$_.Threads.Count}},
        StartTime |
        Format-Table -AutoSize
}

switch ($Action) {

    'List' {
        Write-Status "Top $TopN processes by CPU:"
        Get-Process | Sort-Object CPU -Descending | Select-Object -First $TopN | ForEach-Object { $_ } |
            Select-Object @{N='PID';E={$_.Id}}, Name,
                @{N='CPU(s)';E={[math]::Round($_.CPU, 1)}},
                @{N='Mem(MB)';E={[math]::Round($_.WorkingSet64 / 1MB, 1)}},
                @{N='Handles';E={$_.HandleCount}} |
            Format-Table -AutoSize
    }

    'Find' {
        if (-not $ProcessName) { throw "-ProcessName required." }
        $procs = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if (-not $procs) { Write-Status "No process named '$ProcessName' found." 'WARN'; return }
        Write-Status "Found $($procs.Count) instance(s) of '$ProcessName':"
        Format-Process $procs
    }

    'Details' {
        if (-not $ProcessName) { throw "-ProcessName required." }
        $procs = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if (-not $procs) { Write-Status "No process named '$ProcessName' found." 'WARN'; return }
        foreach ($proc in $procs) {
            try {
                $wmi = Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.Id)" -ErrorAction SilentlyContinue
                [PSCustomObject]@{
                    Name        = $proc.Name
                    PID         = $proc.Id
                    'Path'      = $wmi.ExecutablePath ?? '(access denied)'
                    'Parent PID'= $wmi.ParentProcessId
                    'CPU (s)'   = [math]::Round($proc.CPU, 2)
                    'Mem (MB)'  = [math]::Round($proc.WorkingSet64 / 1MB, 1)
                    Handles     = $proc.HandleCount
                    Threads     = $proc.Threads.Count
                    'Start Time'= $proc.StartTime
                } | Format-List
            } catch {
                Write-Status "Could not get details for PID $($proc.Id): $_" 'WARN'
            }
        }
    }

    'Kill' {
        if (-not $ProcessName -and -not $PID) { throw "Either -ProcessName or -PID is required." }
        if ($PID) {
            $proc = Get-Process -Id $PID -ErrorAction SilentlyContinue
            if (-not $proc) { throw "Process with PID $PID not found." }
            if ($PSCmdlet.ShouldProcess("PID $PID ($($proc.Name))", 'Kill process')) {
                Stop-Process -Id $PID -Force
                Write-Status "Process $PID ($($proc.Name)) killed." 'SUCCESS'
            }
        } else {
            $procs = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
            if (-not $procs) { Write-Status "No process named '$ProcessName' found." 'WARN'; return }
            if ($PSCmdlet.ShouldProcess("$($procs.Count) instance(s) of '$ProcessName'", 'Kill all')) {
                $procs | Stop-Process -Force
                Write-Status "Killed $($procs.Count) instance(s) of '$ProcessName'." 'SUCCESS'
            }
        }
    }

    'HighCPU' {
        Write-Status "Processes with more than $CPUThreshold CPU seconds:"
        $procs = Get-Process | Where-Object { $_.CPU -gt $CPUThreshold } | Sort-Object CPU -Descending
        if (-not $procs) { Write-Status "No processes exceed CPU threshold of $CPUThreshold seconds." }
        else { Format-Process $procs }
    }

    'HighMemory' {
        Write-Status "Processes using more than $MemoryMBThreshold MB of memory:"
        $procs = Get-Process | Where-Object { ($_.WorkingSet64 / 1MB) -gt $MemoryMBThreshold } |
                 Sort-Object WorkingSet64 -Descending
        if (-not $procs) { Write-Status "No processes exceed memory threshold of $MemoryMBThreshold MB." }
        else { Format-Process $procs }
    }
}
