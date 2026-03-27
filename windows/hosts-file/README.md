> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Hosts File Management

Add, remove, list, and back up entries in the Windows hosts file (`C:\Windows\System32\drivers\etc\hosts`).

## Script

`Manage-HostsFile.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# List all non-comment entries
.\Manage-HostsFile.ps1 -Action List

# Add an entry
.\Manage-HostsFile.ps1 -Action Add -IPAddress "10.0.0.50" -Hostname "intranet.corp.local"

# Add with a comment
.\Manage-HostsFile.ps1 -Action Add -IPAddress "10.0.0.50" -Hostname "intranet.corp.local" `
  -Comment "Internal intranet server"

# Remove an entry by hostname
.\Manage-HostsFile.ps1 -Action Remove -Hostname "intranet.corp.local"

# Back up the hosts file
.\Manage-HostsFile.ps1 -Action Backup -BackupPath "C:\Backups\hosts.bak"

# Flush DNS cache after changes (also done automatically by Add/Remove)
.\Manage-HostsFile.ps1 -Action Flush
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `Add`, `Remove`, `Backup`, `Flush` |
| `-IPAddress` | Add | IP address for the entry |
| `-Hostname` | Add/Remove | Hostname to map or remove |
| `-Comment` | No | Optional comment appended after the entry |
| `-BackupPath` | Backup | Destination path for the backup file |

## Notes

- The script always backs up the hosts file to a `.bak` copy before any modification.
- Duplicate entries (same IP+hostname) are not added.
- DNS cache is flushed automatically after Add and Remove operations via `ipconfig /flushdns`.
- The default hosts file location is `%SystemRoot%\System32\drivers\etc\hosts`.
