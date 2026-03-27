> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Service Management

Start, stop, restart, and query the status of Windows services.

## Script

`Manage-Services.ps1`

**Must be run as Administrator for Start/Stop/Restart actions.**

## Usage

```powershell
# Get the status of a service
.\Manage-Services.ps1 -Action Status -ServiceName "wuauserv"

# Start a service
.\Manage-Services.ps1 -Action Start -ServiceName "wuauserv"

# Stop a service
.\Manage-Services.ps1 -Action Stop -ServiceName "wuauserv"

# Restart a service
.\Manage-Services.ps1 -Action Restart -ServiceName "wuauserv"

# Set a service startup type
.\Manage-Services.ps1 -Action SetStartup -ServiceName "wuauserv" -StartupType Automatic

# List all services (optionally filter by status)
.\Manage-Services.ps1 -Action List
.\Manage-Services.ps1 -Action List -StatusFilter Running
.\Manage-Services.ps1 -Action List -StatusFilter Stopped
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | One of: `Status`, `Start`, `Stop`, `Restart`, `SetStartup`, `List` |
| `-ServiceName` | Yes (except List) | The service name (not display name). Use `Get-Service` to find service names. |
| `-StartupType` | Yes for SetStartup | One of: `Automatic`, `Manual`, `Disabled`, `AutomaticDelayedStart` |
| `-StatusFilter` | No | Filter `List` results: `Running`, `Stopped`, or omit for all |

## Notes

- Use the **service name**, not the display name (e.g., `wuauserv` not `Windows Update`).
- Run `Get-Service | Select-Object Name, DisplayName, Status` to find service names.
- Stopping critical services (e.g., `LanmanServer`, `Winmgmt`) can destabilize the system.
