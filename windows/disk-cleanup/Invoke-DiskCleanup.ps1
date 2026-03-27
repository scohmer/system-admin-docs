#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Clean temporary files and report disk usage on Windows.

.NOTES
    See README.md for usage examples and full parameter documentation.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Report','CleanUserTemp','CleanSystemTemp','CleanWindowsUpdate','EmptyRecycleBin','All')]
    [string]$Action,

    [Parameter()]
    [string]$Drive = 'C'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'  # Keep going if individual file deletions fail

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

function Get-FriendlySize {
    param([long]$Bytes)
    switch ($Bytes) {
        { $_ -ge 1GB } { return '{0:N2} GB' -f ($_ / 1GB) }
        { $_ -ge 1MB } { return '{0:N2} MB' -f ($_ / 1MB) }
        { $_ -ge 1KB } { return '{0:N2} KB' -f ($_ / 1KB) }
        default        { return "$_ bytes" }
    }
}

function Get-DiskFreeSpace {
    $disk = Get-PSDrive -Name $Drive -ErrorAction SilentlyContinue
    if ($disk) { return $disk.Free } else { return 0 }
}

function Remove-DirectoryContents {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path $Path)) {
        Write-Status "$Label path not found: $Path" 'WARN'
        return 0
    }
    $before = (Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum
    Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    $after = (Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum
    $freed = [math]::Max(0, $before - $after)
    Write-Status "$Label — freed $(Get-FriendlySize $freed)" 'SUCCESS'
    return $freed
}

function Invoke-Report {
    Write-Status "Disk usage report for drive ${Drive}:\"
    $drive = Get-PSDrive -Name $Drive
    $total = $drive.Used + $drive.Free
    Write-Host ""
    Write-Host "  Drive:      ${Drive}:"
    Write-Host "  Total:      $(Get-FriendlySize $total)"
    Write-Host "  Used:       $(Get-FriendlySize $drive.Used)"
    Write-Host "  Free:       $(Get-FriendlySize $drive.Free)"
    Write-Host "  Free (%):   $([math]::Round(($drive.Free / $total) * 100, 1))%"
    Write-Host ""

    # Show largest temp directory sizes
    $tempPaths = @(
        @{ Label = 'User Temp (%TEMP%)';          Path = $env:TEMP },
        @{ Label = 'System Temp (Windows\Temp)';  Path = "$env:SystemRoot\Temp" },
        @{ Label = 'WU Download Cache';           Path = "$env:SystemRoot\SoftwareDistribution\Download" }
    )
    Write-Host "  Candidate cleanup locations:"
    foreach ($t in $tempPaths) {
        if (Test-Path $t.Path) {
            $size = (Get-ChildItem $t.Path -Recurse -Force -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum).Sum
            Write-Host ("  {0,-40} {1}" -f $t.Label, (Get-FriendlySize $size))
        }
    }
}

function Invoke-CleanUserTemp {
    Write-Status "Cleaning user temp files ($env:TEMP)..."
    Remove-DirectoryContents -Path $env:TEMP -Label 'User Temp'
}

function Invoke-CleanSystemTemp {
    Write-Status "Cleaning system temp files ($env:SystemRoot\Temp)..."
    Remove-DirectoryContents -Path "$env:SystemRoot\Temp" -Label 'System Temp'
}

function Invoke-CleanWindowsUpdate {
    Write-Status "Cleaning Windows Update download cache..." 'WARN'
    $wuPath = "$env:SystemRoot\SoftwareDistribution\Download"
    Write-Status "Stopping Windows Update service (wuauserv)..."
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Remove-DirectoryContents -Path $wuPath -Label 'WU Download Cache'
    Write-Status "Restarting Windows Update service..."
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    Write-Status "Windows Update service restarted." 'SUCCESS'
}

function Invoke-EmptyRecycleBin {
    Write-Status "Emptying Recycle Bin for all users..."
    if ($PSCmdlet.ShouldProcess('Recycle Bin', 'Empty')) {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Status "Recycle Bin emptied." 'SUCCESS'
    }
}

$freeBefore = Get-DiskFreeSpace

switch ($Action) {
    'Report'             { Invoke-Report }
    'CleanUserTemp'      { Invoke-CleanUserTemp }
    'CleanSystemTemp'    { Invoke-CleanSystemTemp }
    'CleanWindowsUpdate' { Invoke-CleanWindowsUpdate }
    'EmptyRecycleBin'    { Invoke-EmptyRecycleBin }
    'All' {
        Invoke-CleanUserTemp
        Invoke-CleanSystemTemp
        Invoke-CleanWindowsUpdate
        Invoke-EmptyRecycleBin
    }
}

if ($Action -ne 'Report') {
    $freeAfter = Get-DiskFreeSpace
    $totalFreed = [math]::Max(0, $freeAfter - $freeBefore)
    Write-Status "Total additional free space on ${Drive}: $(Get-FriendlySize $totalFreed)" 'SUCCESS'
    Invoke-Report
}
