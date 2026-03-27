> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Remote Desktop Configuration

Enable, disable, and configure Remote Desktop (RDP) including Network Level Authentication (NLA) and allowed users.

## Script

`Set-RemoteDesktop.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# Check current RDP status
.\Set-RemoteDesktop.ps1 -Action Status

# Enable RDP with NLA (recommended)
.\Set-RemoteDesktop.ps1 -Action Enable

# Enable RDP without NLA (less secure, needed for older clients)
.\Set-RemoteDesktop.ps1 -Action Enable -NLA Disabled

# Disable RDP
.\Set-RemoteDesktop.ps1 -Action Disable

# Add a user to Remote Desktop Users group
.\Set-RemoteDesktop.ps1 -Action AllowUser -Username "CORP\jdoe"

# Remove a user from Remote Desktop Users group
.\Set-RemoteDesktop.ps1 -Action RemoveUser -Username "CORP\jdoe"

# List users in Remote Desktop Users group
.\Set-RemoteDesktop.ps1 -Action ListUsers

# Change the RDP port (default 3389)
.\Set-RemoteDesktop.ps1 -Action SetPort -Port 3390
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `Status`, `Enable`, `Disable`, `AllowUser`, `RemoveUser`, `ListUsers`, `SetPort` |
| `-NLA` | No | `Enabled` (default) or `Disabled` — Network Level Authentication |
| `-Username` | User actions | User to add/remove from Remote Desktop Users group |
| `-Port` | SetPort | RDP listening port (default: `3389`) |

## Notes

- Enabling RDP automatically creates a Windows Firewall rule for the configured port.
- Changing the RDP port requires updating your firewall rules and clients — update both before restarting.
- NLA requires valid AD or local credentials before the full RDP session is established, reducing attack surface.
- Members of the `Administrators` group always have RDP access regardless of the Remote Desktop Users group.
