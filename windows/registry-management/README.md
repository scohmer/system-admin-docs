> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Registry Management

Read, write, delete, export, import, and list Windows registry keys and values using PowerShell. Supports all common registry value types and works across HKLM, HKCU, and other hives.

## Script

`Manage-Registry.ps1`

No admin required for HKCU operations. Admin is required for HKLM and other system hives.

## Usage

```powershell
# Get a registry value
.\Manage-Registry.ps1 -Action Get -RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName"

# Set a registry value (creates key/value if it doesn't exist)
.\Manage-Registry.ps1 -Action Set -RegistryPath "HKCU:\SOFTWARE\MyApp" -Name "Setting1" -Value "Enabled" -Type String

# Set a DWORD value
.\Manage-Registry.ps1 -Action Set -RegistryPath "HKLM:\SOFTWARE\MyApp" -Name "MaxRetries" -Value 5 -Type DWord

# Delete a registry value
.\Manage-Registry.ps1 -Action Delete -RegistryPath "HKCU:\SOFTWARE\MyApp" -Name "OldSetting"

# List all values under a key
.\Manage-Registry.ps1 -Action ListKeys -RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

# Export a registry key to a .reg file
.\Manage-Registry.ps1 -Action Export -RegistryPath "HKCU:\SOFTWARE\MyApp" -ExportPath "C:\Backups\MyApp.reg"

# Import a .reg file
.\Manage-Registry.ps1 -Action Import -ExportPath "C:\Backups\MyApp.reg"
```

## Parameters

| Parameter       | Type   | Required | Description                                                          |
|-----------------|--------|----------|----------------------------------------------------------------------|
| `-Action`       | String | Yes      | Action: Get, Set, Delete, Export, Import, ListKeys                   |
| `-RegistryPath` | String | Varies   | Registry path in PS drive format (e.g. `HKLM:\SOFTWARE\...`)        |
| `-Name`         | String | Varies   | Name of the registry value                                           |
| `-Value`        | Object | Varies   | Value data to set                                                    |
| `-Type`         | String | No       | Value type: String, DWord, QWord, Binary, MultiString (default: String) |
| `-ExportPath`   | String | Varies   | File path for Export/Import operations (.reg file)                   |

## Notes

- HKLM (and other system hives) require Administrator privileges
- HKCU operations do not require elevation
- Export uses `reg.exe export` which produces a standard .reg file compatible with regedit
- Import uses `reg.exe import` which applies the .reg file; backup first
- Use `-WhatIf` to preview Set and Delete actions
- The script creates intermediate registry keys automatically when using Set
