> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Process Management

List, filter, and kill Windows processes. Identify high CPU/memory consumers and view detailed process information.

## Script

`Manage-Processes.ps1`

## Usage

```powershell
# List top 20 processes by CPU usage
.\Manage-Processes.ps1 -Action List

# Find a process by name
.\Manage-Processes.ps1 -Action Find -ProcessName "notepad"

# Show detailed info for a process
.\Manage-Processes.ps1 -Action Details -ProcessName "w3wp"

# Kill a process by name (kills ALL instances)
.\Manage-Processes.ps1 -Action Kill -ProcessName "notepad"

# Kill a specific process by PID
.\Manage-Processes.ps1 -Action Kill -PID 1234

# List processes consuming more than 50% CPU
.\Manage-Processes.ps1 -Action HighCPU -CPUThreshold 50

# List processes using more than 500 MB of memory
.\Manage-Processes.ps1 -Action HighMemory -MemoryMBThreshold 500
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `Find`, `Details`, `Kill`, `HighCPU`, `HighMemory` |
| `-ProcessName` | Context | Process name (without `.exe`) — supports wildcards |
| `-PID` | Kill | Process ID to kill |
| `-TopN` | No | Number of processes for `List` (default: `20`) |
| `-CPUThreshold` | HighCPU | Minimum CPU seconds to flag (default: `10`) |
| `-MemoryMBThreshold` | HighMemory | Minimum working set in MB (default: `200`) |

## Notes

- `Kill` by name terminates **all** processes with that name. Use `-PID` for precision.
- CPU column shows total CPU seconds consumed since process start, not current %.
- Use `-Action Details` to see a process's full path, parent PID, and handles — useful for diagnosing unknown processes.
