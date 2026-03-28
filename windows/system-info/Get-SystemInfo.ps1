<#
.SYNOPSIS
    Retrieve comprehensive system information: OS, hardware, BIOS, software, drivers, hotfixes.
.NOTES
    See README.md for usage. Does not require elevated privileges for most actions.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('All','OS','Hardware','BIOS','Software','Drivers','Hotfixes')]
    [string]$Action,

    [Parameter()] [string]$ExportPath,
    [Parameter()] [string]$ComputerName = $env:COMPUTERNAME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Get-SystemInfo'

$cimParams = @{}
if ($ComputerName -ne $env:COMPUTERNAME) { $cimParams['ComputerName'] = $ComputerName }

$output = [System.Text.StringBuilder]::new()

function Write-Section {
    param([string]$Title)
    $line = "=" * 60
    Write-Host "`n$line" -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host "$line" -ForegroundColor Cyan
    [void]$output.AppendLine("`n$line`n $Title`n$line")
}

function Write-Out {
    param([string]$Text)
    Write-Host $Text
    [void]$output.AppendLine($Text)
}

function Get-OSInfo {
    Write-Section "Operating System"
    $os   = Get-CimInstance Win32_OperatingSystem @cimParams
    $comp = Get-CimInstance Win32_ComputerSystem  @cimParams
    $info = [ordered]@{
        'Computer Name'    = $comp.Name
        'Domain/Workgroup' = if ($comp.PartOfDomain) { $comp.Domain } else { "$($comp.Workgroup) (Workgroup)" }
        'OS'               = $os.Caption
        'Version'          = $os.Version
        'Build'            = $os.BuildNumber
        'Architecture'     = $os.OSArchitecture
        'Install Date'     = $os.InstallDate.ToString('yyyy-MM-dd')
        'Last Boot'        = $os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm:ss')
        'Uptime'           = (Get-Date) - $os.LastBootUpTime | ForEach-Object { "$($_.Days)d $($_.Hours)h $($_.Minutes)m" }
        'System Drive'     = $os.SystemDrive
        'Windows Dir'      = $os.WindowsDirectory
    }
    $info.GetEnumerator() | ForEach-Object { Write-Out ("  {0,-20} {1}" -f "$($_.Key):", $_.Value) }
}

function Get-HardwareInfo {
    Write-Section "Hardware"
    $cpu  = Get-CimInstance Win32_Processor @cimParams | Select-Object -First 1
    $mem  = Get-CimInstance Win32_PhysicalMemory @cimParams
    $comp = Get-CimInstance Win32_ComputerSystem @cimParams
    $totalMem = [math]::Round(($mem | Measure-Object -Property Capacity -Sum).Sum / 1GB, 1)
    Write-Out "  CPU:         $($cpu.Name)"
    Write-Out "  Cores:       $($cpu.NumberOfCores) physical / $($cpu.NumberOfLogicalProcessors) logical"
    Write-Out "  CPU Speed:   $($cpu.MaxClockSpeed) MHz"
    Write-Out "  Total RAM:   $totalMem GB ($($mem.Count) DIMM(s))"
    Write-Out "  Model:       $($comp.Manufacturer) $($comp.Model)"
    Write-Out ""
    Write-Out "  Memory Modules:"
    $mem | Select-Object Tag, Capacity, Speed, Manufacturer, PartNumber |
        Format-Table -AutoSize | Out-String | ForEach-Object { Write-Out $_ }
}

function Get-BIOSInfo {
    Write-Section "BIOS / UEFI"
    $bios = Get-CimInstance Win32_BIOS @cimParams
    $board = Get-CimInstance Win32_BaseBoard @cimParams
    Write-Out "  BIOS Vendor:   $($bios.Manufacturer)"
    Write-Out "  BIOS Version:  $($bios.SMBIOSBIOSVersion)"
    Write-Out "  BIOS Date:     $($bios.ReleaseDate.ToString('yyyy-MM-dd'))"
    Write-Out "  Serial Number: $($bios.SerialNumber)"
    Write-Out "  Motherboard:   $($board.Manufacturer) $($board.Product) (S/N: $($board.SerialNumber))"
}

function Get-SoftwareInfo {
    Write-Section "Installed Software"
    $regPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $sw = $regPaths | ForEach-Object {
        Get-ItemProperty $_ -ErrorAction SilentlyContinue
    } | Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
        Sort-Object DisplayName -Unique
    $sw | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Out $_ }
    Write-Out "  Total installed: $($sw.Count) applications"
}

function Get-DriversInfo {
    Write-Section "Installed Drivers"
    Get-CimInstance Win32_PnPSignedDriver @cimParams |
        Where-Object { $_.DeviceName } |
        Select-Object DeviceName, DriverVersion, DriverDate, Manufacturer, DeviceClass |
        Sort-Object DeviceClass, DeviceName |
        Format-Table -AutoSize | Out-String | ForEach-Object { Write-Out $_ }
}

function Get-HotfixInfo {
    Write-Section "Installed Hotfixes / Updates"
    Get-HotFix @cimParams |
        Select-Object HotFixID, Description, InstalledOn, InstalledBy |
        Sort-Object InstalledOn -Descending |
        Format-Table -AutoSize | Out-String | ForEach-Object { Write-Out $_ }
}

switch ($Action) {
    'OS'       { Get-OSInfo }
    'Hardware' { Get-HardwareInfo }
    'BIOS'     { Get-BIOSInfo }
    'Software' { Get-SoftwareInfo }
    'Drivers'  { Get-DriversInfo }
    'Hotfixes' { Get-HotfixInfo }
    'All' {
        Get-OSInfo
        Get-HardwareInfo
        Get-BIOSInfo
        Get-SoftwareInfo
        Get-DriversInfo
        Get-HotfixInfo
    }
}

if ($ExportPath) {
    $output.ToString() | Set-Content -Path $ExportPath -Encoding UTF8
    Write-Host "`n[SUCCESS] Report saved to: $ExportPath" -ForegroundColor Green
}
Close-Log
