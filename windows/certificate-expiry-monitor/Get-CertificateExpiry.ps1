#Requires -Version 5.1
<#
.SYNOPSIS
    Scan Windows certificate stores for certificates approaching or past expiry.
.DESCRIPTION
    Scans one or all certificate stores in LocalMachine or CurrentUser and issues
    WARN entries for certs expiring within WarnDays, ALERT entries for certs
    expiring within AlertDays. Uses the shared Write-Log module for network logging.
.PARAMETER Action
    Check  — Scan and display expiring certificates.
    Export — Scan and export results to a CSV file.
.PARAMETER StoreLocation
    LocalMachine (default) or CurrentUser.
.PARAMETER StoreName
    Certificate store to scan (e.g. My, Root, CA). Use 'All' to scan every store.
.PARAMETER WarnDays
    Issue a WARN for certs expiring within this many days. Default: 60.
.PARAMETER AlertDays
    Issue an ALERT for certs expiring within this many days. Default: 14.
.PARAMETER ExportCsv
    Output CSV path (used with -Action Export).
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
    [ValidateSet('Check','Export')]
    [string]$Action,

    [Parameter()]
    [ValidateSet('LocalMachine','CurrentUser')]
    [string]$StoreLocation = 'LocalMachine',

    [Parameter()]
    [string]$StoreName = 'My',

    [Parameter()]
    [int]$WarnDays = 60,

    [Parameter()]
    [int]$AlertDays = 14,

    [Parameter()]
    [string]$ExportCsv = '',

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
Initialize-Log -ScriptName 'Get-CertificateExpiry' `
    -LocalLogPath   $LocalLogPath `
    -NetworkLogPath $NetworkLogPath `
    -AlertLogPath   $AlertLogPath

$now        = Get-Date
$alertCount = 0
$warnCount  = 0
$results    = [System.Collections.Generic.List[PSObject]]::new()

$storeNames = if ($StoreName -eq 'All') {
    [System.Security.Cryptography.X509Certificates.StoreName].GetEnumNames()
} else {
    @($StoreName)
}

Write-Log "Scanning $StoreLocation certificate stores: $($storeNames -join ', ')"
Write-Log "Thresholds — WARN: $WarnDays days, ALERT: $AlertDays days"

foreach ($store in $storeNames) {
    try {
        $certStore = [System.Security.Cryptography.X509Certificates.X509Store]::new(
            $store, $StoreLocation)
        $certStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
        $certs = @($certStore.Certificates | Where-Object { $_.NotAfter -gt $now })
        $certStore.Close()
    } catch {
        Write-Log "Cannot open store ${StoreLocation}\${store}: $($_.Exception.Message)" 'WARN'
        continue
    }

    foreach ($cert in $certs) {
        $daysLeft = [math]::Round(($cert.NotAfter - $now).TotalDays, 0)
        if ($daysLeft -gt $WarnDays) { continue }

        $subject = if ($cert.Subject) { $cert.Subject } else { '(no subject)' }
        $msg     = "[$store] $subject — expires $($cert.NotAfter.ToString('yyyy-MM-dd')) ($daysLeft days left)"

        $level = if ($daysLeft -le $AlertDays) {
            $alertCount++
            'ALERT'
        } else {
            $warnCount++
            'WARN'
        }

        Write-Log $msg $level

        $results.Add([PSCustomObject]@{
            StoreLocation = $StoreLocation
            Store         = $store
            Subject       = $subject
            Thumbprint    = $cert.Thumbprint
            Expiry        = $cert.NotAfter.ToString('yyyy-MM-dd')
            DaysLeft      = $daysLeft
            Level         = $level
        })
    }
}

if ($results.Count -eq 0) {
    Write-Log "No certificates expiring within $WarnDays days found." 'SUCCESS'
} else {
    Write-Log "Found $($results.Count) expiring certificate(s): $alertCount critical (<= $AlertDays days), $warnCount warning(s)."
    $results | Sort-Object DaysLeft | Format-Table -AutoSize
}

if ($Action -eq 'Export' -and $ExportCsv) {
    $results | Export-Csv -Path $ExportCsv -NoTypeInformation -Encoding UTF8
    Write-Log "Results exported to: $ExportCsv" 'SUCCESS'
}

Close-Log -ExitCode $(if ($alertCount -gt 0) { 2 } elseif ($warnCount -gt 0) { 1 } else { 0 })
