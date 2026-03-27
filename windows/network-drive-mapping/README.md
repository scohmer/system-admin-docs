> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Network Drive Mapping

Map, list, and remove persistent network drive mappings for users or system-wide.

## Script

`Manage-NetworkDrives.ps1`

## Usage

```powershell
# List all currently mapped drives
.\Manage-NetworkDrives.ps1 -Action List

# Map a drive letter to a UNC path (persistent across reboots)
.\Manage-NetworkDrives.ps1 -Action Map -DriveLetter Z -UNCPath "\\fileserver\share"

# Map with explicit credentials
.\Manage-NetworkDrives.ps1 -Action Map -DriveLetter Z -UNCPath "\\fileserver\share" -UserName "DOMAIN\user"

# Remove a mapped drive
.\Manage-NetworkDrives.ps1 -Action Remove -DriveLetter Z

# Test connectivity to a UNC path without mapping
.\Manage-NetworkDrives.ps1 -Action Test -UNCPath "\\fileserver\share"

# Remove all mapped drives
.\Manage-NetworkDrives.ps1 -Action RemoveAll
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `Map`, `Remove`, `Test`, `RemoveAll` |
| `-DriveLetter` | Map/Remove | Drive letter to map or remove (e.g., `Z`) |
| `-UNCPath` | Map/Test | UNC path to the network share (e.g., `\\server\share`) |
| `-UserName` | No | Username for authentication (prompts for password) |
| `-Persistent` | No | Keep mapping after reboot (default: `$true`) |

## Notes

- Mappings created as Administrator may not be visible to standard users due to UAC drive isolation.
- Use Group Policy (`User Configuration > Preferences > Drive Maps`) for domain-wide drive mapping.
- The `Test` action uses `Test-Path` over the network and does not require Admin rights.
