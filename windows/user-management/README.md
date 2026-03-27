> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — User Management

Manage local Windows user accounts: create, modify, reset passwords, disable, and remove users, as well as add users to local groups.

## Script

`Manage-LocalUsers.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# Create a new local user
.\Manage-LocalUsers.ps1 -Action Create -Username "jdoe" -FullName "Jane Doe" -Description "Support Staff"

# Disable a user account
.\Manage-LocalUsers.ps1 -Action Disable -Username "jdoe"

# Enable a user account
.\Manage-LocalUsers.ps1 -Action Enable -Username "jdoe"

# Reset a user's password (prompts securely)
.\Manage-LocalUsers.ps1 -Action ResetPassword -Username "jdoe"

# Add a user to a local group
.\Manage-LocalUsers.ps1 -Action AddToGroup -Username "jdoe" -GroupName "Remote Desktop Users"

# Remove a user from a local group
.\Manage-LocalUsers.ps1 -Action RemoveFromGroup -Username "jdoe" -GroupName "Remote Desktop Users"

# Remove a user account permanently
.\Manage-LocalUsers.ps1 -Action Remove -Username "jdoe"

# List all local users
.\Manage-LocalUsers.ps1 -Action List
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | One of: `Create`, `Disable`, `Enable`, `ResetPassword`, `AddToGroup`, `RemoveFromGroup`, `Remove`, `List` |
| `-Username` | Yes (except List) | The local username to act on |
| `-FullName` | No | Full display name (used with `Create`) |
| `-Description` | No | Account description (used with `Create`) |
| `-GroupName` | Yes for group actions | Local group name (e.g., `Administrators`, `Remote Desktop Users`) |

## Notes

- Passwords are never passed as plain text; the script prompts using `Read-Host -AsSecureString`.
- The `Remove` action is irreversible. Confirm the username before executing.
- To manage **domain** users, use Active Directory tools instead.
