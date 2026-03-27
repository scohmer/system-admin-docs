> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — WSUS Client Configuration

Configure the Windows Update client to use a WSUS server, target groups, and update detection settings.

## Script

`Set-WSUSClient.ps1`

## Usage

```powershell
# Show current Windows Update / WSUS configuration
.\Set-WSUSClient.ps1 -Action GetConfig

# Point this client to a WSUS server
.\Set-WSUSClient.ps1 -Action SetServer -WSUSServer "http://wsus.corp.local:8530"

# Set this client's WSUS target group
.\Set-WSUSClient.ps1 -Action SetTargetGroup -TargetGroup "Servers"

# Force Windows Update detection (check-in with WSUS now)
.\Set-WSUSClient.ps1 -Action ForceDetection

# Force Windows Update reporting to WSUS
.\Set-WSUSClient.ps1 -Action ForceReport

# Reset WSUS client registration (fixes stuck clients)
.\Set-WSUSClient.ps1 -Action Reset

# Remove WSUS configuration (revert to Windows Update)
.\Set-WSUSClient.ps1 -Action RemoveServer
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `GetConfig`, `SetServer`, `SetTargetGroup`, `ForceDetection`, `ForceReport`, `Reset`, `RemoveServer` |
| `-WSUSServer` | SetServer | WSUS server URL including port (e.g., `http://wsus.corp.local:8530`) |
| `-TargetGroup` | SetTargetGroup | WSUS target group name (must match group on WSUS server) |

## Notes

- Settings are written to `HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate` — this is the same location Group Policy writes.
- If WSUS is configured via Group Policy, manual registry changes may be overwritten at next GP refresh.
- `Reset` clears the SUS Client ID from the registry and restarts the Windows Update service, causing the client to re-register with WSUS.
