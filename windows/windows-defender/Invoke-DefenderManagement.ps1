#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Windows Defender: status, scans, definition updates, and exclusions.
.NOTES
    See README.md for usage examples and exclusion guidance.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Status','QuickScan','FullScan','UpdateDefinitions','AddExclusion','RemoveExclusion','ListExclusions','GetThreats')]
    [string]$Action,

    [Parameter()]
    [string]$ExclusionPath,

    [Parameter()]
    [ValidateSet('Path','Extension','Process')]
    [string]$ExclusionType = 'Path'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Invoke-DefenderManagement'

switch ($Action) {

    'Status' {
        $status = Get-MpComputerStatus -ErrorAction Stop
        [PSCustomObject]@{
            'Antivirus Enabled'         = $status.AntivirusEnabled
            'Real-time Protection'       = $status.RealTimeProtectionEnabled
            'AM Service Enabled'        = $status.AMServiceEnabled
            'Signature Date'            = $status.AntivirusSignatureLastUpdated
            'Signature Version'         = $status.AntivirusSignatureVersion
            'Quick Scan Age (days)'     = $status.QuickScanAge
            'Full Scan Age (days)'      = $status.FullScanAge
            'Last Full Scan'            = $status.FullScanEndTime
            'Tamper Protection'         = $status.IsTamperProtected
        } | Format-List
    }

    'QuickScan' {
        Write-Status "Starting Quick Scan..."
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Run Defender Quick Scan')) {
            Start-MpScan -ScanType QuickScan
            Write-Status "Quick Scan started. Check Windows Security Center for results." 'SUCCESS'
        }
    }

    'FullScan' {
        Write-Status "Starting Full Scan (this will take a long time and impact performance)..." 'WARN'
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Run Defender Full Scan')) {
            Start-MpScan -ScanType FullScan
            Write-Status "Full Scan started. Check Windows Security Center for results." 'SUCCESS'
        }
    }

    'UpdateDefinitions' {
        Write-Status "Updating Windows Defender definitions..."
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Update Defender definitions')) {
            Update-MpSignature
            $status = Get-MpComputerStatus
            Write-Status "Definitions updated. Version: $($status.AntivirusSignatureVersion)" 'SUCCESS'
        }
    }

    'AddExclusion' {
        if (-not $ExclusionPath) { throw "-ExclusionPath required." }
        Write-Status "Adding $ExclusionType exclusion: $ExclusionPath" 'WARN'
        if ($PSCmdlet.ShouldProcess($ExclusionPath, "Add Defender $ExclusionType exclusion")) {
            switch ($ExclusionType) {
                'Path'      { Add-MpPreference -ExclusionPath $ExclusionPath }
                'Extension' { Add-MpPreference -ExclusionExtension $ExclusionPath }
                'Process'   { Add-MpPreference -ExclusionProcess $ExclusionPath }
            }
            Write-Status "Exclusion added: $ExclusionPath ($ExclusionType)" 'SUCCESS'
        }
    }

    'RemoveExclusion' {
        if (-not $ExclusionPath) { throw "-ExclusionPath required." }
        if ($PSCmdlet.ShouldProcess($ExclusionPath, "Remove Defender $ExclusionType exclusion")) {
            switch ($ExclusionType) {
                'Path'      { Remove-MpPreference -ExclusionPath $ExclusionPath }
                'Extension' { Remove-MpPreference -ExclusionExtension $ExclusionPath }
                'Process'   { Remove-MpPreference -ExclusionProcess $ExclusionPath }
            }
            Write-Status "Exclusion removed: $ExclusionPath" 'SUCCESS'
        }
    }

    'ListExclusions' {
        $prefs = Get-MpPreference
        Write-Host "`n  Path Exclusions:"
        $prefs.ExclusionPath      | ForEach-Object { Write-Host "    $_" }
        Write-Host "`n  Extension Exclusions:"
        $prefs.ExclusionExtension | ForEach-Object { Write-Host "    $_" }
        Write-Host "`n  Process Exclusions:"
        $prefs.ExclusionProcess   | ForEach-Object { Write-Host "    $_" }
    }

    'GetThreats' {
        Write-Status "Threat detection history:"
        $threats = Get-MpThreatDetection -ErrorAction SilentlyContinue
        if (-not $threats) {
            Write-Status "No threats detected in history." 'SUCCESS'
        } else {
            $threats | Select-Object @{N='Detected';E={$_.InitialDetectionTime}},
                ThreatName, ActionSuccess, CurrentThreatExecutionStatusID,
                @{N='Path';E={$_.Resources -join '; '}} |
                Sort-Object Detected -Descending | Format-Table -AutoSize -Wrap
        }
    }
}
Close-Log
