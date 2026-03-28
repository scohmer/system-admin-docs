#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Windows services: start, stop, restart, query status, and set startup type.

.NOTES
    See README.md for usage examples and full parameter documentation.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Status','Start','Stop','Restart','SetStartup','List')]
    [string]$Action,

    [Parameter()]
    [string]$ServiceName,

    [Parameter()]
    [ValidateSet('Automatic','Manual','Disabled','AutomaticDelayedStart')]
    [string]$StartupType,

    [Parameter()]
    [ValidateSet('Running','Stopped','')]
    [string]$StatusFilter = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-Services'

function Assert-ServiceName {
    if (-not $ServiceName) { throw "Parameter -ServiceName is required for action '$Action'." }
    # Verify the service exists
    if (-not (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
        throw "Service '$ServiceName' not found. Use -Action List to see available services."
    }
}

switch ($Action) {

    'Status' {
        Assert-ServiceName
        $svc = Get-Service -Name $ServiceName
        [PSCustomObject]@{
            Name        = $svc.Name
            DisplayName = $svc.DisplayName
            Status      = $svc.Status
            StartType   = $svc.StartType
        } | Format-List
    }

    'Start' {
        Assert-ServiceName
        $svc = Get-Service -Name $ServiceName
        if ($svc.Status -eq 'Running') {
            Write-Status "Service '$ServiceName' is already running." 'WARN'
        } else {
            if ($PSCmdlet.ShouldProcess($ServiceName, 'Start service')) {
                Write-Status "Starting service '$ServiceName'..."
                Start-Service -Name $ServiceName
                Write-Status "Service '$ServiceName' started." 'SUCCESS'
            }
        }
    }

    'Stop' {
        Assert-ServiceName
        $svc = Get-Service -Name $ServiceName
        if ($svc.Status -eq 'Stopped') {
            Write-Status "Service '$ServiceName' is already stopped." 'WARN'
        } else {
            if ($PSCmdlet.ShouldProcess($ServiceName, 'Stop service')) {
                Write-Status "Stopping service '$ServiceName'..."
                Stop-Service -Name $ServiceName -Force
                Write-Status "Service '$ServiceName' stopped." 'SUCCESS'
            }
        }
    }

    'Restart' {
        Assert-ServiceName
        if ($PSCmdlet.ShouldProcess($ServiceName, 'Restart service')) {
            Write-Status "Restarting service '$ServiceName'..."
            Restart-Service -Name $ServiceName -Force
            Write-Status "Service '$ServiceName' restarted." 'SUCCESS'
        }
    }

    'SetStartup' {
        Assert-ServiceName
        if (-not $StartupType) { throw "Parameter -StartupType is required for action 'SetStartup'." }
        if ($PSCmdlet.ShouldProcess($ServiceName, "Set startup type to '$StartupType'")) {
            Write-Status "Setting '$ServiceName' startup type to '$StartupType'..."
            Set-Service -Name $ServiceName -StartupType $StartupType
            Write-Status "Startup type updated." 'SUCCESS'
        }
    }

    'List' {
        Write-Log "Listing services$(if ($StatusFilter) { " with status: $StatusFilter" } else { '' })..."
        $services = Get-Service
        if ($StatusFilter) {
            $services = $services | Where-Object { $_.Status -eq $StatusFilter }
        }
        $services | Select-Object Name, DisplayName, Status, StartType |
            Sort-Object DisplayName | Format-Table -AutoSize
    }
}

Close-Log
