<#
.SYNOPSIS
    Backup and restore directories using Robocopy.

.NOTES
    Robocopy is built into Windows. No additional prerequisites required.
    See README.md for usage examples and backup mode descriptions.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Backup','Mirror','Incremental','Verify')]
    [string]$Action,

    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Destination,

    [Parameter()]
    [switch]$Timestamped,

    [Parameter()]
    [string]$LogFile,

    [Parameter()]
    [string[]]$ExcludeFiles = @('*.tmp', 'desktop.ini', 'thumbs.db'),

    [Parameter()]
    [string[]]$ExcludeDirs = @('$RECYCLE.BIN', 'System Volume Information')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

# Validate source
if (-not (Test-Path $Source)) {
    throw "Source directory not found: $Source"
}

# Apply timestamp to destination if requested
if ($Timestamped) {
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm'
    $Destination = Join-Path $Destination $timestamp
}

# Set up log file
if (-not $LogFile) {
    $logDir = 'C:\Logs'
    $LogFile = Join-Path $logDir "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}
$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Write-Status "Backup operation: $Action"
Write-Status "Source:           $Source"
Write-Status "Destination:      $Destination"
Write-Status "Log:              $LogFile"

# Build common Robocopy arguments
$robocopyArgs = @(
    $Source,
    $Destination,
    '/E',            # Copy subdirectories including empty ones
    '/R:2',          # Retry failed copies 2 times
    '/W:5',          # Wait 5 seconds between retries
    '/NP',           # Don't show progress percentage
    '/TEE',          # Output to log and console
    "/LOG+:$LogFile" # Append to log file
)

# Exclude patterns
if ($ExcludeFiles) { $robocopyArgs += @('/XF') + $ExcludeFiles }
if ($ExcludeDirs)  { $robocopyArgs += @('/XD') + $ExcludeDirs }

# Add mode-specific flags
switch ($Action) {
    'Backup' {
        # Copy all files, preserve attributes and timestamps
        $robocopyArgs += '/COPYALL'
    }
    'Mirror' {
        Write-Status "MIRROR mode will DELETE files in destination not present in source." 'WARN'
        $robocopyArgs += @('/MIR', '/COPYALL')
    }
    'Incremental' {
        # Only copy files that are newer in the source
        $robocopyArgs += @('/XO', '/COPYALL')
    }
    'Verify' {
        # List only — no copy
        $robocopyArgs += '/L'
        Write-Status "VERIFY mode: listing differences only, no files will be copied." 'WARN'
    }
}

if ($PSCmdlet.ShouldProcess("$Source -> $Destination", "$Action via Robocopy")) {
    Write-Status "Starting Robocopy..."
    & robocopy @robocopyArgs

    # Interpret Robocopy exit codes
    $exitCode = $LASTEXITCODE
    switch ($exitCode) {
        0 { Write-Status "No files needed copying. Destination is up to date." 'SUCCESS' }
        1 { Write-Status "Files copied successfully." 'SUCCESS' }
        { $_ -in 2,3 } { Write-Status "Files copied. Some extra files in destination." 'SUCCESS' }
        { $_ -ge 8 }   { Write-Status "Errors occurred during copy (exit code $exitCode). Review log: $LogFile" 'ERROR' }
        default        { Write-Status "Robocopy finished with exit code $exitCode. Review log: $LogFile" 'WARN' }
    }

    Write-Status "Log written to: $LogFile"
}
