#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Windows VSS Shadow Copies: list, create, delete, and mount snapshots.
.NOTES
    See README.md for usage examples.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Create','Delete','Mount','Dismount')]
    [string]$Action,

    [Parameter()]
    [string]$Drive = 'C:',

    [Parameter()]
    [string]$ShadowID,

    [Parameter()]
    [string]$MountPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-ShadowCopies'

# Normalize drive letter
$Drive = $Drive.TrimEnd('\').ToUpper()
if ($Drive -notmatch ':$') { $Drive += ':' }

switch ($Action) {

    'List' {
        Write-Status "Shadow copies for $Drive\:"
        $shadows = Get-CimInstance Win32_ShadowCopy | Where-Object { $_.VolumeName -like "*$Drive*" }
        if ($shadows.Count -eq 0) {
            Write-Status "No shadow copies found for $Drive" 'WARN'
        } else {
            $shadows | Select-Object @{N='ID';E={$_.ID}},
                @{N='Created';E={[Management.ManagementDateTimeConverter]::ToDateTime($_.InstallDate)}},
                @{N='Drive';E={$_.VolumeName}},
                ClientAccessible, Persistent |
                Format-Table -AutoSize
        }
    }

    'Create' {
        if ($PSCmdlet.ShouldProcess($Drive, 'Create shadow copy')) {
            Write-Status "Creating shadow copy of $Drive\..."
            $out = Invoke-CimMethod -ClassName Win32_ShadowCopy -MethodName Create -Arguments @{ Volume = "$Drive\" }
            if ($out.ReturnValue -eq 0) {
                Write-Status "Shadow copy created: $($out.ShadowID)" 'SUCCESS'
            } else {
                throw "Shadow copy creation failed (return value: $($out.ReturnValue))"
            }
        }
    }

    'Delete' {
        if (-not $ShadowID) { throw "-ShadowID is required for Delete." }
        $shadow = Get-CimInstance Win32_ShadowCopy | Where-Object { $_.ID -eq $ShadowID }
        if (-not $shadow) { throw "Shadow copy '$ShadowID' not found." }
        if ($PSCmdlet.ShouldProcess($ShadowID, 'Delete shadow copy')) {
            Write-Status "Deleting shadow copy $ShadowID..." 'WARN'
            Remove-CimInstance -InputObject $shadow
            Write-Status "Shadow copy deleted." 'SUCCESS'
        }
    }

    'Mount' {
        if (-not $ShadowID)  { throw "-ShadowID is required for Mount." }
        if (-not $MountPath) { throw "-MountPath is required for Mount." }
        $shadow = Get-CimInstance Win32_ShadowCopy | Where-Object { $_.ID -eq $ShadowID }
        if (-not $shadow) { throw "Shadow copy '$ShadowID' not found." }
        if (-not (Test-Path $MountPath)) {
            New-Item -ItemType Directory -Path $MountPath -Force | Out-Null
        }
        if ($PSCmdlet.ShouldProcess($MountPath, 'Mount shadow copy')) {
            Write-Status "Mounting shadow copy to $MountPath..."
            $deviceObject = $shadow.DeviceObject + '\'
            & cmd /c "mklink /d `"$MountPath`" `"$deviceObject`"" | Out-Null
            Write-Status "Mounted at: $MountPath" 'SUCCESS'
            Write-Status "Browse with Explorer or: Get-ChildItem '$MountPath'"
        }
    }

    'Dismount' {
        if (-not $MountPath) { throw "-MountPath is required for Dismount." }
        if ($PSCmdlet.ShouldProcess($MountPath, 'Dismount shadow copy')) {
            Write-Status "Dismounting $MountPath..."
            & cmd /c "rmdir `"$MountPath`"" | Out-Null
            Write-Status "Dismounted." 'SUCCESS'
        }
    }
}
Close-Log
