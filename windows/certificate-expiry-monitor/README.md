# Certificate Expiry Monitor

> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

## Overview

Scans Windows certificate stores for certificates approaching expiry and issues WARN/ALERT log entries based on configurable day thresholds. Uses the shared `Write-Log` module to write alerts to a network share log and the Windows Application Event Log.

## Prerequisites

- PowerShell 5.1 or later
- `windows/shared/Write-Log.ps1` present in the repo
- No additional modules required — uses the built-in .NET X509 API

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `Action` | *(required)* | `Check` — scan and display; `Export` — scan and write CSV |
| `StoreLocation` | `LocalMachine` | `LocalMachine` or `CurrentUser` |
| `StoreName` | `My` | Store name (e.g. `My`, `Root`, `CA`) or `All` |
| `WarnDays` | `60` | Days before expiry to issue a WARN |
| `AlertDays` | `14` | Days before expiry to issue an ALERT |
| `ExportCsv` | *(empty)* | CSV output path (used with `-Action Export`) |
| `LocalLogPath` | `C:\Logs\SysAdmin` | Local directory for log files |
| `NetworkLogPath` | *(empty)* | UNC path for network log copy |
| `AlertLogPath` | *(empty)* | UNC path for alert-only log |

## Usage

```powershell
# Check LocalMachine\My store (typical for server certs)
.\Get-CertificateExpiry.ps1 -Action Check

# Scan all stores with extended warning window
.\Get-CertificateExpiry.ps1 -Action Check `
    -StoreName All `
    -WarnDays 90 -AlertDays 30 `
    -NetworkLogPath '\\logserver\SysAdminLogs\windows' `
    -AlertLogPath   '\\logserver\SysAdminLogs\windows\alerts'

# Export expiring certs to CSV for reporting
.\Get-CertificateExpiry.ps1 -Action Export `
    -StoreName All `
    -ExportCsv 'C:\Reports\cert-expiry.csv'
```

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | No certificates expiring within `WarnDays` |
| `1` | Certificates expiring within `WarnDays` (WARN) |
| `2` | Certificates expiring within `AlertDays` (ALERT) |

## Alert Behavior

When a certificate reaches the ALERT threshold:
- An **ALERT** entry is written to the console (magenta), local log, network log, and alert log
- A Windows **Application Event Log** entry is written (Source: `SysAdminScript`, Event ID: 9001)

## Scheduling

Schedule monthly (or weekly for critical systems) via Task Scheduler:

```powershell
.\Manage-ScheduledTasks.ps1 -Action Create `
    -TaskName 'CertExpiryMonitor' `
    -ScriptPath 'C:\Scripts\certificate-expiry-monitor\Get-CertificateExpiry.ps1' `
    -Arguments '-Action Check -StoreName All -WarnDays 90 -AlertDays 30 -AlertLogPath \\logserver\SysAdminLogs\windows\alerts' `
    -TriggerTime '07:00'
```
