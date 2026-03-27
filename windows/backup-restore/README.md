> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Backup & Restore

Backup and restore directories using Robocopy. Supports full backups, incremental (mirror) backups, and dry-run previews.

## Script

`Invoke-Backup.ps1`

**Must be run as Administrator for system directories.**

## Usage

```powershell
# Preview what would be copied (dry run — no files are changed)
.\Invoke-Backup.ps1 -Action Backup -Source "C:\Data" -Destination "D:\Backups\Data" -WhatIf

# Full backup (copy all files)
.\Invoke-Backup.ps1 -Action Backup -Source "C:\Data" -Destination "D:\Backups\Data"

# Mirror backup (destination matches source exactly — deletes extra files in destination)
.\Invoke-Backup.ps1 -Action Mirror -Source "C:\Data" -Destination "D:\Backups\Data"

# Backup to a timestamped folder
.\Invoke-Backup.ps1 -Action Backup -Source "C:\Data" -Destination "D:\Backups" -Timestamped

# Incremental backup (copy only files newer than destination)
.\Invoke-Backup.ps1 -Action Incremental -Source "C:\Data" -Destination "D:\Backups\Data"

# Verify backup (compare source and destination, report differences)
.\Invoke-Backup.ps1 -Action Verify -Source "C:\Data" -Destination "D:\Backups\Data"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | One of: `Backup`, `Mirror`, `Incremental`, `Verify` |
| `-Source` | Yes | Source directory path |
| `-Destination` | Yes | Destination directory path |
| `-Timestamped` | No | Appends a `YYYY-MM-DD_HH-mm` timestamp to the destination path |
| `-LogFile` | No | Path to write the Robocopy log (default: `C:\Logs\backup_<date>.log`) |
| `-ExcludeFiles` | No | Array of file patterns to exclude (e.g., `"*.tmp","*.log"`) |
| `-ExcludeDirs` | No | Array of directory names to exclude (e.g., `"Temp","Cache"`) |

## Backup Modes

| Mode | Description | Deletes from Destination? |
|------|-------------|--------------------------|
| `Backup` | Copies all files from source to destination | No |
| `Mirror` | Makes destination an exact copy of source | **Yes** — removes extra files |
| `Incremental` | Copies only files newer than destination | No |
| `Verify` | Reports differences, no files copied | No |

## Notes

- `Mirror` mode **deletes files** in the destination that don't exist in the source. Use with caution.
- Robocopy exit codes: `0` = no change, `1` = files copied, `2`+ = errors. The script translates these to meaningful output.
- Logs are written to `C:\Logs\` by default. The directory is created if it doesn't exist.
- For large backup jobs, consider running via a Scheduled Task (see [scheduled-tasks](../scheduled-tasks/)).
