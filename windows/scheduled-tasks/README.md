> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Scheduled Tasks

Create, list, run, and remove Windows Scheduled Tasks via PowerShell.

## Script

`Manage-ScheduledTasks.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# List all scheduled tasks in the root folder
.\Manage-ScheduledTasks.ps1 -Action List

# List tasks in a specific folder
.\Manage-ScheduledTasks.ps1 -Action List -TaskPath "\Microsoft\Windows\WindowsUpdate"

# Show details of a specific task
.\Manage-ScheduledTasks.ps1 -Action Show -TaskName "My Backup Task"

# Create a daily task at 2:00 AM
.\Manage-ScheduledTasks.ps1 -Action Create `
  -TaskName "My Backup Task" `
  -ScriptPath "C:\Scripts\Invoke-Backup.ps1" `
  -TriggerType Daily `
  -TriggerTime "02:00"

# Create a task that runs at system startup
.\Manage-ScheduledTasks.ps1 -Action Create `
  -TaskName "Startup Script" `
  -ScriptPath "C:\Scripts\startup.ps1" `
  -TriggerType AtStartup

# Run a task immediately
.\Manage-ScheduledTasks.ps1 -Action Run -TaskName "My Backup Task"

# Enable or disable a task
.\Manage-ScheduledTasks.ps1 -Action Enable  -TaskName "My Backup Task"
.\Manage-ScheduledTasks.ps1 -Action Disable -TaskName "My Backup Task"

# Remove a task
.\Manage-ScheduledTasks.ps1 -Action Remove -TaskName "My Backup Task"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | One of: `List`, `Show`, `Create`, `Run`, `Enable`, `Disable`, `Remove` |
| `-TaskName` | Yes (except List) | Display name of the scheduled task |
| `-TaskPath` | No | Task folder path (default: `\`) |
| `-ScriptPath` | Yes for Create | Full path to the PowerShell script to run |
| `-TriggerType` | Yes for Create | One of: `Daily`, `Weekly`, `AtStartup`, `AtLogon`, `Once` |
| `-TriggerTime` | Yes for Daily/Weekly/Once | Time to run in `HH:mm` format (24-hour) |
| `-TriggerDay` | No | Day of week for `Weekly` trigger (e.g., `Monday`) |
| `-RunAsUser` | No | User account to run the task as (default: `SYSTEM`) |

## Notes

- Tasks created with `RunAsUser = SYSTEM` run without a user session.
- Script paths must be absolute. The task will fail silently if the path is wrong.
- Use `-Action Show` to verify the trigger and action before running.
