#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage disk partitions: list, initialize, create, format, extend, and assign letters.
.NOTES
    See README.md for usage examples and safety warnings.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('ListDisks','ListPartitions','Initialize','CreatePartition','FormatVolume','ExtendPartition','AssignLetter')]
    [string]$Action,

    [Parameter()] [int]$DiskNumber = -1,
    [Parameter()] [int]$PartitionNumber = -1,
    [Parameter()] [double]$SizeGB = 0,
    [Parameter()] [string]$DriveLetter,
    [Parameter()] [string]$AssignLetter,
    [Parameter()] [ValidateSet('NTFS','ReFS','FAT32')] [string]$FileSystem = 'NTFS',
    [Parameter()] [string]$Label = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-DiskPartitions'

function Get-FriendlySize {
    param([long]$Bytes)
    switch ($Bytes) {
        { $_ -ge 1TB } { '{0:N1} TB' -f ($_ / 1TB) }
        { $_ -ge 1GB } { '{0:N1} GB' -f ($_ / 1GB) }
        { $_ -ge 1MB } { '{0:N1} MB' -f ($_ / 1MB) }
        default        { "$Bytes bytes" }
    }
}

switch ($Action) {

    'ListDisks' {
        Get-Disk | Select-Object Number, FriendlyName, OperationalStatus, PartitionStyle,
            @{N='Size';E={Get-FriendlySize $_.Size}},
            @{N='Unallocated';E={Get-FriendlySize $_.LargestFreeExtent}},
            IsSystem, IsBoot |
            Format-Table -AutoSize
    }

    'ListPartitions' {
        if ($DiskNumber -lt 0) { throw "-DiskNumber required." }
        Get-Partition -DiskNumber $DiskNumber | Select-Object PartitionNumber,
            @{N='Size';E={Get-FriendlySize $_.Size}},
            DriveLetter, Type, IsSystem, IsActive |
            Format-Table -AutoSize
    }

    'Initialize' {
        if ($DiskNumber -lt 0) { throw "-DiskNumber required." }
        $disk = Get-Disk -Number $DiskNumber
        if ($disk.PartitionStyle -ne 'RAW') {
            Write-Status "Disk $DiskNumber already initialized as $($disk.PartitionStyle). Skipping." 'WARN'
            return
        }
        Write-Status "Initializing disk $DiskNumber as GPT. ALL DATA WILL BE LOST." 'WARN'
        if ($PSCmdlet.ShouldProcess("Disk $DiskNumber", 'Initialize as GPT')) {
            Initialize-Disk -Number $DiskNumber -PartitionStyle GPT
            Write-Status "Disk $DiskNumber initialized as GPT." 'SUCCESS'
        }
    }

    'CreatePartition' {
        if ($DiskNumber -lt 0) { throw "-DiskNumber required." }
        $params = @{ DiskNumber = $DiskNumber }
        if ($SizeGB -gt 0) {
            $params['Size'] = [long]($SizeGB * 1GB)
        } else {
            $params['UseMaximumSize'] = $true
        }
        if ($AssignLetter) { $params['DriveLetter'] = $AssignLetter }
        $sizeStr = if ($SizeGB -gt 0) { "${SizeGB} GB" } else { 'all available space' }
        if ($PSCmdlet.ShouldProcess("Disk $DiskNumber", "Create partition ($sizeStr)")) {
            $partition = New-Partition @params
            Write-Status "Partition created on Disk $DiskNumber$(if ($AssignLetter) { " as drive $AssignLetter:" })." 'SUCCESS'
            Write-Status "Run -Action FormatVolume -DriveLetter $AssignLetter to format."
        }
    }

    'FormatVolume' {
        if (-not $DriveLetter) { throw "-DriveLetter required." }
        $letter = $DriveLetter.TrimEnd(':').ToUpper()
        Write-Status "Formatting $letter`: as $FileSystem. All data will be erased." 'WARN'
        if ($PSCmdlet.ShouldProcess("$letter`:", "Format as $FileSystem")) {
            $formatParams = @{
                DriveLetter    = $letter
                FileSystem     = $FileSystem
                NewFileSystemLabel = $Label
                Confirm        = $false
                Force          = $true
            }
            Format-Volume @formatParams | Out-Null
            Write-Status "Volume $letter`: formatted as $FileSystem$(if ($Label) { " ($Label)" })." 'SUCCESS'
        }
    }

    'ExtendPartition' {
        if (-not $DriveLetter) { throw "-DriveLetter required." }
        $letter = $DriveLetter.TrimEnd(':').ToUpper()
        if ($PSCmdlet.ShouldProcess("$letter`:", 'Extend partition to maximum size')) {
            $partition = Get-Partition -DriveLetter $letter
            $max = ($partition | Get-PartitionSupportedSize).SizeMax
            Resize-Partition -DriveLetter $letter -Size $max
            Write-Status "Partition $letter`: extended to maximum size ($(Get-FriendlySize $max))." 'SUCCESS'
        }
    }

    'AssignLetter' {
        if ($DiskNumber -lt 0)      { throw "-DiskNumber required." }
        if ($PartitionNumber -lt 0) { throw "-PartitionNumber required." }
        if (-not $DriveLetter)      { throw "-DriveLetter required." }
        $letter = $DriveLetter.TrimEnd(':').ToUpper()
        if ($PSCmdlet.ShouldProcess("Disk $DiskNumber Partition $PartitionNumber", "Assign letter $letter")) {
            Set-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -NewDriveLetter $letter
            Write-Status "Drive letter $letter assigned to Disk $DiskNumber, Partition $PartitionNumber." 'SUCCESS'
        }
    }
}
Close-Log
