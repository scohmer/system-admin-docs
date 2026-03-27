> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Disk Cleanup

Remove temporary files, clear system caches, and report disk usage to free up disk space.

## Script

`Invoke-DiskCleanup.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# Report disk usage only (no changes made)
.\Invoke-DiskCleanup.ps1 -Action Report

# Clean temp files for the current user
.\Invoke-DiskCleanup.ps1 -Action CleanUserTemp

# Clean system-wide temp files
.\Invoke-DiskCleanup.ps1 -Action CleanSystemTemp

# Clear Windows Update cache (frees significant space; safe after updates are installed)
.\Invoke-DiskCleanup.ps1 -Action CleanWindowsUpdate

# Empty the Recycle Bin for all users
.\Invoke-DiskCleanup.ps1 -Action EmptyRecycleBin

# Run all cleanup actions
.\Invoke-DiskCleanup.ps1 -Action All
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | One of: `Report`, `CleanUserTemp`, `CleanSystemTemp`, `CleanWindowsUpdate`, `EmptyRecycleBin`, `All` |
| `-Drive` | No | Drive letter to report on (default: `C`). Example: `D` |

## What Gets Cleaned

| Action | Location | Notes |
|--------|----------|-------|
| `CleanUserTemp` | `%TEMP%` | Current user temp files |
| `CleanSystemTemp` | `C:\Windows\Temp` | System-wide temp files |
| `CleanWindowsUpdate` | `C:\Windows\SoftwareDistribution\Download` | Safe after updates are confirmed installed |
| `EmptyRecycleBin` | All drives | Clears Recycle Bin for all users |

## Notes

- The script reports space freed before and after each operation.
- Files in use will be skipped without causing the script to fail.
- `CleanWindowsUpdate` stops and restarts the `wuauserv` service temporarily.
