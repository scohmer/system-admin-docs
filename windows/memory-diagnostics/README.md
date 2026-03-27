> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Memory Diagnostics

Run Windows Memory Diagnostic, check memory health, and view historical memory error events.

## Script

`Invoke-MemoryDiagnostic.ps1`

## Usage

```powershell
# Show current memory usage and installed modules
.\Invoke-MemoryDiagnostic.ps1 -Action GetMemoryInfo

# Schedule Windows Memory Diagnostic on next reboot
.\Invoke-MemoryDiagnostic.ps1 -Action ScheduleDiagnostic

# Check Event Log for memory diagnostic results from last run
.\Invoke-MemoryDiagnostic.ps1 -Action GetResults

# Check for hardware memory errors in the System event log
.\Invoke-MemoryDiagnostic.ps1 -Action CheckErrors

# Show page file / virtual memory configuration
.\Invoke-MemoryDiagnostic.ps1 -Action GetPageFile
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `GetMemoryInfo`, `ScheduleDiagnostic`, `GetResults`, `CheckErrors`, `GetPageFile` |

## Notes

- `ScheduleDiagnostic` schedules `mdsched.exe` to run at next reboot and will prompt the user to restart (or restart automatically with `-Force`).
- Diagnostic results appear in Event Viewer under `System` with Source `MemoryDiagnostics-Results` (Event ID 1201).
- Hardware memory errors appear with Source `WHEA-Logger` or `mcupdate`.
- Run as Administrator for scheduling and event log access.
