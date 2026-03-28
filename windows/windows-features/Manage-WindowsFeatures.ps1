#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Enable, disable, and list Windows features. Supports both Server and Desktop OS.
.NOTES
    See README.md for feature name reference and usage examples.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','ListEnabled','Status','Enable','Disable')]
    [string]$Action,

    [Parameter()] [string]$FeatureName,
    [Parameter()] [switch]$IncludeAllSubFeature
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-WindowsFeatures'

# Detect OS type: Server has Get-WindowsFeature, Desktop uses Get-WindowsOptionalFeature
$isServer = $null -ne (Get-Command Get-WindowsFeature -ErrorAction SilentlyContinue)
Write-Status "Detected OS type: $(if ($isServer) { 'Server' } else { 'Desktop/Workstation' })"

switch ($Action) {

    'List' {
        if ($isServer) {
            Get-WindowsFeature | Select-Object Name, DisplayName, Installed, InstallState |
                Format-Table -AutoSize
        } else {
            Get-WindowsOptionalFeature -Online |
                Select-Object FeatureName, State | Sort-Object FeatureName | Format-Table -AutoSize
        }
    }

    'ListEnabled' {
        if ($isServer) {
            Get-WindowsFeature | Where-Object { $_.Installed } |
                Select-Object Name, DisplayName | Format-Table -AutoSize
        } else {
            Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' } |
                Select-Object FeatureName, State | Format-Table -AutoSize
        }
    }

    'Status' {
        if (-not $FeatureName) { throw "-FeatureName required." }
        if ($isServer) {
            $f = Get-WindowsFeature -Name $FeatureName -ErrorAction Stop
            $f | Select-Object Name, DisplayName, Description, Installed, InstallState | Format-List
        } else {
            $f = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName -ErrorAction Stop
            $f | Select-Object FeatureName, State, Description | Format-List
        }
    }

    'Enable' {
        if (-not $FeatureName) { throw "-FeatureName required." }
        if ($PSCmdlet.ShouldProcess($FeatureName, 'Enable Windows feature')) {
            Write-Status "Enabling feature: $FeatureName..."
            if ($isServer) {
                $result = Install-WindowsFeature -Name $FeatureName `
                    -IncludeAllSubFeature:$IncludeAllSubFeature `
                    -IncludeManagementTools
                if ($result.Success) {
                    Write-Status "Feature '$FeatureName' enabled." 'SUCCESS'
                    if ($result.RestartNeeded -eq 'Yes') {
                        Write-Status "A REBOOT is required to complete the installation." 'WARN'
                    }
                } else {
                    Write-Status "Feature installation failed." 'ERROR'
                }
            } else {
                $result = Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart
                Write-Status "Feature '$FeatureName' enabled." 'SUCCESS'
                if ($result.RestartNeeded) {
                    Write-Status "A REBOOT is required to complete the installation." 'WARN'
                }
            }
        }
    }

    'Disable' {
        if (-not $FeatureName) { throw "-FeatureName required." }
        if ($PSCmdlet.ShouldProcess($FeatureName, 'Disable Windows feature')) {
            Write-Status "Disabling feature: $FeatureName..." 'WARN'
            if ($isServer) {
                $result = Uninstall-WindowsFeature -Name $FeatureName
                Write-Status "Feature '$FeatureName' disabled." 'SUCCESS'
                if ($result.RestartNeeded -eq 'Yes') {
                    Write-Status "A REBOOT is required to complete the removal." 'WARN'
                }
            } else {
                $result = Disable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart
                Write-Status "Feature '$FeatureName' disabled." 'SUCCESS'
                if ($result.RestartNeeded) {
                    Write-Status "A REBOOT is required." 'WARN'
                }
            }
        }
    }
}
Close-Log
