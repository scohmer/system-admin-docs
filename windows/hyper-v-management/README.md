> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Hyper-V Management

Start, stop, checkpoint, and manage Hyper-V virtual machines via PowerShell.

## Prerequisites

```powershell
# Install Hyper-V role (Server)
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart

# Enable Hyper-V (Windows 10/11 Pro/Enterprise)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

## Script

`Manage-HyperV.ps1`

**Must be run as Administrator or Hyper-V Administrators group member.**

## Usage

```powershell
# List all VMs on the local host
.\Manage-HyperV.ps1 -Action ListVMs

# Start a VM
.\Manage-HyperV.ps1 -Action Start -VMName "WebServer01"

# Stop a VM gracefully (shutdown guest OS)
.\Manage-HyperV.ps1 -Action Stop -VMName "WebServer01"

# Force stop (equivalent to pulling the power)
.\Manage-HyperV.ps1 -Action Stop -VMName "WebServer01" -Force

# Restart a VM
.\Manage-HyperV.ps1 -Action Restart -VMName "WebServer01"

# Create a checkpoint (snapshot)
.\Manage-HyperV.ps1 -Action Checkpoint -VMName "WebServer01" -CheckpointName "Pre-Update-$(Get-Date -f yyyyMMdd)"

# List checkpoints for a VM
.\Manage-HyperV.ps1 -Action ListCheckpoints -VMName "WebServer01"

# Restore a checkpoint
.\Manage-HyperV.ps1 -Action RestoreCheckpoint -VMName "WebServer01" -CheckpointName "Pre-Update-20260326"

# Delete a checkpoint
.\Manage-HyperV.ps1 -Action DeleteCheckpoint -VMName "WebServer01" -CheckpointName "Pre-Update-20260326"

# Manage a remote Hyper-V host
.\Manage-HyperV.ps1 -Action ListVMs -ComputerName "hyperv-host01"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `ListVMs`, `Start`, `Stop`, `Restart`, `Suspend`, `Resume`, `Checkpoint`, `ListCheckpoints`, `RestoreCheckpoint`, `DeleteCheckpoint`, `GetInfo` |
| `-VMName` | Context | Virtual machine name |
| `-CheckpointName` | Context | Checkpoint name |
| `-Force` | No | Force-stop without graceful shutdown |
| `-ComputerName` | No | Hyper-V host to manage (default: local) |

## Notes

- `Stop` without `-Force` sends a shutdown command to the guest OS — requires Integration Services installed in the VM.
- Restoring a checkpoint reverts the VM to that point in time. All changes since the checkpoint are lost.
- Production VMs should use **Production Checkpoints** (VSS-based) rather than Standard checkpoints to avoid application inconsistency.
