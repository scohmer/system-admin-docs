> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Windows Defender Management

Check status, run scans, update definitions, manage exclusions, and review threat history for Windows Defender Antivirus.

## Script

`Invoke-DefenderManagement.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# Show Defender status and definition versions
.\Invoke-DefenderManagement.ps1 -Action Status

# Run a quick scan
.\Invoke-DefenderManagement.ps1 -Action QuickScan

# Run a full scan
.\Invoke-DefenderManagement.ps1 -Action FullScan

# Update virus definitions
.\Invoke-DefenderManagement.ps1 -Action UpdateDefinitions

# Add a path exclusion
.\Invoke-DefenderManagement.ps1 -Action AddExclusion -ExclusionPath "C:\App\Data"

# Add a file extension exclusion
.\Invoke-DefenderManagement.ps1 -Action AddExclusion -ExclusionPath ".log" -ExclusionType Extension

# List all exclusions
.\Invoke-DefenderManagement.ps1 -Action ListExclusions

# Remove a path exclusion
.\Invoke-DefenderManagement.ps1 -Action RemoveExclusion -ExclusionPath "C:\App\Data"

# Show detected threats history
.\Invoke-DefenderManagement.ps1 -Action GetThreats
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `Status`, `QuickScan`, `FullScan`, `UpdateDefinitions`, `AddExclusion`, `RemoveExclusion`, `ListExclusions`, `GetThreats` |
| `-ExclusionPath` | Exclusion actions | Path, extension (`.log`), or process name to exclude |
| `-ExclusionType` | No | `Path` (default), `Extension`, or `Process` |

## Notes

- Exclusions reduce security. Only exclude paths required for known compatibility issues (e.g., database files, build artifacts).
- After adding exclusions, verify they appear with `-Action ListExclusions` before assuming they're active.
- `FullScan` can take hours on large drives and will impact system performance.
- Real-time protection settings should be managed via Group Policy in domain environments rather than per-machine scripts.
