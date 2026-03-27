> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Storage Spaces

Create and manage Windows Storage Spaces pools and virtual disks for software-defined storage with resiliency.

## Script

`Manage-StorageSpaces.ps1`

## Usage

```powershell
# List all storage pools
.\Manage-StorageSpaces.ps1 -Action ListPools

# List available (unallocated) physical disks
.\Manage-StorageSpaces.ps1 -Action ListDisks

# Create a new storage pool from physical disks
.\Manage-StorageSpaces.ps1 -Action CreatePool -PoolName "DataPool" -DiskNumbers 1,2,3,4

# List virtual disks in a pool
.\Manage-StorageSpaces.ps1 -Action ListVirtualDisks -PoolName "DataPool"

# Create a mirrored virtual disk (2-way mirror)
.\Manage-StorageSpaces.ps1 -Action CreateVirtualDisk -PoolName "DataPool" -VirtualDiskName "Data" -ResiliencyType Mirror -SizeGB 500

# Create a parity virtual disk
.\Manage-StorageSpaces.ps1 -Action CreateVirtualDisk -PoolName "DataPool" -VirtualDiskName "Archive" -ResiliencyType Parity -SizeGB 2000

# Get storage pool status
.\Manage-StorageSpaces.ps1 -Action GetPoolStatus -PoolName "DataPool"

# Remove a virtual disk
.\Manage-StorageSpaces.ps1 -Action RemoveVirtualDisk -PoolName "DataPool" -VirtualDiskName "Data"

# Remove a storage pool (all virtual disks must be removed first)
.\Manage-StorageSpaces.ps1 -Action RemovePool -PoolName "DataPool"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `ListPools`, `ListDisks`, `CreatePool`, `ListVirtualDisks`, `CreateVirtualDisk`, `GetPoolStatus`, `RemoveVirtualDisk`, `RemovePool` |
| `-PoolName` | Context | Storage pool name |
| `-VirtualDiskName` | Context | Virtual disk name |
| `-DiskNumbers` | CreatePool | Array of physical disk numbers to add to the pool |
| `-SizeGB` | CreateVirtualDisk | Virtual disk size in GB (omit for maximum) |
| `-ResiliencyType` | No | `Simple`, `Mirror`, `Parity` (default: `Mirror`) |
| `-NumberOfColumns` | No | Number of columns for striping (default: auto) |

## Notes

- **Simple** = no resiliency (striping only). **Mirror** = 2-way requires 2+ disks, 3-way requires 5+ disks. **Parity** = RAID-5 equivalent, requires 3+ disks.
- Storage Spaces requires Windows Server 2012+ or Windows 8+.
- Physical disks added to a pool must be unformatted and have no existing partitions.
- After creating a virtual disk, use `Manage-DiskPartitions.ps1` to initialize, partition, and format it.
