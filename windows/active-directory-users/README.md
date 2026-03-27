> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Active Directory User Management

Manage Active Directory user accounts from the command line using PowerShell and the RSAT ActiveDirectory module. Supports creating, disabling, enabling, unlocking, resetting passwords, moving to OUs, assigning managers, listing, and searching users.

## Script

`Manage-ADUsers.ps1`

Requires the RSAT ActiveDirectory PowerShell module. Run on a domain-joined machine with appropriate AD permissions.

## Usage

```powershell
# List all users in the domain
.\Manage-ADUsers.ps1 -Action List

# Search for users matching a filter
.\Manage-ADUsers.ps1 -Action Search -SearchFilter "Department -eq 'IT'"

# Create a new user
.\Manage-ADUsers.ps1 -Action Create -Username jsmith -DisplayName "John Smith" -OU "OU=Users,DC=corp,DC=local"

# Disable a user account
.\Manage-ADUsers.ps1 -Action Disable -Username jsmith

# Enable a user account
.\Manage-ADUsers.ps1 -Action Enable -Username jsmith

# Unlock a locked-out user
.\Manage-ADUsers.ps1 -Action Unlock -Username jsmith

# Reset a user's password
.\Manage-ADUsers.ps1 -Action ResetPassword -Username jsmith

# Move a user to a different OU
.\Manage-ADUsers.ps1 -Action Move -Username jsmith -OU "OU=Contractors,DC=corp,DC=local"

# Set a user's manager
.\Manage-ADUsers.ps1 -Action SetManager -Username jsmith -Manager bjones
```

## Parameters

| Parameter      | Type   | Required | Description                                                |
|----------------|--------|----------|------------------------------------------------------------|
| `-Action`      | String | Yes      | Action to perform: Create, Disable, Enable, Unlock, ResetPassword, Move, SetManager, List, Search |
| `-Username`    | String | Varies   | SAMAccountName of the target user                          |
| `-OU`          | String | Varies   | Distinguished name of the target OU (for Create/Move)      |
| `-DisplayName` | String | No       | Display name for new user (used with Create)               |
| `-Manager`     | String | No       | SAMAccountName of the manager (used with SetManager)       |
| `-SearchFilter`| String | No       | LDAP-style filter string for Search action                 |

## Notes

- Requires RSAT: Active Directory Domain Services and Lightweight Directory Services Tools
- Install RSAT: `Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0`
- The `ResetPassword` action will prompt for a new password securely
- The `Create` action generates a random initial password and outputs it; change on first login is enforced
- Run as a user with appropriate AD delegation or as a Domain Admin
- Use `-WhatIf` to preview changes without applying them
