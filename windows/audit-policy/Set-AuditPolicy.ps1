#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manages Windows Advanced Audit Policy using auditpol.exe.

.DESCRIPTION
    Provides actions to query, configure, report, and reset Windows audit policy
    settings at the subcategory level using the auditpol command-line tool.

.PARAMETER Action
    Get    - Query current audit policy (all categories or a specific one)
    Set    - Enable/disable auditing for a subcategory
    Report - Export current policy to a CSV file
    Reset  - Reset all audit policy settings to system defaults

.PARAMETER Category
    Audit category name (e.g. "Logon/Logoff"). Used with Get action.

.PARAMETER Subcategory
    Specific subcategory name (e.g. "Logon"). Required for Set action.

.PARAMETER AuditType
    Audit type for Set action: Success, Failure, Both, or None.

.PARAMETER ReportPath
    Output file path for the Report action (CSV format).

.EXAMPLE
    .\Set-AuditPolicy.ps1 -Action Get
    .\Set-AuditPolicy.ps1 -Action Set -Subcategory "Logon" -AuditType Both
    .\Set-AuditPolicy.ps1 -Action Report -ReportPath "C:\Reports\AuditPolicy.csv"
    .\Set-AuditPolicy.ps1 -Action Reset
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Get', 'Set', 'Report', 'Reset')]
    [string]$Action,

    [Parameter()]
    [string]$Category,

    [Parameter()]
    [string]$Subcategory,

    [Parameter()]
    [ValidateSet('Success', 'Failure', 'Both', 'None')]
    [string]$AuditType,

    [Parameter()]
    [string]$ReportPath
)

$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

# Helper: parse auditpol output into structured objects
function Get-AuditPolicyData {
    param([string]$CategoryFilter)

    # Run auditpol and capture output (skip header lines)
    $auditpolArgs = @('/get', '/category:*', '/r')  # /r = CSV output
    $rawOutput = & auditpol @auditpolArgs 2>&1

    # Parse CSV output from auditpol /r
    $results = $rawOutput | Select-Object -Skip 1 | ConvertFrom-Csv

    if ($CategoryFilter) {
        $results = $results | Where-Object { $_.'Category/Subcategory' -like "*$CategoryFilter*" -or $_.Category -like "*$CategoryFilter*" }
    }

    return $results
}

switch ($Action) {

    'Get' {
        if ($Category) {
            Write-Status "Querying audit policy for category: $Category"
            # Use direct auditpol query for human-readable output
            & auditpol /get /category:"$Category" 2>&1 | ForEach-Object { Write-Host $_ }
        } else {
            Write-Status "Querying all audit policy settings..."
            & auditpol /get /category:* 2>&1 | ForEach-Object { Write-Host $_ }
        }
    }

    'Set' {
        if (-not $Subcategory) {
            Write-Status "Subcategory parameter is required for Set action." 'ERROR'
            exit 1
        }
        if (-not $AuditType) {
            Write-Status "AuditType parameter is required for Set action." 'ERROR'
            exit 1
        }

        # Map AuditType to auditpol /success and /failure flags
        $successFlag = switch ($AuditType) {
            'Success' { 'enable' }
            'Both'    { 'enable' }
            'None'    { 'disable' }
            'Failure' { 'disable' }
        }
        $failureFlag = switch ($AuditType) {
            'Failure' { 'enable' }
            'Both'    { 'enable' }
            'None'    { 'disable' }
            'Success' { 'disable' }
        }

        Write-Status "Setting audit policy: Subcategory='$Subcategory' Success=$successFlag Failure=$failureFlag"

        if ($PSCmdlet.ShouldProcess($Subcategory, "Set audit policy to $AuditType")) {
            $result = & auditpol /set /subcategory:"$Subcategory" /success:$successFlag /failure:$failureFlag 2>&1
            $result | ForEach-Object { Write-Host $_ }

            if ($LASTEXITCODE -eq 0) {
                Write-Status "Audit policy for '$Subcategory' set to '$AuditType' successfully." 'SUCCESS'
            } else {
                Write-Status "auditpol returned exit code $LASTEXITCODE. Verify the subcategory name." 'ERROR'
                exit 1
            }
        }
    }

    'Report' {
        if (-not $ReportPath) {
            # Default to current directory with timestamp
            $ReportPath = Join-Path $PWD "AuditPolicy_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
        }

        Write-Status "Exporting audit policy report to: $ReportPath"

        if ($PSCmdlet.ShouldProcess($ReportPath, 'Export audit policy report')) {
            # auditpol /backup exports a full CSV backup
            & auditpol /backup /file:"$ReportPath" 2>&1 | ForEach-Object { Write-Host $_ }

            if (Test-Path $ReportPath) {
                $lineCount = (Get-Content $ReportPath).Count
                Write-Status "Report exported: $ReportPath ($lineCount lines)" 'SUCCESS'
            } else {
                Write-Status "Report file was not created. Check permissions and path." 'WARN'
            }
        }
    }

    'Reset' {
        Write-Status "Resetting all audit policy settings to defaults..." 'WARN'
        Write-Status "This will DISABLE all audit subcategories." 'WARN'

        if ($PSCmdlet.ShouldProcess('Audit Policy', 'Reset all settings to defaults')) {
            # /clear resets all subcategory settings; /y suppresses confirmation
            $result = & auditpol /clear /y 2>&1
            $result | ForEach-Object { Write-Host $_ }

            if ($LASTEXITCODE -eq 0) {
                Write-Status "Audit policy reset to defaults successfully." 'SUCCESS'
            } else {
                Write-Status "auditpol /clear returned exit code $LASTEXITCODE." 'ERROR'
                exit 1
            }
        }
    }
}
