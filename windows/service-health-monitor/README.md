# Service Health Monitor

> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

## Overview

Checks auto-start Windows services on local or remote hosts and issues ALERT entries for any that are not running. Optionally restarts stopped services. Uses the shared `Write-Log` module to write alerts to a network share log and the Windows Application Event Log.

## Prerequisites

- PowerShell 5.1 or later
- `windows/shared/Write-Log.ps1` present in the repo
- WinRM enabled on remote targets
- Write access to the network log share (if configured)

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `Action` | *(required)* | `Check` — report only; `AutoRestart` — check and restart; `List` — list all services |
| `ComputerName` | Local machine | One or more target computer names |
| `WatchServices` | *(empty — all auto-start)* | Specific service names to monitor |
| `LocalLogPath` | `C:\Logs\SysAdmin` | Local directory for log files |
| `NetworkLogPath` | *(empty)* | UNC path for network log copy |
| `AlertLogPath` | *(empty)* | UNC path for alert-only log |

## Usage

```powershell
# Check all auto-start services on the local machine
.\Get-ServiceHealth.ps1 -Action Check

# Monitor specific services across multiple servers with network logging
.\Get-ServiceHealth.ps1 -Action Check `
    -ComputerName 'WEB01','WEB02','DB01' `
    -WatchServices 'W3SVC','MSSQLSERVER','WinRM' `
    -NetworkLogPath '\\logserver\SysAdminLogs\windows' `
    -AlertLogPath   '\\logserver\SysAdminLogs\windows\alerts'

# Check and auto-restart any stopped services from the watch list
.\Get-ServiceHealth.ps1 -Action AutoRestart `
    -WatchServices 'Spooler','W3SVC','wuauserv' `
    -AlertLogPath   '\\logserver\SysAdminLogs\windows\alerts'

# List all services and their state
.\Get-ServiceHealth.ps1 -Action List
```

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All monitored services running |
| `1` | One or more services were down |

## Alert Behavior

When a service is found stopped:
- An **ALERT** entry is written to the console (magenta), local log, network log, and alert log
- A Windows **Application Event Log** entry is written (Source: `SysAdminScript`, Event ID: 9001)
- If `-Action AutoRestart`: a restart is attempted and the outcome is logged (SUCCESS or ERROR)

## Scheduling

Run every 15 minutes via Task Scheduler for near-real-time monitoring:

```powershell
.\Manage-ScheduledTasks.ps1 -Action Create `
    -TaskName 'ServiceHealthMonitor' `
    -ScriptPath 'C:\Scripts\service-health-monitor\Get-ServiceHealth.ps1' `
    -Arguments '-Action AutoRestart -WatchServices W3SVC,MSSQLSERVER -AlertLogPath \\logserver\SysAdminLogs\windows\alerts' `
    -RepeatInterval '00:15:00'
```
