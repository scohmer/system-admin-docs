#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Windows printers: list, add, remove, set default, and manage print queues.
.NOTES
    See README.md for usage examples.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Add','Remove','SetDefault','GetQueue','ClearQueue','ListDrivers')]
    [string]$Action,

    [Parameter()] [string]$PrinterName,
    [Parameter()] [string]$PortAddress,
    [Parameter()] [string]$DriverName
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
        Write-Status "Installed printers on $env:COMPUTERNAME:"
        Get-Printer | Select-Object Name, DriverName, PortName, Shared, Published, PrinterStatus |
            Format-Table -AutoSize
    }

    'ListDrivers' {
        Write-Status "Installed printer drivers:"
        Get-PrinterDriver | Select-Object Name, Manufacturer, PrinterEnvironment | Format-Table -AutoSize
    }

    'GetQueue' {
        if (-not $PrinterName) { throw "-PrinterName required." }
        Write-Status "Print queue for '$PrinterName':"
        $jobs = Get-PrintJob -PrinterName $PrinterName -ErrorAction SilentlyContinue
        if (-not $jobs) {
            Write-Status "Queue is empty." 'SUCCESS'
        } else {
            $jobs | Select-Object Id, DocumentName, UserName, JobStatus, TotalPages, Size | Format-Table -AutoSize
        }
    }

    'SetDefault' {
        if (-not $PrinterName) { throw "-PrinterName required." }
        if ($PSCmdlet.ShouldProcess($PrinterName, 'Set as default printer')) {
            # Set via WMI for reliability
            $printer = Get-CimInstance -ClassName Win32_Printer -Filter "Name='$PrinterName'"
            if (-not $printer) { throw "Printer '$PrinterName' not found." }
            Invoke-CimMethod -InputObject $printer -MethodName SetDefaultPrinter | Out-Null
            Write-Status "Default printer set to '$PrinterName'." 'SUCCESS'
        }
    }

    'ClearQueue' {
        if (-not $PrinterName) { throw "-PrinterName required." }
        if ($PSCmdlet.ShouldProcess($PrinterName, 'Clear print queue')) {
            Write-Status "Clearing print queue for '$PrinterName'..." 'WARN'
            Get-PrintJob -PrinterName $PrinterName -ErrorAction SilentlyContinue |
                Remove-PrintJob -ErrorAction SilentlyContinue
            Write-Status "Queue cleared." 'SUCCESS'
        }
    }

    'Add' {
        if (-not $PrinterName) { throw "-PrinterName required." }
        if (-not $PortAddress) { throw "-PortAddress required." }
        if (-not $DriverName)  { throw "-DriverName required." }

        $portName = "IP_$PortAddress"

        if ($PSCmdlet.ShouldProcess($PrinterName, "Add printer at $PortAddress")) {
            # Create TCP/IP port if it doesn't exist
            if (-not (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue)) {
                Write-Status "Creating port: $portName -> $PortAddress"
                Add-PrinterPort -Name $portName -PrinterHostAddress $PortAddress
            }
            # Verify driver exists
            if (-not (Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue)) {
                throw "Driver '$DriverName' not found. Use -Action ListDrivers to see installed drivers."
            }
            Add-Printer -Name $PrinterName -PortName $portName -DriverName $DriverName
            Write-Status "Printer '$PrinterName' added on port $portName." 'SUCCESS'
        }
    }

    'Remove' {
        if (-not $PrinterName) { throw "-PrinterName required." }
        if ($PSCmdlet.ShouldProcess($PrinterName, 'Remove printer')) {
            Remove-Printer -Name $PrinterName -ErrorAction Stop
            Write-Status "Printer '$PrinterName' removed." 'SUCCESS'
        }
    }
}
