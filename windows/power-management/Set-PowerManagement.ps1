#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Windows power plans, sleep settings, and system shutdown/restart.
.NOTES
    Uses powercfg.exe for plan management. See README.md for usage.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('ListPlans','GetPlan','SetPlan','DisableSleep','SetSleepTimeout','SetHibernation','Shutdown','Restart')]
    [string]$Action,

    [Parameter()] [string]$PlanName,
    [Parameter()] [int]$ACTimeout = 0,
    [Parameter()] [int]$DCTimeout = 0,
    [Parameter()] [bool]$EnableHibernation = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Set-PowerManagement'

function Get-PowerPlans {
    # Parse powercfg /list output into objects
    $output = & powercfg /list 2>&1
    $plans  = $output | Select-String 'Power Scheme GUID' | ForEach-Object {
        if ($_.Line -match 'GUID: ([a-f0-9-]+)\s+\((.+?)\)\s*(\*?)') {
            [PSCustomObject]@{
                GUID   = $Matches[1]
                Name   = $Matches[2].Trim()
                Active = $Matches[3] -eq '*'
            }
        }
    }
    return $plans
}

switch ($Action) {

    'ListPlans' {
        Write-Status "Available power plans:"
        Get-PowerPlans | Select-Object GUID, Name, @{N='Active';E={if ($_.Active) {'*'} else {''}}} |
            Format-Table -AutoSize
    }

    'GetPlan' {
        $active = Get-PowerPlans | Where-Object { $_.Active }
        Write-Host "`n  Active Plan: $($active.Name)"
        Write-Host "  GUID:        $($active.GUID)`n"
        # Show current sleep settings
        Write-Host "  Sleep settings:"
        & powercfg /query $active.GUID SUB_SLEEP 2>&1 | Select-String 'AC Power|DC Power|Current AC|Current DC' |
            ForEach-Object { Write-Host "    $($_.Line.Trim())" }
    }

    'SetPlan' {
        if (-not $PlanName) { throw "-PlanName required." }
        $plan = Get-PowerPlans | Where-Object { $_.Name -like "*$PlanName*" } | Select-Object -First 1
        if (-not $plan) { throw "Power plan '$PlanName' not found. Use -Action ListPlans to see available plans." }
        if ($PSCmdlet.ShouldProcess($plan.Name, 'Set active power plan')) {
            & powercfg /setactive $plan.GUID
            Write-Status "Active power plan set to: $($plan.Name)" 'SUCCESS'
        }
    }

    'DisableSleep' {
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Disable sleep (AC and DC)')) {
            & powercfg /change standby-timeout-ac 0
            & powercfg /change standby-timeout-dc 0
            & powercfg /change monitor-timeout-ac 0
            & powercfg /change monitor-timeout-dc 0
            Write-Status "Sleep disabled (AC and DC). Monitor timeout disabled." 'SUCCESS'
        }
    }

    'SetSleepTimeout' {
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set sleep timeout AC=$ACTimeout DC=$DCTimeout")) {
            & powercfg /change standby-timeout-ac $ACTimeout
            & powercfg /change standby-timeout-dc $DCTimeout
            Write-Status "Sleep timeout set: AC=$ACTimeout min, DC=$DCTimeout min (0 = never)" 'SUCCESS'
        }
    }

    'SetHibernation' {
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "$(if ($EnableHibernation) {'Enable'} else {'Disable'}) hibernation")) {
            $arg = if ($EnableHibernation) { 'on' } else { 'off' }
            & powercfg /hibernate $arg
            Write-Status "Hibernation $(if ($EnableHibernation) { 'enabled' } else { 'disabled (hiberfil.sys removed)' })." 'SUCCESS'
        }
    }

    'Shutdown' {
        Write-Status "System will shut down in 60 seconds. Use 'shutdown /a' to abort." 'WARN'
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Shutdown in 60 seconds')) {
            & shutdown /s /t 60 /c "Scheduled shutdown initiated by Manage-PowerManagement.ps1"
            Write-Status "Shutdown initiated." 'SUCCESS'
        }
    }

    'Restart' {
        Write-Status "System will restart in 60 seconds. Use 'shutdown /a' to abort." 'WARN'
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Restart in 60 seconds')) {
            & shutdown /r /t 60 /c "Scheduled restart initiated by Manage-PowerManagement.ps1"
            Write-Status "Restart initiated." 'SUCCESS'
        }
    }
}
Close-Log
