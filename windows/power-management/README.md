> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Power Management

Manage Windows power plans, configure sleep/hibernation, and control shutdown/restart behavior.

## Script

`Set-PowerManagement.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# List available power plans
.\Set-PowerManagement.ps1 -Action ListPlans

# Show the active power plan
.\Set-PowerManagement.ps1 -Action GetPlan

# Set the active power plan
.\Set-PowerManagement.ps1 -Action SetPlan -PlanName "High Performance"

# Disable sleep (recommended for servers)
.\Set-PowerManagement.ps1 -Action DisableSleep

# Set AC sleep timeout to 30 minutes
.\Set-PowerManagement.ps1 -Action SetSleepTimeout -ACTimeout 30

# Disable hibernation (frees disk space equal to RAM size)
.\Set-PowerManagement.ps1 -Action SetHibernation -EnableHibernation $false

# Initiate a system shutdown (60 second countdown)
.\Set-PowerManagement.ps1 -Action Shutdown

# Initiate a system restart
.\Set-PowerManagement.ps1 -Action Restart
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `ListPlans`, `GetPlan`, `SetPlan`, `DisableSleep`, `SetSleepTimeout`, `SetHibernation`, `Shutdown`, `Restart` |
| `-PlanName` | SetPlan | Power plan name (e.g., `Balanced`, `High Performance`, `Power Saver`) |
| `-ACTimeout` | SetSleepTimeout | Sleep timeout in minutes when on AC power (0 = never) |
| `-DCTimeout` | SetSleepTimeout | Sleep timeout in minutes when on DC/battery (0 = never) |
| `-EnableHibernation` | SetHibernation | `$true` to enable, `$false` to disable |

## Notes

- `DisableSleep` is equivalent to setting both AC and DC sleep timeouts to 0 (never).
- Disabling hibernation removes the `hiberfil.sys` file, freeing disk space equal to your RAM.
- On servers, the recommended plan is **High Performance** with sleep and hibernation disabled.
- `Shutdown` and `Restart` have a 60-second countdown and broadcast a message to logged-in users.
