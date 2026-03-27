#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Create, list, run, enable, disable, and remove Windows Scheduled Tasks.

.NOTES
    See README.md for usage examples and full parameter documentation.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Show','Create','Run','Enable','Disable','Remove')]
    [string]$Action,

    [Parameter()]
    [string]$TaskName,

    [Parameter()]
    [string]$TaskPath = '\',

    [Parameter()]
    [string]$ScriptPath,

    [Parameter()]
    [ValidateSet('Daily','Weekly','AtStartup','AtLogon','Once')]
    [string]$TriggerType,

    [Parameter()]
    [string]$TriggerTime,

    [Parameter()]
    [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')]
    [string]$TriggerDay = 'Monday',

    [Parameter()]
    [string]$RunAsUser = 'SYSTEM'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

switch ($Action) {

    'List' {
        Write-Status "Listing scheduled tasks in '$TaskPath'..."
        Get-ScheduledTask -TaskPath "$TaskPath*" -ErrorAction SilentlyContinue |
            Select-Object TaskName, TaskPath, State, @{N='LastRun';E={(Get-ScheduledTaskInfo $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue).LastRunTime}} |
            Format-Table -AutoSize
    }

    'Show' {
        if (-not $TaskName) { throw "-TaskName is required." }
        $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
        $info = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction SilentlyContinue
        $task | Format-List TaskName, TaskPath, Description, State
        Write-Host "  Actions:"
        $task.Actions | ForEach-Object { Write-Host "    Execute: $($_.Execute) $($_.Arguments)" }
        Write-Host "  Triggers:"
        $task.Triggers | ForEach-Object { Write-Host "    $($_.CimClass.CimClassName): $($_ | Format-List | Out-String)" }
        if ($info) {
            Write-Host "  Last Run Time:   $($info.LastRunTime)"
            Write-Host "  Last Result:     $($info.LastTaskResult)"
            Write-Host "  Next Run Time:   $($info.NextRunTime)"
        }
    }

    'Create' {
        if (-not $TaskName)    { throw "-TaskName is required." }
        if (-not $ScriptPath)  { throw "-ScriptPath is required." }
        if (-not $TriggerType) { throw "-TriggerType is required." }
        if (-not (Test-Path $ScriptPath)) {
            Write-Status "Warning: ScriptPath '$ScriptPath' does not exist yet." 'WARN'
        }

        # Build trigger
        $trigger = switch ($TriggerType) {
            'Daily' {
                if (-not $TriggerTime) { throw "-TriggerTime is required for Daily trigger." }
                New-ScheduledTaskTrigger -Daily -At $TriggerTime
            }
            'Weekly' {
                if (-not $TriggerTime) { throw "-TriggerTime is required for Weekly trigger." }
                New-ScheduledTaskTrigger -Weekly -DaysOfWeek $TriggerDay -At $TriggerTime
            }
            'Once' {
                if (-not $TriggerTime) { throw "-TriggerTime is required for Once trigger." }
                New-ScheduledTaskTrigger -Once -At $TriggerTime
            }
            'AtStartup' { New-ScheduledTaskTrigger -AtStartup }
            'AtLogon'   { New-ScheduledTaskTrigger -AtLogon }
        }

        # Build action — run PowerShell with the script
        $action = New-ScheduledTaskAction `
            -Execute 'powershell.exe' `
            -Argument "-NonInteractive -NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

        # Build principal
        $principal = if ($RunAsUser -eq 'SYSTEM') {
            New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount -RunLevel Highest
        } else {
            New-ScheduledTaskPrincipal -UserId $RunAsUser -LogonType InteractiveOrPassword -RunLevel Highest
        }

        $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 4) -RestartCount 1

        if ($PSCmdlet.ShouldProcess($TaskName, 'Create scheduled task')) {
            Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath `
                -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
            Write-Status "Task '$TaskName' created." 'SUCCESS'
        }
    }

    'Run' {
        if (-not $TaskName) { throw "-TaskName is required." }
        if ($PSCmdlet.ShouldProcess($TaskName, 'Run scheduled task now')) {
            Write-Status "Starting task '$TaskName'..."
            Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath
            Write-Status "Task '$TaskName' started." 'SUCCESS'
        }
    }

    'Enable' {
        if (-not $TaskName) { throw "-TaskName is required." }
        if ($PSCmdlet.ShouldProcess($TaskName, 'Enable scheduled task')) {
            Enable-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Out-Null
            Write-Status "Task '$TaskName' enabled." 'SUCCESS'
        }
    }

    'Disable' {
        if (-not $TaskName) { throw "-TaskName is required." }
        if ($PSCmdlet.ShouldProcess($TaskName, 'Disable scheduled task')) {
            Disable-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Out-Null
            Write-Status "Task '$TaskName' disabled." 'SUCCESS'
        }
    }

    'Remove' {
        if (-not $TaskName) { throw "-TaskName is required." }
        Write-Status "Removing task '$TaskName'..." 'WARN'
        if ($PSCmdlet.ShouldProcess($TaskName, 'Remove scheduled task')) {
            Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
            Write-Status "Task '$TaskName' removed." 'SUCCESS'
        }
    }
}
