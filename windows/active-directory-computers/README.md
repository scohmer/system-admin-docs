> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Active Directory Computer Management

Manage Active Directory computer objects using PowerShell and the RSAT ActiveDirectory module. Supports listing, searching, disabling, enabling, moving to OUs, deleting, and retrieving last logon information for computer accounts.

## Script

`Manage-ADComputers.ps1`

Requires the RSAT ActiveDirectory PowerShell module. Run on a domain-joined machine with appropriate AD permissions.

## Usage

```powershell
# List all computer accounts
.\Manage-ADComputers.ps1 -Action List

# Search for computers matching a filter
.\Manage-ADComputers.ps1 -Action Search -SearchFilter "OperatingSystem -like '*Server*'"

# Disable a computer account
.\Manage-ADComputers.ps1 -Action Disable -ComputerName WORKSTATION01

# Enable a computer account
.\Manage-ADComputers.ps1 -Action Enable -ComputerName WORKSTATION01

# Move a computer to a different OU
.\Manage-ADComputers.ps1 -Action Move -ComputerName WORKSTATION01 -OU "OU=Decommissioned,DC=corp,DC=local"

# Delete a computer account
.\Manage-ADComputers.ps1 -Action Delete -ComputerName OLDPC01 -Confirm:$false

# Get last logon time for a computer
.\Manage-ADComputers.ps1 -Action GetLastLogon -ComputerName WORKSTATION01
```

## Parameters

| Parameter       | Type   | Required | Description                                                  |
|-----------------|--------|----------|--------------------------------------------------------------|
| `-Action`       | String | Yes      | Action to perform: List, Search, Disable, Enable, Move, Delete, GetLastLogon |
| `-ComputerName` | String | Varies   | Name of the target computer (SAM name without trailing $)    |
| `-OU`           | String | Varies   | Distinguished name of the target OU (for Move action)        |
| `-SearchFilter` | String | No       | LDAP-style filter string for Search action                   |

## Notes

- Requires RSAT: Active Directory Domain Services and Lightweight Directory Services Tools
- Install RSAT: `Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0`
- The `Delete` action is destructive and irreversible; use `-WhatIf` to preview
- `GetLastLogon` queries the `LastLogonDate` attribute (replicated) not the raw `lastLogon` (non-replicated)
- Use `-WhatIf` to preview changes without applying them
- Stale computer accounts (not logged on in 90+ days) are common targets for cleanup
