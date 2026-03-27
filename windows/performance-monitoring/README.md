> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Performance Monitoring

Collect and report CPU, memory, disk, and network performance metrics. Optionally export to CSV for trending.

## Script

`Get-PerformanceMetrics.ps1`

## Usage

```powershell
# Show all metrics (CPU, memory, disk, network)
.\Get-PerformanceMetrics.ps1 -Action All

# Show CPU usage with 3 samples 5 seconds apart
.\Get-PerformanceMetrics.ps1 -Action CPU -SampleCount 3 -SampleInterval 5

# Show memory usage
.\Get-PerformanceMetrics.ps1 -Action Memory

# Show disk usage for all drives
.\Get-PerformanceMetrics.ps1 -Action Disk

# Show top 10 processes by CPU
.\Get-PerformanceMetrics.ps1 -Action Top -TopN 10

# Export all metrics to CSV
.\Get-PerformanceMetrics.ps1 -Action All -ExportCsv "C:\Reports\perf_$(Get-Date -f yyyyMMdd).csv"

# Query a remote machine
.\Get-PerformanceMetrics.ps1 -Action All -ComputerName "SERVER01"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `All`, `CPU`, `Memory`, `Disk`, `Network`, `Top` |
| `-SampleCount` | No | Number of counter samples to average (default: `3`) |
| `-SampleInterval` | No | Seconds between samples (default: `2`) |
| `-TopN` | No | Number of top processes to show (default: `10`) |
| `-ExportCsv` | No | Export results to this CSV path |
| `-ComputerName` | No | Remote computer name (default: local) |

## Notes

- CPU % is averaged across all samples to smooth out spikes.
- Network stats show bytes sent/received since the last counter reset (not a rate).
- Remote queries require WinRM to be enabled on the target: `Enable-PSRemoting -Force`.
