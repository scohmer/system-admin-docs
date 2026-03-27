> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Windows Features Management

Enable, disable, and list optional Windows features using DISM/PowerShell. Works on both Windows Server (`Get-WindowsFeature`) and Windows Desktop (`Get-WindowsOptionalFeature`).

## Script

`Manage-WindowsFeatures.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# List all available features (Server OS)
.\Manage-WindowsFeatures.ps1 -Action List

# List only enabled features
.\Manage-WindowsFeatures.ps1 -Action ListEnabled

# Check the status of a specific feature
.\Manage-WindowsFeatures.ps1 -Action Status -FeatureName "Telnet-Client"

# Enable a feature (Server)
.\Manage-WindowsFeatures.ps1 -Action Enable -FeatureName "Web-Server"

# Enable with all sub-features
.\Manage-WindowsFeatures.ps1 -Action Enable -FeatureName "RSAT" -IncludeAllSubFeature

# Enable a feature (Windows 10/11 Desktop)
.\Manage-WindowsFeatures.ps1 -Action Enable -FeatureName "Microsoft-Windows-Subsystem-Linux"

# Disable a feature
.\Manage-WindowsFeatures.ps1 -Action Disable -FeatureName "Telnet-Client"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `ListEnabled`, `Status`, `Enable`, `Disable` |
| `-FeatureName` | Context | Feature name. Use `List` to find exact names. |
| `-IncludeAllSubFeature` | No | Also enable all sub-features (Server OS only) |

## Common Feature Names

| Feature | OS | Name |
|---------|-----|------|
| IIS Web Server | Server | `Web-Server` |
| DNS Server | Server | `DNS` |
| DHCP Server | Server | `DHCP` |
| Hyper-V | Server | `Hyper-V` |
| RSAT Tools | Server | `RSAT` |
| Telnet Client | Both | `Telnet-Client` (Server) / `TelnetClient` (Desktop) |
| WSL | Desktop | `Microsoft-Windows-Subsystem-Linux` |
| .NET 3.5 | Both | `NetFx3` (Desktop DISM name) |

## Notes

- Some features require a reboot after enable/disable. The script reports whether a reboot is needed.
- The script auto-detects whether it's running on Server or Desktop OS and uses the appropriate cmdlets.
