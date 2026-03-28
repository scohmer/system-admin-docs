# Disk Space Alerting

> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

## Overview

Checks all fixed drives on local or remote systems and issues WARN/ALERT entries when usage exceeds configured thresholds. Uses the shared `Write-Log` module to write alerts to a network share log and the Windows Application Event Log.

## Prerequisites

- PowerShell 5.1 or later
- `windows/shared/Write-Log.ps1` present in the repo
- WinRM enabled on remote targets (for `-ComputerName` usage)
- Write access to the network log share (if configured)

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `Action` | *(required)* | `Check` — scan and log; `Report` — scan, log, and print summary table |
| `ComputerName` | Local machine | One or more target computer names |
| `WarnPercent` | `80` | Usage % that triggers a WARN log entry |
| `AlertPercent` | `90` | Usage % that triggers an ALERT log entry |
| `LocalLogPath` | `C:\Logs\SysAdmin` | Local directory for log files |
| `NetworkLogPath` | *(empty)* | UNC path for network log copy |
| `AlertLogPath` | *(empty)* | UNC path for alert-only log (WARN + ALERT) |

## Usage

```powershell
# Check local drives with default thresholds
.\Get-DiskSpaceAlert.ps1 -Action Check

# Check multiple servers with custom thresholds and network logging
.\Get-DiskSpaceAlert.ps1 -Action Report `
    -ComputerName 'SERVER01','SERVER02','FILE01' `
    -WarnPercent 75 -AlertPercent 85 `
    -NetworkLogPath '\\logserver\SysAdminLogs\windows' `
    -AlertLogPath   '\\logserver\SysAdminLogs\windows\alerts'

# Dry run (no log files written — useful for testing thresholds)
.\Get-DiskSpaceAlert.ps1 -Action Check -WhatIf
```

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All drives within thresholds |
| `1` | One or more drives in WARN state |
| `2` | One or more drives in ALERT state |

## Alert Behavior

When a drive reaches the ALERT threshold:
- An **ALERT** entry is written to the console (magenta), local log, network log, and alert log
- A Windows **Application Event Log** entry is written (Source: `SysAdminScript`, Event ID: 9001)

## Scheduling

Schedule daily checks via Task Scheduler (see `windows/scheduled-tasks/`):

```powershell
.\Manage-ScheduledTasks.ps1 -Action Create `
    -TaskName 'DiskSpaceAlert' `
    -ScriptPath 'C:\Scripts\disk-space-alert\Get-DiskSpaceAlert.ps1' `
    -Arguments '-Action Report -AlertLogPath \\logserver\SysAdminLogs\windows\alerts' `
    -TriggerTime '06:00'
```
