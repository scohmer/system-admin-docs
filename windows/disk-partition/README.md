> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Disk Partition Management

List disks, create partitions, format volumes, extend partitions, and assign drive letters using PowerShell Storage cmdlets.

## Script

`Manage-DiskPartitions.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# List all disks
.\Manage-DiskPartitions.ps1 -Action ListDisks

# List partitions on disk 1
.\Manage-DiskPartitions.ps1 -Action ListPartitions -DiskNumber 1

# Initialize a raw disk (GPT)
.\Manage-DiskPartitions.ps1 -Action Initialize -DiskNumber 1

# Create a new partition using all available space
.\Manage-DiskPartitions.ps1 -Action CreatePartition -DiskNumber 1 -AssignLetter D

# Create a 50 GB partition
.\Manage-DiskPartitions.ps1 -Action CreatePartition -DiskNumber 1 -SizeGB 50 -AssignLetter E

# Format a volume as NTFS
.\Manage-DiskPartitions.ps1 -Action FormatVolume -DriveLetter D -Label "Data" -FileSystem NTFS

# Extend partition to use all available space
.\Manage-DiskPartitions.ps1 -Action ExtendPartition -DriveLetter D

# Assign a letter to an existing partition
.\Manage-DiskPartitions.ps1 -Action AssignLetter -DiskNumber 1 -PartitionNumber 2 -DriveLetter F
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `ListDisks`, `ListPartitions`, `Initialize`, `CreatePartition`, `FormatVolume`, `ExtendPartition`, `AssignLetter` |
| `-DiskNumber` | Context | Disk number (from `ListDisks`) |
| `-PartitionNumber` | Context | Partition number (from `ListPartitions`) |
| `-SizeGB` | No | Partition size in GB (omit to use all remaining space) |
| `-DriveLetter` | Context | Drive letter to assign or format (without colon) |
| `-AssignLetter` | CreatePartition | Letter to assign to the new partition |
| `-FileSystem` | FormatVolume | `NTFS` (default), `ReFS`, or `FAT32` |
| `-Label` | No | Volume label |

## Notes

- `Initialize` overwrites the disk partition table — all data on the disk will be lost.
- `CreatePartition` without `-SizeGB` uses all remaining unallocated space.
- Do not extend or modify the OS partition (`C:`) while Windows is running; use offline tools.
- Always verify the correct disk number with `ListDisks` before initializing or partitioning.
