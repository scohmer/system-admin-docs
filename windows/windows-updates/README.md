> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Windows Updates

Check for and install Windows updates via PowerShell using the PSWindowsUpdate module.

## Prerequisites

The `PSWindowsUpdate` module must be installed:

```powershell
Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers
```

## Script

`Invoke-WindowsUpdates.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# Check for available updates (no installation)
.\Invoke-WindowsUpdates.ps1 -Action Check

# Install all available updates (prompts for reboot confirmation)
.\Invoke-WindowsUpdates.ps1 -Action Install

# Install updates and automatically reboot if required
.\Invoke-WindowsUpdates.ps1 -Action Install -AutoReboot

# Install only security updates
.\Invoke-WindowsUpdates.ps1 -Action InstallSecurityOnly

# View update history
.\Invoke-WindowsUpdates.ps1 -Action History
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | One of: `Check`, `Install`, `InstallSecurityOnly`, `History` |
| `-AutoReboot` | No | Automatically reboot after installation if required (default: false — prompts) |

## Notes

- Do **not** run `-Action Install` on production servers without a maintenance window.
- If `PSWindowsUpdate` is not available, use `sconfig` (Server Core) or Windows Update in Settings.
- After installation, review the update history with `-Action History` to confirm success.
