> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Event Log Query

Search and export Windows Event Log entries with flexible filtering by log, event ID, level, source, and time range.

## Script

`Get-EventLogEntries.ps1`

## Usage

```powershell
# Show the last 50 System log entries
.\Get-EventLogEntries.ps1 -LogName System -Count 50

# Show only errors and warnings from the Application log in the last 24 hours
.\Get-EventLogEntries.ps1 -LogName Application -Level Error,Warning -HoursBack 24

# Filter by specific Event ID
.\Get-EventLogEntries.ps1 -LogName Security -EventId 4625 -Count 100

# Filter by event source
.\Get-EventLogEntries.ps1 -LogName System -Source "Service Control Manager"

# Export results to CSV
.\Get-EventLogEntries.ps1 -LogName Application -Level Error -HoursBack 48 -ExportCsv "C:\Logs\errors.csv"

# Query a remote computer
.\Get-EventLogEntries.ps1 -LogName System -ComputerName "SERVER01" -Count 50
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-LogName` | Yes | Log to query: `System`, `Application`, `Security`, or any custom log name |
| `-Count` | No | Maximum number of entries to return (default: `100`) |
| `-Level` | No | Filter by level: `Information`, `Warning`, `Error`, `Critical` (can specify multiple) |
| `-EventId` | No | Filter by a specific Event ID number |
| `-Source` | No | Filter by event source/provider name |
| `-HoursBack` | No | Return only events from the last N hours |
| `-ExportCsv` | No | Full path to export results as CSV (e.g., `C:\Logs\events.csv`) |
| `-ComputerName` | No | Query a remote computer (default: local machine) |

## Common Event IDs

| Log | Event ID | Meaning |
|-----|----------|---------|
| Security | 4624 | Successful logon |
| Security | 4625 | Failed logon attempt |
| Security | 4648 | Logon using explicit credentials |
| Security | 4720 | User account created |
| Security | 4726 | User account deleted |
| System | 6005 | Event Log service started (system boot) |
| System | 6006 | Event Log service stopped (system shutdown) |
| System | 7036 | Service state change |

## Notes

- Querying the Security log requires Administrator privileges.
- Remote queries require WinRM to be enabled on the target: `Enable-PSRemoting -Force`.
