#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Map, list, and remove network drive mappings.
.NOTES
    See README.md for usage examples and notes on UAC drive isolation.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Map','Remove','Test','RemoveAll')]
    [string]$Action,

    [Parameter()] [string]$DriveLetter,
    [Parameter()] [string]$UNCPath,
    [Parameter()] [string]$UserName,
    [Parameter()] [bool]$Persistent = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-NetworkDrives'

switch ($Action) {

    'List' {
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot -like '\\*' }
        if (-not $drives) {
            Write-Status "No network drives currently mapped." 'WARN'
        } else {
            $drives | Select-Object Name,
                @{N='UNCPath';E={$_.DisplayRoot}},
                @{N='Used(GB)';E={if ($_.Used) { [math]::Round($_.Used/1GB,1) } else { 'N/A' }}},
                @{N='Free(GB)';E={if ($_.Free) { [math]::Round($_.Free/1GB,1) } else { 'N/A' }}} |
                Format-Table -AutoSize
        }
    }

    'Map' {
        if (-not $DriveLetter) { throw "-DriveLetter required." }
        if (-not $UNCPath)     { throw "-UNCPath required." }
        $letter = $DriveLetter.TrimEnd(':').ToUpper()
        if ($PSCmdlet.ShouldProcess("$letter`: -> $UNCPath", 'Map network drive')) {
            $mapParams = @{
                Name       = $letter
                PSProvider = 'FileSystem'
                Root       = $UNCPath
                Persist    = $Persistent
                Scope      = 'Global'
            }
            if ($UserName) {
                $cred = Get-Credential -UserName $UserName -Message "Password for $UNCPath"
                $mapParams['Credential'] = $cred
            }
            New-PSDrive @mapParams | Out-Null
            Write-Status "Drive $letter`: mapped to $UNCPath$(if ($Persistent) { ' (persistent)' })." 'SUCCESS'
        }
    }

    'Remove' {
        if (-not $DriveLetter) { throw "-DriveLetter required." }
        $letter = $DriveLetter.TrimEnd(':').ToUpper()
        $drive = Get-PSDrive -Name $letter -ErrorAction SilentlyContinue
        if (-not $drive) { throw "Drive $letter`: is not mapped." }
        if ($PSCmdlet.ShouldProcess("$letter`:", 'Remove network drive mapping')) {
            Remove-PSDrive -Name $letter -Force
            Write-Status "Drive $letter`: removed." 'SUCCESS'
        }
    }

    'Test' {
        if (-not $UNCPath) { throw "-UNCPath required." }
        Write-Status "Testing connectivity to $UNCPath..."
        if (Test-Path $UNCPath) {
            Write-Status "Path $UNCPath is accessible." 'SUCCESS'
        } else {
            Write-Status "Path $UNCPath is NOT accessible." 'ERROR'
        }
    }

    'RemoveAll' {
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot -like '\\*' }
        if (-not $drives) { Write-Status "No network drives to remove." 'WARN'; return }
        if ($PSCmdlet.ShouldProcess("All mapped network drives ($($drives.Name -join ', '))", 'Remove all')) {
            $drives | Remove-PSDrive -Force
            Write-Status "All network drives removed." 'SUCCESS'
        }
    }
}
Close-Log
