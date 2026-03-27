#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Hyper-V virtual machines: start, stop, checkpoint, restore, and list.
.NOTES
    Requires Hyper-V PowerShell module. See README.md for prerequisites.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('ListVMs','Start','Stop','Restart','Suspend','Resume','Checkpoint','ListCheckpoints','RestoreCheckpoint','DeleteCheckpoint','GetInfo')]
    [string]$Action,

    [Parameter()] [string]$VMName,
    [Parameter()] [string]$CheckpointName,
    [Parameter()] [switch]$Force,
    [Parameter()] [string]$ComputerName = $env:COMPUTERNAME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

if (-not (Get-Module -ListAvailable Hyper-V)) {
    throw "Hyper-V PowerShell module not found. See README.md for prerequisites."
}

$hvParams = @{ ComputerName = $ComputerName }

function Get-VM-Safe {
    $vm = Get-VM -Name $VMName @hvParams -ErrorAction SilentlyContinue
    if (-not $vm) { throw "VM '$VMName' not found on $ComputerName." }
    return $vm
}

switch ($Action) {

    'ListVMs' {
        Write-Status "Virtual machines on $ComputerName:"
        Get-VM @hvParams | Select-Object Name, State, CPUUsage,
            @{N='Mem(MB)';E={[math]::Round($_.MemoryAssigned / 1MB)}},
            Uptime, Version | Format-Table -AutoSize
    }

    'GetInfo' {
        if (-not $VMName) { throw "-VMName required." }
        $vm = Get-VM-Safe
        $vm | Format-List Name, State, Path, Generation, Version, ProcessorCount,
            MemoryStartup, MemoryMinimum, MemoryMaximum, DynamicMemoryEnabled, Uptime
        Write-Host "`n  Network Adapters:"
        Get-VMNetworkAdapter -VMName $VMName @hvParams | Select-Object Name, SwitchName, MacAddress, IPAddresses | Format-Table -AutoSize
        Write-Host "`n  Hard Drives:"
        Get-VMHardDiskDrive -VMName $VMName @hvParams | Select-Object Name, Path, ControllerType, ControllerNumber | Format-Table -AutoSize
    }

    'Start' {
        if (-not $VMName) { throw "-VMName required." }
        $vm = Get-VM-Safe
        if ($vm.State -eq 'Running') { Write-Status "VM '$VMName' is already running." 'WARN'; return }
        if ($PSCmdlet.ShouldProcess($VMName, 'Start VM')) {
            Start-VM -Name $VMName @hvParams
            Write-Status "VM '$VMName' started." 'SUCCESS'
        }
    }

    'Stop' {
        if (-not $VMName) { throw "-VMName required." }
        Get-VM-Safe | Out-Null
        $stopParams = $hvParams.Clone()
        if ($Force) {
            $stopParams['TurnOff'] = $true
            Write-Status "Force-stopping VM '$VMName' (no graceful shutdown)..." 'WARN'
        } else {
            Write-Status "Stopping VM '$VMName' (graceful shutdown)..."
        }
        if ($PSCmdlet.ShouldProcess($VMName, 'Stop VM')) {
            Stop-VM -Name $VMName @stopParams
            Write-Status "VM '$VMName' stopped." 'SUCCESS'
        }
    }

    'Restart' {
        if (-not $VMName) { throw "-VMName required." }
        if ($PSCmdlet.ShouldProcess($VMName, 'Restart VM')) {
            Restart-VM -Name $VMName @hvParams -Force:$Force
            Write-Status "VM '$VMName' restarted." 'SUCCESS'
        }
    }

    'Suspend' {
        if (-not $VMName) { throw "-VMName required." }
        if ($PSCmdlet.ShouldProcess($VMName, 'Suspend VM (save state)')) {
            Suspend-VM -Name $VMName @hvParams
            Write-Status "VM '$VMName' suspended (saved state)." 'SUCCESS'
        }
    }

    'Resume' {
        if (-not $VMName) { throw "-VMName required." }
        if ($PSCmdlet.ShouldProcess($VMName, 'Resume VM')) {
            Resume-VM -Name $VMName @hvParams
            Write-Status "VM '$VMName' resumed." 'SUCCESS'
        }
    }

    'Checkpoint' {
        if (-not $VMName)         { throw "-VMName required." }
        if (-not $CheckpointName) { throw "-CheckpointName required." }
        if ($PSCmdlet.ShouldProcess($VMName, "Create checkpoint '$CheckpointName'")) {
            Checkpoint-VM -Name $VMName @hvParams -SnapshotName $CheckpointName
            Write-Status "Checkpoint '$CheckpointName' created for VM '$VMName'." 'SUCCESS'
        }
    }

    'ListCheckpoints' {
        if (-not $VMName) { throw "-VMName required." }
        Get-VMSnapshot -VMName $VMName @hvParams |
            Select-Object Name, CreationTime, SnapshotType, ParentSnapshotName |
            Sort-Object CreationTime | Format-Table -AutoSize
    }

    'RestoreCheckpoint' {
        if (-not $VMName)         { throw "-VMName required." }
        if (-not $CheckpointName) { throw "-CheckpointName required." }
        Write-Status "Restoring checkpoint '$CheckpointName'. VM will revert to that state." 'WARN'
        if ($PSCmdlet.ShouldProcess($VMName, "Restore checkpoint '$CheckpointName'")) {
            $snap = Get-VMSnapshot -VMName $VMName @hvParams | Where-Object { $_.Name -eq $CheckpointName }
            if (-not $snap) { throw "Checkpoint '$CheckpointName' not found." }
            Restore-VMSnapshot -VMSnapshot $snap -Confirm:$false
            Write-Status "Checkpoint '$CheckpointName' restored." 'SUCCESS'
        }
    }

    'DeleteCheckpoint' {
        if (-not $VMName)         { throw "-VMName required." }
        if (-not $CheckpointName) { throw "-CheckpointName required." }
        if ($PSCmdlet.ShouldProcess($VMName, "Delete checkpoint '$CheckpointName'")) {
            Remove-VMSnapshot -VMName $VMName @hvParams -Name $CheckpointName
            Write-Status "Checkpoint '$CheckpointName' deleted." 'SUCCESS'
        }
    }
}
