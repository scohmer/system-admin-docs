> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — System Information

Retrieve comprehensive system information including OS, hardware, BIOS, installed software, and drivers.

## Script

`Get-SystemInfo.ps1`

## Usage

```powershell
# Show all system information
.\Get-SystemInfo.ps1 -Action All

# OS and system summary
.\Get-SystemInfo.ps1 -Action OS

# Hardware summary (CPU, RAM, motherboard)
.\Get-SystemInfo.ps1 -Action Hardware

# BIOS/UEFI information
.\Get-SystemInfo.ps1 -Action BIOS

# Installed software list
.\Get-SystemInfo.ps1 -Action Software

# Installed drivers
.\Get-SystemInfo.ps1 -Action Drivers

# Hotfixes and Windows updates installed
.\Get-SystemInfo.ps1 -Action Hotfixes

# Export all info to a text file
.\Get-SystemInfo.ps1 -Action All -ExportPath "C:\Reports\$(hostname)-sysinfo.txt"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `All`, `OS`, `Hardware`, `BIOS`, `Software`, `Drivers`, `Hotfixes` |
| `-ExportPath` | No | File path to export the report (in addition to console output) |
| `-ComputerName` | No | Remote computer name (default: local) |

## Notes

- Does not require Hyper-V or RSAT modules — uses built-in CIM/WMI.
- `Software` queries both 64-bit and 32-bit registry hives.
- Run as Administrator for full driver and BIOS access on some hardware.
