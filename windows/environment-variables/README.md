> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Environment Variables

Get, set, remove, and list system and user environment variables. Supports appending to `PATH`.

## Script

`Manage-EnvironmentVariables.ps1`

**Requires Administrator for Machine-scope variables.**

## Usage

```powershell
# List all system (Machine) variables
.\Manage-EnvironmentVariables.ps1 -Action List -Scope Machine

# List all user variables
.\Manage-EnvironmentVariables.ps1 -Action List -Scope User

# Get a specific variable
.\Manage-EnvironmentVariables.ps1 -Action Get -Name "PATH" -Scope Machine

# Set a system variable
.\Manage-EnvironmentVariables.ps1 -Action Set -Name "APP_HOME" -Value "C:\App" -Scope Machine

# Set a user variable
.\Manage-EnvironmentVariables.ps1 -Action Set -Name "MY_KEY" -Value "abc123" -Scope User

# Append a directory to the system PATH
.\Manage-EnvironmentVariables.ps1 -Action Append -Name "PATH" -Value "C:\Tools" -Scope Machine

# Remove a variable
.\Manage-EnvironmentVariables.ps1 -Action Remove -Name "APP_HOME" -Scope Machine
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `Get`, `Set`, `Remove`, `Append` |
| `-Name` | Context | Variable name |
| `-Value` | Set/Append | Variable value |
| `-Scope` | No | `Machine` (default), `User`, or `Process` |

## Notes

- `Machine` scope changes require **Administrator** rights and affect all users.
- Changes broadcast a `WM_SETTINGCHANGE` message so running applications pick up the change without a reboot.
- `Append` on `PATH` checks for duplicates before appending.
- New terminals/sessions see changes immediately; running processes may need a restart.
