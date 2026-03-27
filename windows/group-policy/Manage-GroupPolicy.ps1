#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Group Policy Objects (GPOs).

.DESCRIPTION
    List GPOs, force remote group policy updates, generate HTML reports,
    back up GPOs, and retrieve Resultant Set of Policy (RSoP) data.
    Requires the RSAT GroupPolicy PowerShell module.

.PARAMETER Action
    The operation to perform.

.PARAMETER ComputerName
    Target remote computer for ForceUpdate or GetResultantSet.

.PARAMETER GPOName
    Name of a specific GPO. Omit to target all GPOs where applicable.

.PARAMETER BackupPath
    Directory where GPO backups will be stored.

.PARAMETER ReportPath
    File path for HTML report output.

.EXAMPLE
    .\Manage-GroupPolicy.ps1 -Action List
    .\Manage-GroupPolicy.ps1 -Action ForceUpdate -ComputerName PC01
    .\Manage-GroupPolicy.ps1 -Action Backup -BackupPath "C:\GPOBackups"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List', 'ForceUpdate', 'Report', 'Backup', 'GetResultantSet')]
    [string]$Action,

    [string]$ComputerName,
    [string]$GPOName,
    [string]$BackupPath,
    [string]$ReportPath
)

$ErrorActionPreference = 'Stop'

# ─── Helper: coloured timestamped output ────────────────────────────────────
function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

# ─── Ensure GroupPolicy module is available ───────────────────────────────────
function Assert-GPModule {
    if (-not (Get-Module -ListAvailable -Name GroupPolicy)) {
        Write-Status "GroupPolicy module not found. Install RSAT Group Policy Management Tools." 'ERROR'
        Write-Status "Run: Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0" 'WARN'
        exit 1
    }
    Import-Module GroupPolicy -ErrorAction Stop
    Write-Status "GroupPolicy module loaded." 'SUCCESS'
}

function Assert-Param {
    param([string]$Value, [string]$ParamName)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Write-Status "-$ParamName is required for this action." 'ERROR'
        exit 1
    }
}

Assert-GPModule

switch ($Action) {

    'List' {
        # List all GPOs with link count and modification date
        Write-Status "Listing all GPOs in the domain..."
        $gpos = Get-GPO -All | Sort-Object DisplayName
        $gpos | Select-Object DisplayName, Id, GpoStatus, CreationTime, ModificationTime |
            Format-Table -AutoSize
        Write-Status "Total GPOs: $($gpos.Count)" 'SUCCESS'
    }

    'ForceUpdate' {
        Assert-Param $ComputerName 'ComputerName'
        Write-Status "Invoking gpupdate /force on '$ComputerName'..."
        if ($PSCmdlet.ShouldProcess($ComputerName, 'Invoke-GPUpdate /force')) {
            # Invoke-GPUpdate sends a signal; wait for completion is optional
            Invoke-GPUpdate -Computer $ComputerName -Force -RandomDelayInMinutes 0
            Write-Status "Group Policy update triggered on '$ComputerName'." 'SUCCESS'
        }
    }

    'Report' {
        Assert-Param $ReportPath 'ReportPath'
        # Ensure output directory exists
        $reportDir = Split-Path $ReportPath -Parent
        if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }

        if ($GPOName) {
            Write-Status "Generating HTML report for GPO '$GPOName'..."
            if ($PSCmdlet.ShouldProcess($GPOName, "Generate HTML Report to $ReportPath")) {
                Get-GPOReport -Name $GPOName -ReportType HTML -Path $ReportPath
                Write-Status "Report saved to '$ReportPath'." 'SUCCESS'
            }
        }
        else {
            Write-Status "Generating HTML report for ALL GPOs..."
            if ($PSCmdlet.ShouldProcess('All GPOs', "Generate HTML Report to $ReportPath")) {
                Get-GPOReport -All -ReportType HTML -Path $ReportPath
                Write-Status "Report saved to '$ReportPath'." 'SUCCESS'
            }
        }
    }

    'Backup' {
        Assert-Param $BackupPath 'BackupPath'
        # Create backup directory if it doesn't exist
        if (-not (Test-Path $BackupPath)) {
            New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
            Write-Status "Created backup directory: $BackupPath"
        }

        if ($GPOName) {
            Write-Status "Backing up GPO '$GPOName' to '$BackupPath'..."
            if ($PSCmdlet.ShouldProcess($GPOName, "Backup to $BackupPath")) {
                $result = Backup-GPO -Name $GPOName -Path $BackupPath -Comment "Backup $(Get-Date -Format 'yyyy-MM-dd')"
                Write-Status "GPO '$GPOName' backed up. ID: $($result.Id)" 'SUCCESS'
            }
        }
        else {
            Write-Status "Backing up ALL GPOs to '$BackupPath'..."
            if ($PSCmdlet.ShouldProcess('All GPOs', "Backup to $BackupPath")) {
                $results = Backup-GPO -All -Path $BackupPath -Comment "Full backup $(Get-Date -Format 'yyyy-MM-dd')"
                Write-Status "Backed up $($results.Count) GPOs." 'SUCCESS'
            }
        }
    }

    'GetResultantSet' {
        Assert-Param $ComputerName 'ComputerName'
        Assert-Param $ReportPath 'ReportPath'
        $reportDir = Split-Path $ReportPath -Parent
        if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }

        Write-Status "Generating RSoP report for '$ComputerName'..."
        if ($PSCmdlet.ShouldProcess($ComputerName, "Get Resultant Set of Policy, save to $ReportPath")) {
            # Get-GPResultantSetOfPolicy requires WinRM access to the target
            Get-GPResultantSetOfPolicy -Computer $ComputerName -ReportType HTML -Path $ReportPath
            Write-Status "RSoP report saved to '$ReportPath'." 'SUCCESS'
        }
    }
}
