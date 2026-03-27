> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Local Group Management

Create, modify, and list local groups and their memberships on a Windows system.

## Script

`Manage-LocalGroups.ps1`

## Usage

```powershell
# List all local groups
.\Manage-LocalGroups.ps1 -Action List

# Show members of a specific group
.\Manage-LocalGroups.ps1 -Action GetMembers -GroupName "Administrators"

# Create a new local group
.\Manage-LocalGroups.ps1 -Action Create -GroupName "AppAdmins" -Description "Application administrators"

# Add a user or group to a local group
.\Manage-LocalGroups.ps1 -Action AddMember -GroupName "AppAdmins" -MemberName "jdoe"

# Add a domain user or group to a local group
.\Manage-LocalGroups.ps1 -Action AddMember -GroupName "Remote Desktop Users" -MemberName "DOMAIN\HelpDesk"

# Remove a member from a group
.\Manage-LocalGroups.ps1 -Action RemoveMember -GroupName "AppAdmins" -MemberName "jdoe"

# Delete a local group
.\Manage-LocalGroups.ps1 -Action Delete -GroupName "AppAdmins"

# Rename a local group
.\Manage-LocalGroups.ps1 -Action Rename -GroupName "AppAdmins" -NewName "ApplicationAdmins"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `GetMembers`, `Create`, `AddMember`, `RemoveMember`, `Delete`, `Rename` |
| `-GroupName` | Context | Local group name |
| `-MemberName` | Add/Remove | User or group name to add or remove (use `DOMAIN\Name` for domain accounts) |
| `-Description` | Create | Group description |
| `-NewName` | Rename | New group name |

## Notes

- Uses `Microsoft.PowerShell.LocalAccounts` module (built-in since PowerShell 5.1).
- For Active Directory groups, use `Manage-ADUsers.ps1` with the RSAT AD module.
- Built-in groups (Administrators, Users, etc.) cannot be deleted.
