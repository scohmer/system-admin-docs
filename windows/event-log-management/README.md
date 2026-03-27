> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Event Log Management

Clear, resize, export (backup), and get information about Windows Event Logs.

## Script

`Manage-EventLogs.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# List all event logs with their size and record count
.\Manage-EventLogs.ps1 -Action List

# Get info on a specific log
.\Manage-EventLogs.ps1 -Action GetInfo -LogName "Application"

# Set max log size to 100 MB
.\Manage-EventLogs.ps1 -Action SetSize -LogName "Application" -MaxSizeKB 102400

# Export (backup) a log to .evtx before clearing
.\Manage-EventLogs.ps1 -Action Export -LogName "System" -ExportPath "C:\LogBackups\System.evtx"

# Clear a log
.\Manage-EventLogs.ps1 -Action Clear -LogName "Application"

# Clear all three main logs
.\Manage-EventLogs.ps1 -Action ClearAll

# Set retention policy
.\Manage-EventLogs.ps1 -Action SetRetention -LogName "Security" -RetentionDays 90
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `GetInfo`, `SetSize`, `Export`, `Clear`, `ClearAll`, `SetRetention` |
| `-LogName` | Context | Event log name (e.g., `System`, `Application`, `Security`) |
| `-MaxSizeKB` | SetSize | Maximum log size in KB |
| `-ExportPath` | Export | Full path for the `.evtx` export file |
| `-RetentionDays` | SetRetention | Days to retain events (0 = overwrite as needed) |
| `-ComputerName` | No | Manage a remote system's event logs |

## Notes

- Always export (`-Action Export`) before clearing a log — clearing is irreversible.
- Security log changes may require `auditpol` or Group Policy configuration.
- Use the [event-log-query](../event-log-query/) script to search and filter log contents.
