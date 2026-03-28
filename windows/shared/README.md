# Shared PowerShell Modules

> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

## Overview

The `windows/shared/` directory contains PowerShell modules that are dot-sourced by admin scripts to provide common functionality without duplicating code across every script.

---

## `Write-Log.ps1` — Centralized Logging Module

Replaces the inline `Write-Status` function found in every script with an enhanced version that writes to:

| Destination | Behavior |
|-------------|----------|
| **Console** | Always; color-coded by severity (unchanged from `Write-Status`) |
| **Local log file** | `C:\Logs\SysAdmin\<ScriptName>_<Host>_<Timestamp>.log` |
| **Network share log** | Optional UNC path — full copy of the local log |
| **Network share alert log** | Optional UNC path — ERROR and ALERT entries only |
| **Windows Application Event Log** | ERROR and ALERT entries; Source: `SysAdminScript`, Event ID: 9001 |

### Quick Start

**1. Dot-source the module** (add after the `param(...)` block):

```powershell
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'My-Script' `
    -LocalLogPath   'C:\Logs\SysAdmin' `
    -NetworkLogPath '\\logserver\logs\windows' `
    -AlertLogPath   '\\logserver\logs\windows\alerts'
```

**2. Use `Write-Log` instead of `Write-Status`:**

```powershell
Write-Log "Starting operation..."            # INFO (default, cyan)
Write-Log "Done." 'SUCCESS'                  # Green
Write-Log "Disk space low." 'WARN'           # Yellow
Write-Log "Operation failed: $err" 'ERROR'   # Red  + alert log + Event Log
Write-Log "Disk critically full!" 'ALERT'    # Magenta + alert log + Event Log
```

**3. Close the log on exit:**

```powershell
Close-Log -ExitCode 0
```

### `Initialize-Log` Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `ScriptName` | *(required)* | Used in filenames and Event Log. Typically the script's base name. |
| `LocalLogPath` | `C:\Logs\SysAdmin` | Local directory. Created automatically if missing. |
| `NetworkLogPath` | *(empty)* | UNC path for network log copy. Leave empty to disable. |
| `AlertLogPath` | *(empty)* | UNC path for alert-only log. Leave empty to disable. |
| `MaxLocalLogAgeDays` | `30` | Logs older than this are deleted automatically. |

### Log File Naming

```
<ScriptName>_<COMPUTERNAME>_<yyyy-MM-dd_HH-mm-ss>.log
<ScriptName>_<COMPUTERNAME>_<yyyy-MM-dd_HH-mm-ss>_ALERTS.log
```

Example:
```
Invoke-DiskCleanup_SERVER01_2026-03-28_03-00-00.log
Invoke-DiskCleanup_SERVER01_2026-03-28_03-00-00_ALERTS.log
```

### Backward Compatibility

All existing scripts that call `Write-Status` continue to work without modification after dot-sourcing this module — `Write-Status` is preserved as an alias for `Write-Log`. Migration to `Write-Log` is optional.

### Network Share Setup

Run once on the central log server to create the share:

```powershell
New-Item -ItemType Directory -Path 'D:\Logs\Windows' -Force
New-Item -ItemType Directory -Path 'D:\Logs\Windows\Alerts' -Force
New-SmbShare -Name 'SysAdminLogs' -Path 'D:\Logs\Windows' `
    -ChangeAccess 'DOMAIN\Domain Computers'
```

Grant the computer accounts (or a dedicated service account) **Change** permission on the share.

### Viewing Alerts in Event Viewer

All ERROR and ALERT entries are written to:
- **Log:** Application
- **Source:** SysAdminScript
- **Event ID:** 9001

Filter quickly with:
```powershell
Get-EventLog -LogName Application -Source SysAdminScript -Newest 50
```
