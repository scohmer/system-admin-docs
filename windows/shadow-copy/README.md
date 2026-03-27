> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Shadow Copy Management

Manages Windows Volume Shadow Copies (VSS snapshots) including listing, creating, deleting, mounting, and scheduling. Uses both CIM/WMI (`Win32_ShadowCopy`) and `vssadmin` for full coverage.

## Script

`Manage-ShadowCopies.ps1`

## Usage

```powershell
# List all shadow copies for C:
.\Manage-ShadowCopies.ps1 -Action List -Drive C:

# Create a new shadow copy of C:
.\Manage-ShadowCopies.ps1 -Action Create -Drive C:

# Delete a specific shadow copy by ID
.\Manage-ShadowCopies.ps1 -Action Delete -ShadowID "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}"

# Mount a shadow copy as a drive letter or path
.\Manage-ShadowCopies.ps1 -Action MountAs -ShadowID "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}" -MountPath "C:\ShadowMount"

# Open shadow copy in Explorer
.\Manage-ShadowCopies.ps1 -Action Browse -ShadowID "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}"

# Show VSS schedule for a volume
.\Manage-ShadowCopies.ps1 -Action GetSchedule -Drive C:

# Configure VSS schedule using Task Scheduler
.\Manage-ShadowCopies.ps1 -Action SetSchedule -Drive C:
```

## Parameters

| Parameter    | Type   | Required | Description                                                             |
|--------------|--------|----------|-------------------------------------------------------------------------|
| `-Action`    | String | Yes      | `List`, `Create`, `Delete`, `MountAs`, `Browse`, `GetSchedule`, `SetSchedule` |
| `-Drive`     | String | No       | Drive letter to operate on (default: `C:`)                              |
| `-ShadowID`  | String | No       | Shadow copy ID GUID (required for Delete, MountAs, Browse)              |
| `-MountPath` | String | No       | Target directory or drive letter path for MountAs                       |

## Notes

- Requires administrator privileges.
- Shadow copies must have VSS (Volume Shadow Copy service) enabled and running.
- `MountAs` creates a symbolic link directory to the shadow copy device path; use `Remove-Item` on the junction to unmount.
- `Browse` opens the shadow copy in Windows Explorer via the mounted device path.
- `GetSchedule`/`SetSchedule` interact with Windows Task Scheduler VSS tasks.
- Large volumes may take time to complete shadow copy creation.
