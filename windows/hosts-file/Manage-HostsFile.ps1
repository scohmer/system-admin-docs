#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Add, remove, list, and back up entries in the Windows hosts file.
.NOTES
    Always creates a backup before modifying. Flushes DNS cache on changes.
    See README.md for usage examples.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Add','Remove','Backup','Flush')]
    [string]$Action,

    [Parameter()] [string]$IPAddress,
    [Parameter()] [string]$Hostname,
    [Parameter()] [string]$Comment = '',
    [Parameter()] [string]$BackupPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"

function Backup-Hosts {
    $dest = "$hostsPath.$(Get-Date -Format 'yyyyMMdd_HHmmss').bak"
    Copy-Item $hostsPath $dest -Force
    Write-Status "Hosts file backed up to: $dest"
    return $dest
}

switch ($Action) {

    'List' {
        Write-Status "Hosts file entries ($hostsPath):"
        $lines = Get-Content $hostsPath
        $entries = $lines | Where-Object { $_ -match '^\s*\d' } |
            ForEach-Object {
                $parts = $_ -split '\s+', 3
                [PSCustomObject]@{ IP = $parts[0]; Hostname = $parts[1]; Comment = if ($parts[2]) { $parts[2] } else { '' } }
            }
        if ($entries.Count -eq 0) {
            Write-Status "No active (non-comment) entries found." 'WARN'
        } else {
            $entries | Format-Table -AutoSize
        }
    }

    'Add' {
        if (-not $IPAddress) { throw "-IPAddress required." }
        if (-not $Hostname)  { throw "-Hostname required." }

        $lines = Get-Content $hostsPath
        # Check for duplicate
        if ($lines | Where-Object { $_ -match "^\s*$([regex]::Escape($IPAddress))\s+$([regex]::Escape($Hostname))" }) {
            Write-Status "Entry '$IPAddress $Hostname' already exists. No change." 'WARN'
            return
        }

        if ($PSCmdlet.ShouldProcess($hostsPath, "Add '$IPAddress $Hostname'")) {
            Backup-Hosts | Out-Null
            $entry = "$IPAddress`t$Hostname"
            if ($Comment) { $entry += "`t# $Comment" }
            Add-Content $hostsPath "`n$entry" -Encoding UTF8
            Write-Status "Added: $entry" 'SUCCESS'
            # Flush DNS
            & ipconfig /flushdns | Out-Null
            Write-Status "DNS cache flushed."
        }
    }

    'Remove' {
        if (-not $Hostname) { throw "-Hostname required." }
        $lines = Get-Content $hostsPath
        $newLines = $lines | Where-Object { $_ -notmatch "\s$([regex]::Escape($Hostname))(\s|$)" }
        if ($newLines.Count -eq $lines.Count) {
            Write-Status "Hostname '$Hostname' not found in hosts file." 'WARN'
            return
        }
        if ($PSCmdlet.ShouldProcess($hostsPath, "Remove entries for '$Hostname'")) {
            Backup-Hosts | Out-Null
            $newLines | Set-Content $hostsPath -Encoding UTF8
            Write-Status "Entries for '$Hostname' removed." 'SUCCESS'
            & ipconfig /flushdns | Out-Null
            Write-Status "DNS cache flushed."
        }
    }

    'Backup' {
        $dest = if ($BackupPath) { $BackupPath } else { "$hostsPath.$(Get-Date -Format 'yyyyMMdd_HHmmss').bak" }
        Copy-Item $hostsPath $dest -Force
        Write-Status "Hosts file backed up to: $dest" 'SUCCESS'
    }

    'Flush' {
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Flush DNS cache')) {
            & ipconfig /flushdns
            Write-Status "DNS cache flushed." 'SUCCESS'
        }
    }
}
