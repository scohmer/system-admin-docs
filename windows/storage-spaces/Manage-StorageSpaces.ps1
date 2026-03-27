#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Create and manage Windows Storage Spaces pools and virtual disks.
.NOTES
    See README.md for resiliency types and prerequisites.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('ListPools','ListDisks','CreatePool','ListVirtualDisks','CreateVirtualDisk','GetPoolStatus','RemoveVirtualDisk','RemovePool')]
    [string]$Action,

    [Parameter()] [string]$PoolName,
    [Parameter()] [string]$VirtualDiskName,
    [Parameter()] [int[]]$DiskNumbers,
    [Parameter()] [double]$SizeGB = 0,
    [Parameter()] [ValidateSet('Simple','Mirror','Parity')] [string]$ResiliencyType = 'Mirror',
    [Parameter()] [int]$NumberOfColumns = 0
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

function Get-Pool {
    $pool = Get-StoragePool -FriendlyName $PoolName -ErrorAction SilentlyContinue
    if (-not $pool) { throw "Storage pool '$PoolName' not found." }
    return $pool
}

switch ($Action) {

    'ListPools' {
        Write-Status "Storage pools:"
        Get-StoragePool | Where-Object { $_.IsPrimordial -eq $false } |
            Select-Object FriendlyName, OperationalStatus, HealthStatus,
                @{N='Size(GB)';E={[math]::Round($_.Size/1GB,1)}},
                @{N='Allocated(GB)';E={[math]::Round($_.AllocatedSize/1GB,1)}},
                ResiliencySettingNameDefault |
            Format-Table -AutoSize
    }

    'ListDisks' {
        Write-Status "Available physical disks (not in a pool):"
        Get-PhysicalDisk -CanPool $true |
            Select-Object DeviceId, FriendlyName, MediaType,
                @{N='Size(GB)';E={[math]::Round($_.Size/1GB,1)}},
                HealthStatus |
            Format-Table -AutoSize
    }

    'CreatePool' {
        if (-not $PoolName)    { throw "-PoolName required." }
        if (-not $DiskNumbers) { throw "-DiskNumbers required (e.g., -DiskNumbers 1,2,3)." }
        $disks = $DiskNumbers | ForEach-Object { Get-PhysicalDisk | Where-Object { $_.DeviceId -eq $_ } }
        if ($disks.Count -ne $DiskNumbers.Count) { throw "One or more specified disk numbers not found or not poolable." }
        if ($PSCmdlet.ShouldProcess($PoolName, "Create storage pool from $($disks.Count) disk(s)")) {
            $subsystem = Get-StorageSubSystem | Select-Object -First 1
            New-StoragePool -FriendlyName $PoolName -StorageSubSystemUniqueId $subsystem.UniqueId -PhysicalDisks $disks | Out-Null
            Write-Status "Storage pool '$PoolName' created with $($disks.Count) disk(s)." 'SUCCESS'
        }
    }

    'ListVirtualDisks' {
        if (-not $PoolName) { throw "-PoolName required." }
        $pool = Get-Pool
        $vDisks = $pool | Get-VirtualDisk
        if (-not $vDisks) { Write-Status "No virtual disks in pool '$PoolName'." 'WARN'; return }
        $vDisks | Select-Object FriendlyName, OperationalStatus, HealthStatus,
            ResiliencySettingName,
            @{N='Size(GB)';E={[math]::Round($_.Size/1GB,1)}},
            NumberOfColumns | Format-Table -AutoSize
    }

    'CreateVirtualDisk' {
        if (-not $PoolName)        { throw "-PoolName required." }
        if (-not $VirtualDiskName) { throw "-VirtualDiskName required." }
        $pool = Get-Pool
        $vdParams = @{
            StoragePool          = $pool
            FriendlyName         = $VirtualDiskName
            ResiliencySettingName = $ResiliencyType
            ProvisioningType     = 'Fixed'
        }
        if ($SizeGB -gt 0) {
            $vdParams['Size'] = [long]($SizeGB * 1GB)
        } else {
            $vdParams['UseMaximumSize'] = $true
        }
        if ($NumberOfColumns -gt 0) { $vdParams['NumberOfColumns'] = $NumberOfColumns }
        $sizeStr = if ($SizeGB -gt 0) { "${SizeGB} GB" } else { 'maximum size' }
        if ($PSCmdlet.ShouldProcess($VirtualDiskName, "Create $ResiliencyType virtual disk ($sizeStr) in pool '$PoolName'")) {
            New-VirtualDisk @vdParams | Out-Null
            Write-Status "Virtual disk '$VirtualDiskName' created ($ResiliencyType, $sizeStr) in pool '$PoolName'." 'SUCCESS'
            Write-Status "Use Manage-DiskPartitions.ps1 to initialize and format the new virtual disk."
        }
    }

    'GetPoolStatus' {
        if (-not $PoolName) { throw "-PoolName required." }
        $pool = Get-Pool
        $pool | Format-List FriendlyName, OperationalStatus, HealthStatus,
            @{N='TotalSize(GB)';E={[math]::Round($_.Size/1GB,1)}},
            @{N='AllocatedSize(GB)';E={[math]::Round($_.AllocatedSize/1GB,1)}}
        Write-Host "`n  Physical Disks:"
        $pool | Get-PhysicalDisk | Select-Object FriendlyName, MediaType,
            @{N='Size(GB)';E={[math]::Round($_.Size/1GB,1)}},
            HealthStatus, OperationalStatus | Format-Table -AutoSize
        Write-Host "`n  Virtual Disks:"
        $pool | Get-VirtualDisk | Select-Object FriendlyName, ResiliencySettingName,
            @{N='Size(GB)';E={[math]::Round($_.Size/1GB,1)}},
            HealthStatus, OperationalStatus | Format-Table -AutoSize
    }

    'RemoveVirtualDisk' {
        if (-not $PoolName)        { throw "-PoolName required." }
        if (-not $VirtualDiskName) { throw "-VirtualDiskName required." }
        $pool = Get-Pool
        $vdisk = $pool | Get-VirtualDisk | Where-Object { $_.FriendlyName -eq $VirtualDiskName }
        if (-not $vdisk) { throw "Virtual disk '$VirtualDiskName' not found in pool '$PoolName'." }
        Write-Status "Removing virtual disk '$VirtualDiskName'. All data will be lost." 'WARN'
        if ($PSCmdlet.ShouldProcess($VirtualDiskName, 'Remove virtual disk')) {
            $vdisk | Remove-VirtualDisk -Confirm:$false
            Write-Status "Virtual disk '$VirtualDiskName' removed." 'SUCCESS'
        }
    }

    'RemovePool' {
        if (-not $PoolName) { throw "-PoolName required." }
        $pool = Get-Pool
        $vdisks = $pool | Get-VirtualDisk
        if ($vdisks) { throw "Pool '$PoolName' still has virtual disks. Remove them first." }
        Write-Status "Removing storage pool '$PoolName'. Physical disks will be returned to available state." 'WARN'
        if ($PSCmdlet.ShouldProcess($PoolName, 'Remove storage pool')) {
            $pool | Remove-StoragePool -Confirm:$false
            Write-Status "Storage pool '$PoolName' removed." 'SUCCESS'
        }
    }
}
