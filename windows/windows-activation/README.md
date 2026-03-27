> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Windows Activation

Check, manage, and troubleshoot Windows activation status using the Software Licensing Service (SLS).

## Script

`Manage-WindowsActivation.ps1`

## Usage

```powershell
# Check current activation status
.\Manage-WindowsActivation.ps1 -Action Status

# Activate Windows online (using currently installed key)
.\Manage-WindowsActivation.ps1 -Action Activate

# Install a new product key
.\Manage-WindowsActivation.ps1 -Action InstallKey -ProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"

# Configure KMS server for volume activation
.\Manage-WindowsActivation.ps1 -Action SetKMSServer -KMSServer "kms.corp.local"

# Activate against KMS server
.\Manage-WindowsActivation.ps1 -Action ActivateKMS

# Remove the installed product key (for reimaging)
.\Manage-WindowsActivation.ps1 -Action RemoveKey

# Get detailed license information
.\Manage-WindowsActivation.ps1 -Action GetLicenseInfo
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `Status`, `Activate`, `InstallKey`, `SetKMSServer`, `ActivateKMS`, `RemoveKey`, `GetLicenseInfo` |
| `-ProductKey` | InstallKey | 25-character Windows product key |
| `-KMSServer` | SetKMSServer | KMS server hostname or IP |
| `-KMSPort` | No | KMS server port (default: `1688`) |

## Notes

- Uses `slmgr.vbs` (Software Licensing Management Tool) which is the standard Microsoft tool for activation management.
- `RemoveKey` removes the key from the registry (making it non-activatable) but does not deactivate the license from Microsoft's servers.
- KMS activation requires the system to contact the KMS server every 180 days. KMS requires a minimum of 25 clients (5 for Server) to activate.
