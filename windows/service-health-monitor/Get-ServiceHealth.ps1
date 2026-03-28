#Requires -Version 5.1
<#
.SYNOPSIS
    Monitor Windows services and alert when expected services are stopped or failed.
.DESCRIPTION
    Checks auto-start services (or a specific watch list) on local or remote hosts.
    Stopped services trigger an ALERT entry in the log and Event Log. The AutoRestart
    action will attempt to restart stopped services and log the outcome.
.PARAMETER Action
    Check       — Report service states; alert on any stopped auto-start services.
    AutoRestart — Check and attempt to restart any stopped services in WatchServices.
    List        — List all services and their current state.
.PARAMETER ComputerName
    One or more target computers. Defaults to the local machine.
.PARAMETER WatchServices
    Service names to monitor. If empty, all auto-start services are checked.
.PARAMETER LocalLogPath
    Local directory for log files.
.PARAMETER NetworkLogPath
    UNC path to write a full log copy to a network share.
.PARAMETER AlertLogPath
    UNC path to write alert-only entries.
.NOTES
    See README.md for usage and scheduling examples.
    Requires the shared Write-Log module at ..\shared\Write-Log.ps1
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Check','AutoRestart','List')]
    [string]$Action,

    [Parameter()]
    [string[]]$ComputerName = @($env:COMPUTERNAME),

    [Parameter()]
    [string[]]$WatchServices = @(),

    [Parameter()]
    [string]$LocalLogPath   = "$env:SystemDrive\Logs\SysAdmin",

    [Parameter()]
    [string]$NetworkLogPath = '',

    [Parameter()]
    [string]$AlertLogPath   = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Get-ServiceHealth' `
    -LocalLogPath   $LocalLogPath `
    -NetworkLogPath $NetworkLogPath `
    -AlertLogPath   $AlertLogPath

$alertCount   = 0
$restartCount = 0
$results      = [System.Collections.Generic.List[PSObject]]::new()

foreach ($computer in $ComputerName) {
    Write-Log "Checking services on: $computer"
    try {
        $services = Get-CimInstance Win32_Service `
            -ComputerName $computer `
            -Filter "StartMode='Auto'" `
            -ErrorAction Stop

        if ($WatchServices.Count -gt 0) {
            $services = $services | Where-Object { $_.Name -in $WatchServices }
        }

        foreach ($svc in $services) {
            $isDown = $svc.State -ne 'Running'
            $level  = if ($isDown) { $alertCount++; 'ALERT' } else { 'INFO' }
            $msg    = "$computer | $($svc.Name) ($($svc.DisplayName)) — $($svc.State)"

            Write-Log $msg $level

            $results.Add([PSCustomObject]@{
                Computer    = $computer
                Name        = $svc.Name
                DisplayName = $svc.DisplayName
                State       = $svc.State
                StartMode   = $svc.StartMode
            })

            if ($isDown -and $Action -eq 'AutoRestart') {
                if ($PSCmdlet.ShouldProcess("$computer\$($svc.Name)", 'Restart service')) {
                    try {
                        Write-Log "Attempting restart of '$($svc.Name)' on $computer..." 'WARN'
                        Invoke-CimMethod -InputObject $svc -MethodName StartService -ErrorAction Stop | Out-Null
                        $restartCount++
                        Write-Log "'$($svc.Name)' restarted successfully on $computer." 'SUCCESS'
                    } catch {
                        Write-Log "Failed to restart '$($svc.Name)' on ${computer}: $($_.Exception.Message)" 'ERROR'
                    }
                }
            }
        }
    } catch {
        Write-Log "Failed to query services on ${computer}: $($_.Exception.Message)" 'ERROR'
    }
}

Write-Log "Scan complete — $($results.Count) service(s) checked, $alertCount down, $restartCount restarted."

if ($Action -eq 'List') {
    Write-Host "`n=== Service Health Report ===" -ForegroundColor White
    $results | Sort-Object Computer, State | Format-Table -AutoSize
}

Close-Log -ExitCode $(if ($alertCount -gt 0) { 1 } else { 0 })
