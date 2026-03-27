> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — NFS Client

Enable the Windows NFS client and mount NFS shares from Linux/Unix servers.

## Prerequisites

```powershell
# Enable NFS Client feature (Windows 10/11 Pro/Enterprise)
Enable-WindowsOptionalFeature -Online -FeatureName ServicesForNFS-ClientOnly,ClientForNFS-Infrastructure -All

# OR on Windows Server
Install-WindowsFeature NFS-Client
```

## Script

`Manage-NFSClient.ps1`

## Usage

```powershell
# Check NFS client status
.\Manage-NFSClient.ps1 -Action Status

# List currently mounted NFS shares
.\Manage-NFSClient.ps1 -Action List

# Mount an NFS share to a drive letter
.\Manage-NFSClient.ps1 -Action Mount -NFSPath "192.168.1.10:/exports/data" -DriveLetter Z

# Unmount a drive
.\Manage-NFSClient.ps1 -Action Unmount -DriveLetter Z

# Show NFS client configuration (UID/GID mapping, transfer sizes)
.\Manage-NFSClient.ps1 -Action GetConfig

# Set anonymous UID/GID for permission mapping
.\Manage-NFSClient.ps1 -Action SetAnonymousID -UID 0 -GID 0
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `Status`, `List`, `Mount`, `Unmount`, `GetConfig`, `SetAnonymousID` |
| `-NFSPath` | Mount | NFS path in `host:/export` format |
| `-DriveLetter` | Mount/Unmount | Drive letter to mount to or unmount |
| `-UID` | SetAnonymousID | Anonymous UID (default: `-2`) |
| `-GID` | SetAnonymousID | Anonymous GID (default: `-2`) |

## Notes

- Windows NFS client maps all NFS access to a configurable anonymous UID/GID. Set UID/GID to `0` for root access to exports that permit it.
- NFS mounts do not survive reboot by default. Use `Mount-PSDrive -Persist` or a startup script for persistent mounts.
- NFSv3 is the default; NFSv4 may require additional configuration on both client and server.
