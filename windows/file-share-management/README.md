> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — File Share Management

Create, modify, remove, and report on SMB file shares and their share-level permissions.

## Script

`Manage-FileShares.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# List all SMB shares
.\Manage-FileShares.ps1 -Action List

# Show details for a specific share
.\Manage-FileShares.ps1 -Action Show -ShareName "Data"

# Create a share with read-only access for a group
.\Manage-FileShares.ps1 -Action Create -ShareName "Data" `
  -Path "D:\SharedData" `
  -Description "Shared data drive" `
  -ReadOnlyUsers "CORP\Domain Users" `
  -FullAccessUsers "CORP\IT-Admins"

# Show who is connected to a share
.\Manage-FileShares.ps1 -Action GetConnections -ShareName "Data"

# Remove a share (does NOT delete the folder)
.\Manage-FileShares.ps1 -Action Remove -ShareName "Data"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `Show`, `Create`, `Remove`, `GetConnections` |
| `-ShareName` | Context | SMB share name |
| `-Path` | Create | Local filesystem path to share |
| `-Description` | No | Share description/comment |
| `-FullAccessUsers` | No | User or group with Full Control share permission |
| `-ReadOnlyUsers` | No | User or group with Read share permission |

## Notes

- Share-level permissions are a first gate; NTFS permissions provide granular control. Use the [ntfs-permissions](../ntfs-permissions/) script for NTFS ACLs.
- Removing a share does **not** delete the underlying folder or files.
- Admin shares (`C$`, `ADMIN$`, etc.) cannot be removed with this script.
- Share names with spaces must be quoted when accessed: `\\server\"share name"`.
