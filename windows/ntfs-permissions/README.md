> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — NTFS Permissions

View, add, remove, and replace NTFS access control entries (ACEs) on files and folders.

## Script

`Set-NTFSPermissions.ps1`

**Must be run as Administrator or as a user with Write Owner/Take Ownership rights.**

## Usage

```powershell
# View current permissions on a folder
.\Set-NTFSPermissions.ps1 -Action Get -Path "D:\Data\Finance"

# Add read permission for a user
.\Set-NTFSPermissions.ps1 -Action Add -Path "D:\Data\Finance" `
  -Identity "CORP\jdoe" -Rights ReadAndExecute

# Add full control for a group (recursive)
.\Set-NTFSPermissions.ps1 -Action Add -Path "D:\Data\Finance" `
  -Identity "CORP\Finance-Admins" -Rights FullControl -Recurse

# Remove all permissions for an identity
.\Set-NTFSPermissions.ps1 -Action Remove -Path "D:\Data\Finance" `
  -Identity "CORP\jdoe"

# Add a deny ACE
.\Set-NTFSPermissions.ps1 -Action Add -Path "D:\Data\Restricted" `
  -Identity "CORP\Contractors" -Rights FullControl -AccessType Deny

# Disable inheritance and copy existing permissions
.\Set-NTFSPermissions.ps1 -Action DisableInheritance -Path "D:\Data\Finance"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `Get`, `Add`, `Remove`, `DisableInheritance`, `EnableInheritance` |
| `-Path` | Yes | File or folder path |
| `-Identity` | Add/Remove | User or group (e.g., `CORP\jdoe`, `Administrators`) |
| `-Rights` | Add | `FullControl`, `Modify`, `ReadAndExecute`, `Read`, `Write`, `ListDirectory` |
| `-AccessType` | No | `Allow` (default) or `Deny` |
| `-Recurse` | No | Apply to all child files and folders |

## Notes

- NTFS `Deny` permissions override `Allow` — use sparingly and deliberately.
- Disabling inheritance copies existing inherited ACEs as explicit entries before removing inheritance.
- Use `-Recurse` with caution on large directory trees — it can take significant time.
- Always run `-Action Get` first to understand the existing ACL before making changes.
