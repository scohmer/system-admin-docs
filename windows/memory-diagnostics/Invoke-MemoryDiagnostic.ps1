#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Run Windows Memory Diagnostic, check memory health, and view diagnostic results.
.NOTES
    See README.md for usage. ScheduleDiagnostic requires a reboot to run.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('GetMemoryInfo','ScheduleDiagnostic','GetResults','CheckErrors','GetPageFile')]
    [string]$Action,

    [Parameter()] [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

switch ($Action) {

    'GetMemoryInfo' {
        Write-Status "Memory modules:"
        $modules = Get-CimInstance Win32_PhysicalMemory
        $modules | Select-Object Tag,
            @{N='Capacity(GB)';E={[math]::Round($_.Capacity/1GB,1)}},
            Speed, Manufacturer, PartNumber, MemoryType, FormFactor |
            Format-Table -AutoSize

        $os = Get-CimInstance Win32_OperatingSystem
        $totalGB   = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $freeGB    = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
        $usedGB    = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1)
        $usedPct   = [math]::Round($usedGB / $totalGB * 100, 0)
        Write-Host ""
        Write-Status "Memory usage:"
        Write-Host "  Total:  $totalGB GB"
        Write-Host "  Used:   $usedGB GB ($usedPct%)"
        Write-Host "  Free:   $freeGB GB"
    }

    'ScheduleDiagnostic' {
        Write-Status "Windows Memory Diagnostic will run on next reboot." 'WARN'
        if ($PSCmdlet.ShouldProcess('Windows Memory Diagnostic', 'Schedule on next reboot')) {
            & mdsched.exe
            Write-Status "Memory diagnostic scheduled. Reboot the system to run it." 'SUCCESS'
        }
    }

    'GetResults' {
        Write-Status "Memory diagnostic results from Event Log:"
        $events = Get-WinEvent -FilterHashtable @{
            LogName   = 'System'
            Id        = 1201
            ProviderName = 'Microsoft-Windows-MemoryDiagnostics-Results'
        } -MaxEvents 10 -ErrorAction SilentlyContinue
        if (-not $events) {
            Write-Status "No memory diagnostic results found. Run ScheduleDiagnostic first." 'WARN'
        } else {
            $events | Select-Object TimeCreated, Id, Message | Format-List
        }
    }

    'CheckErrors' {
        Write-Status "Hardware memory error events (last 30 days):"
        $since = (Get-Date).AddDays(-30)
        $errors = Get-WinEvent -FilterHashtable @{
            LogName   = 'System'
            StartTime = $since
        } -ErrorAction SilentlyContinue |
            Where-Object { $_.ProviderName -match 'WHEA|mcupdate|edac' }
        if (-not $errors) {
            Write-Status "No hardware memory error events found in last 30 days." 'SUCCESS'
        } else {
            Write-Status "$($errors.Count) hardware error event(s) found!" 'ERROR'
            $errors | Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, Message |
                Format-List
        }
    }

    'GetPageFile' {
        Write-Status "Page file configuration:"
        Get-CimInstance Win32_PageFileUsage | Select-Object Name,
            @{N='AllocatedBase(MB)';E={$_.AllocatedBaseSize}},
            @{N='CurrentUsage(MB)';E={$_.CurrentUsage}},
            @{N='PeakUsage(MB)';E={$_.PeakUsage}} |
            Format-Table -AutoSize

        Write-Status "Virtual memory totals:"
        $os = Get-CimInstance Win32_OperatingSystem
        Write-Host "  Total Virtual Memory: $([math]::Round($os.TotalVirtualMemorySize/1MB,1)) GB"
        Write-Host "  Free Virtual Memory:  $([math]::Round($os.FreeVirtualMemory/1MB,1)) GB"
    }
}
