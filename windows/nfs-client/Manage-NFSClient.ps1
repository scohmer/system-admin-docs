#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Enable the Windows NFS client and mount/unmount NFS shares.
.NOTES
    See README.md for prerequisites (NFS Client feature must be installed).
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Status','List','Mount','Unmount','GetConfig','SetAnonymousID')]
    [string]$Action,

    [Parameter()] [string]$NFSPath,
    [Parameter()] [string]$DriveLetter,
    [Parameter()] [int]$UID = -2,
    [Parameter()] [int]$GID = -2
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-NFSClient'

function Assert-NFSClient {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName ServicesForNFS-ClientOnly -ErrorAction SilentlyContinue
    if (-not $feature -or $feature.State -ne 'Enabled') {
        throw "NFS Client is not installed. See README.md for prerequisites."
    }
}

switch ($Action) {

    'Status' {
        Write-Status "NFS Client feature status:"
        $feature = Get-WindowsOptionalFeature -Online -FeatureName ServicesForNFS-ClientOnly -ErrorAction SilentlyContinue
        if ($feature) {
            Write-Host "  ServicesForNFS-ClientOnly: $($feature.State)"
        } else {
            $svcFeature = Get-WindowsFeature NFS-Client -ErrorAction SilentlyContinue
            if ($svcFeature) {
                Write-Host "  NFS-Client (Server): $($svcFeature.InstallState)"
            } else {
                Write-Status "NFS Client feature not found. Install it first." 'WARN'
            }
        }
        Write-Host ""
        Write-Status "NFS client service:"
        Get-Service NfsClnt -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType | Format-Table
    }

    'List' {
        Assert-NFSClient
        Write-Status "Mounted NFS shares:"
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot -match '^\\\\' -and $_.DisplayRoot -match ':' }
        if (-not $drives) {
            # Fall back to mount command output
            $mountOutput = mount
            if ($mountOutput) {
                Write-Host $mountOutput
            } else {
                Write-Status "No NFS shares currently mounted." 'WARN'
            }
        } else {
            $drives | Format-Table Name, DisplayRoot -AutoSize
        }
    }

    'Mount' {
        if (-not $NFSPath)    { throw "-NFSPath required (e.g., 192.168.1.10:/exports/data)." }
        if (-not $DriveLetter) { throw "-DriveLetter required." }
        Assert-NFSClient
        $letter = $DriveLetter.TrimEnd(':').ToUpper()
        if ($PSCmdlet.ShouldProcess("$letter`: -> $NFSPath", 'Mount NFS share')) {
            mount $NFSPath "${letter}:"
            Write-Status "NFS share $NFSPath mounted as ${letter}:." 'SUCCESS'
        }
    }

    'Unmount' {
        if (-not $DriveLetter) { throw "-DriveLetter required." }
        $letter = $DriveLetter.TrimEnd(':').ToUpper()
        if ($PSCmdlet.ShouldProcess("${letter}:", 'Unmount NFS share')) {
            umount "${letter}:"
            Write-Status "NFS share ${letter}: unmounted." 'SUCCESS'
        }
    }

    'GetConfig' {
        Assert-NFSClient
        Write-Status "NFS client configuration:"
        nfsadmin client
    }

    'SetAnonymousID' {
        Assert-NFSClient
        if ($PSCmdlet.ShouldProcess("NFS anonymous UID/GID", "Set to UID=$UID GID=$GID")) {
            nfsadmin client config anon=$UID anongid=$GID
            Write-Status "NFS anonymous UID set to $UID, GID set to $GID." 'SUCCESS'
        }
    }
}
Close-Log
