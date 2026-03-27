#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Install, update, and remove software using Windows Package Manager (winget).

.NOTES
    See README.md for usage, package ID lookup, and list file format.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Search','Install','InstallList','Update','UpdateAll','Uninstall','List')]
    [string]$Action,

    [Parameter()]
    [string]$PackageId,

    [Parameter()]
    [string]$Version,

    [Parameter()]
    [string]$PackageListFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

# Verify winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Status "winget not found. Install 'App Installer' from the Microsoft Store." 'ERROR'
    exit 1
}

function Invoke-WingetInstall {
    param([string]$Id, [string]$Ver = '')
    $args = @('install', '--id', $Id, '--silent', '--accept-package-agreements', '--accept-source-agreements')
    if ($Ver) { $args += @('--version', $Ver) }
    Write-Status "Installing: $Id$(if ($Ver) { " v$Ver" })..."
    winget @args
    if ($LASTEXITCODE -eq 0) {
        Write-Status "$Id installed successfully." 'SUCCESS'
    } else {
        Write-Status "$Id installation failed (exit code $LASTEXITCODE)." 'ERROR'
    }
}

switch ($Action) {

    'Search' {
        if (-not $PackageId) { throw "-PackageId is required for Search." }
        Write-Status "Searching winget for '$PackageId'..."
        winget search $PackageId --accept-source-agreements
    }

    'Install' {
        if (-not $PackageId) { throw "-PackageId is required for Install." }
        if ($PSCmdlet.ShouldProcess($PackageId, 'Install package')) {
            Invoke-WingetInstall -Id $PackageId -Ver $Version
        }
    }

    'InstallList' {
        if (-not $PackageListFile) { throw "-PackageListFile is required for InstallList." }
        if (-not (Test-Path $PackageListFile)) { throw "Package list file not found: $PackageListFile" }

        $packages = Get-Content $PackageListFile |
            Where-Object { $_ -notmatch '^\s*#' -and $_.Trim() -ne '' } |
            ForEach-Object { $_.Trim() }

        Write-Status "Installing $($packages.Count) package(s) from '$PackageListFile'..."
        $success = 0; $failed = 0
        foreach ($pkg in $packages) {
            if ($PSCmdlet.ShouldProcess($pkg, 'Install package')) {
                try {
                    Invoke-WingetInstall -Id $pkg
                    $success++
                } catch {
                    Write-Status "Error installing $pkg`: $_" 'ERROR'
                    $failed++
                }
            }
        }
        Write-Status "Complete: $success succeeded, $failed failed." $(if ($failed -gt 0) { 'WARN' } else { 'SUCCESS' })
    }

    'Update' {
        if (-not $PackageId) { throw "-PackageId is required for Update." }
        if ($PSCmdlet.ShouldProcess($PackageId, 'Update package')) {
            Write-Status "Updating '$PackageId'..."
            winget upgrade --id $PackageId --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) { Write-Status "$PackageId updated." 'SUCCESS' }
            else { Write-Status "Update failed or package is already current (exit code $LASTEXITCODE)." 'WARN' }
        }
    }

    'UpdateAll' {
        Write-Status "Updating all installed packages..." 'WARN'
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Update all packages')) {
            winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
        }
    }

    'Uninstall' {
        if (-not $PackageId) { throw "-PackageId is required for Uninstall." }
        if ($PSCmdlet.ShouldProcess($PackageId, 'Uninstall package')) {
            Write-Status "Uninstalling '$PackageId'..." 'WARN'
            winget uninstall --id $PackageId --silent
            if ($LASTEXITCODE -eq 0) { Write-Status "$PackageId uninstalled." 'SUCCESS' }
            else { Write-Status "Uninstall failed (exit code $LASTEXITCODE)." 'ERROR' }
        }
    }

    'List' {
        Write-Status "Listing installed packages..."
        winget list --accept-source-agreements
    }
}
