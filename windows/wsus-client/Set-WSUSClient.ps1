#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Configure the Windows Update client for WSUS server assignment and detection.
.NOTES
    See README.md for usage. Writes to HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('GetConfig','SetServer','SetTargetGroup','ForceDetection','ForceReport','Reset','RemoveServer')]
    [string]$Action,

    [Parameter()] [string]$WSUSServer,
    [Parameter()] [string]$TargetGroup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$wuRegPath   = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
$wuAuRegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Set-WSUSClient'

function Ensure-RegPath { param([string]$Path) if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null } }

switch ($Action) {

    'GetConfig' {
        Write-Status "Windows Update / WSUS registry configuration:"
        if (Test-Path $wuRegPath) {
            Get-ItemProperty $wuRegPath -ErrorAction SilentlyContinue | Format-List
        } else {
            Write-Status "No WSUS policy registry keys found. Client uses Windows Update directly." 'WARN'
        }
        Write-Host ""
        Write-Status "Windows Update service status:"
        Get-Service wuauserv | Select-Object Name, Status, StartType | Format-Table
        Write-Host ""
        Write-Status "Windows Update client info (wuauclt /detectnow output):"
        & wuauclt /resetauthorization /detectnow
        Write-Status "Detection requested. Check Windows Update status in a few minutes."
    }

    'SetServer' {
        if (-not $WSUSServer) { throw "-WSUSServer required (e.g., http://wsus.corp.local:8530)." }
        if ($PSCmdlet.ShouldProcess($WSUSServer, 'Set WSUS server')) {
            Ensure-RegPath $wuRegPath
            Ensure-RegPath $wuAuRegPath
            Set-ItemProperty -Path $wuRegPath   -Name 'WUServer'          -Value $WSUSServer
            Set-ItemProperty -Path $wuRegPath   -Name 'WUStatusServer'    -Value $WSUSServer
            Set-ItemProperty -Path $wuAuRegPath -Name 'UseWUServer'       -Value 1 -Type DWord
            Write-Status "WSUS server set to: $WSUSServer" 'SUCCESS'
            Write-Status "Run -Action ForceDetection to check in immediately."
        }
    }

    'SetTargetGroup' {
        if (-not $TargetGroup) { throw "-TargetGroup required." }
        if ($PSCmdlet.ShouldProcess($TargetGroup, 'Set WSUS target group')) {
            Ensure-RegPath $wuRegPath
            Set-ItemProperty -Path $wuRegPath -Name 'TargetGroup'          -Value $TargetGroup
            Set-ItemProperty -Path $wuRegPath -Name 'TargetGroupEnabled'   -Value 1 -Type DWord
            Write-Status "WSUS target group set to: $TargetGroup" 'SUCCESS'
        }
    }

    'ForceDetection' {
        if ($PSCmdlet.ShouldProcess('Windows Update', 'Force detection')) {
            & wuauclt /resetauthorization /detectnow
            Write-Status "Detection cycle triggered. Results will appear in Windows Update in a few minutes." 'SUCCESS'
        }
    }

    'ForceReport' {
        if ($PSCmdlet.ShouldProcess('Windows Update', 'Force report to WSUS')) {
            & wuauclt /reportnow
            Write-Status "Reporting triggered. Client status should update in WSUS within a few minutes." 'SUCCESS'
        }
    }

    'Reset' {
        Write-Status "Resetting WSUS client registration. The client will re-register with WSUS." 'WARN'
        if ($PSCmdlet.ShouldProcess('WSUS client', 'Reset registration')) {
            Stop-Service wuauserv -Force
            if (Test-Path $wuRegPath) {
                Remove-ItemProperty -Path $wuRegPath -Name 'SUSClientId'          -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $wuRegPath -Name 'SUSClientIDValidation' -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $wuRegPath -Name 'AccountDomainSid'      -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $wuRegPath -Name 'PingID'                -ErrorAction SilentlyContinue
            }
            Start-Service wuauserv
            & wuauclt /resetauthorization /detectnow
            Write-Status "WSUS client reset. The client will re-register on next detection cycle." 'SUCCESS'
        }
    }

    'RemoveServer' {
        Write-Status "Removing WSUS configuration. Client will revert to Windows Update." 'WARN'
        if ($PSCmdlet.ShouldProcess('WSUS configuration', 'Remove')) {
            if (Test-Path $wuAuRegPath) {
                Remove-ItemProperty -Path $wuAuRegPath -Name 'UseWUServer' -ErrorAction SilentlyContinue
            }
            if (Test-Path $wuRegPath) {
                Remove-ItemProperty -Path $wuRegPath -Name 'WUServer'       -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $wuRegPath -Name 'WUStatusServer' -ErrorAction SilentlyContinue
            }
            Restart-Service wuauserv -Force
            Write-Status "WSUS configuration removed. Client will use Windows Update directly." 'SUCCESS'
        }
    }
}
Close-Log
