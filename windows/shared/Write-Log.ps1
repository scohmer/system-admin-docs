#Requires -Version 5.1
<#
.SYNOPSIS
    Shared logging module for System Administrator scripts.

.DESCRIPTION
    Provides Write-Log (and a Write-Status backward-compatible alias) with
    simultaneous output to:
      - Console               (color-coded by level — always)
      - Local log file        (always written when Initialize-Log is called)
      - Network share log     (optional UNC path)
      - Network share alerts  (optional; ERROR and ALERT levels only)
      - Windows Event Log     (ERROR and ALERT levels; Source: SysAdminScript, ID: 9001)

    Dot-source this file near the top of any admin script (after param block):

        . "$PSScriptRoot\..\shared\Write-Log.ps1"

    Then call Initialize-Log once before your first Write-Log:

        Initialize-Log -ScriptName 'Invoke-DiskCleanup' `
            -LocalLogPath   'C:\Logs\SysAdmin' `
            -NetworkLogPath '\\fileserver\logs\windows' `
            -AlertLogPath   '\\fileserver\logs\windows\alerts'

.NOTES
    See windows/shared/README.md for full usage and network share setup.
#>

#region Module State
$script:LogInitialized = $false
$script:LocalLogFile   = $null
$script:NetworkLogFile = $null
$script:AlertLogFile   = $null
$script:ScriptLabel    = 'UnknownScript'
#endregion

function Initialize-Log {
    <#
    .SYNOPSIS
        Configure log destinations for the current script run.
    .PARAMETER ScriptName
        Label used in log filenames and Event Log entries. Use the script base name.
    .PARAMETER LocalLogPath
        Directory for local log files. Created automatically if missing.
        Default: C:\Logs\SysAdmin
    .PARAMETER NetworkLogPath
        UNC path for a network copy of the full log. Leave empty to disable.
    .PARAMETER AlertLogPath
        UNC path for the alert-only log (ERROR/ALERT entries). Leave empty to disable.
    .PARAMETER MaxLocalLogAgeDays
        Local log files older than this many days are removed automatically. Default: 30.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ScriptName,

        [string]$LocalLogPath       = "$env:SystemDrive\Logs\SysAdmin",
        [string]$NetworkLogPath     = '',
        [string]$AlertLogPath       = '',
        [int]   $MaxLocalLogAgeDays = 30
    )

    $script:ScriptLabel = $ScriptName
    $timestamp          = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $logName            = "${ScriptName}_$($env:COMPUTERNAME)_${timestamp}.log"

    # ── Local log ─────────────────────────────────────────────────────────────
    try {
        if (-not (Test-Path $LocalLogPath)) {
            New-Item -ItemType Directory -Path $LocalLogPath -Force | Out-Null
        }
        $script:LocalLogFile = Join-Path $LocalLogPath $logName
    } catch {
        Write-Warning "Cannot create local log path '$LocalLogPath': $_"
    }

    # ── Network log ───────────────────────────────────────────────────────────
    if ($NetworkLogPath) {
        try {
            if (-not (Test-Path $NetworkLogPath)) {
                New-Item -ItemType Directory -Path $NetworkLogPath -Force | Out-Null
            }
            $script:NetworkLogFile = Join-Path $NetworkLogPath $logName
        } catch {
            Write-Warning "Cannot reach network log path '$NetworkLogPath': $_. Continuing with local logging only."
        }
    }

    # ── Alert log ─────────────────────────────────────────────────────────────
    if ($AlertLogPath) {
        try {
            if (-not (Test-Path $AlertLogPath)) {
                New-Item -ItemType Directory -Path $AlertLogPath -Force | Out-Null
            }
            $alertName             = "${ScriptName}_$($env:COMPUTERNAME)_${timestamp}_ALERTS.log"
            $script:AlertLogFile   = Join-Path $AlertLogPath $alertName
        } catch {
            Write-Warning "Cannot reach alert log path '$AlertLogPath': $_. Alert logging disabled."
        }
    }

    # ── Clean up stale local logs ──────────────────────────────────────────────
    if ($script:LocalLogFile -and $MaxLocalLogAgeDays -gt 0) {
        Get-ChildItem -Path $LocalLogPath -Filter "${ScriptName}_*.log" -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$MaxLocalLogAgeDays) } |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }

    # ── Register Event Log source (safe — no-op if already registered) ─────────
    try {
        if (-not [System.Diagnostics.EventLog]::SourceExists('SysAdminScript')) {
            New-EventLog -LogName Application -Source 'SysAdminScript' -ErrorAction SilentlyContinue
        }
    } catch { }

    $script:LogInitialized = $true

    # ── Write header to file logs ──────────────────────────────────────────────
    $divider = '=' * 60
    $header  = ($divider,
                "  Script  : $ScriptName",
                "  Host    : $env:COMPUTERNAME",
                "  User    : $env:USERNAME",
                "  Started : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
                $divider,
                '') -join [System.Environment]::NewLine

    if ($script:LocalLogFile) {
        Set-Content -Path $script:LocalLogFile -Value $header -Encoding UTF8 -ErrorAction SilentlyContinue
    }
    if ($script:NetworkLogFile) {
        Set-Content -Path $script:NetworkLogFile -Value $header -Encoding UTF8 -ErrorAction SilentlyContinue
    }
}

function Write-Log {
    <#
    .SYNOPSIS
        Write a timestamped entry to the console and all configured log destinations.
    .PARAMETER Message
        The message text to log.
    .PARAMETER Level
        Severity level: INFO (default), SUCCESS, WARN, ERROR, ALERT.
        ERROR and ALERT also write to the alert log and Windows Application Event Log.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$Message,

        [Parameter(Position = 1)]
        [ValidateSet('INFO','SUCCESS','WARN','ERROR','ALERT')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry     = "[$timestamp][$($env:COMPUTERNAME)][$Level] $Message"

    # ── Console ───────────────────────────────────────────────────────────────
    $color = switch ($Level) {
        'SUCCESS' { 'Green'   }
        'WARN'    { 'Yellow'  }
        'ERROR'   { 'Red'     }
        'ALERT'   { 'Magenta' }
        default   { 'Cyan'    }
    }
    Write-Host $entry -ForegroundColor $color

    # ── Local log ─────────────────────────────────────────────────────────────
    if ($script:LocalLogFile) {
        Add-Content -Path $script:LocalLogFile -Value $entry -Encoding UTF8 -ErrorAction SilentlyContinue
    }

    # ── Network log ───────────────────────────────────────────────────────────
    if ($script:NetworkLogFile) {
        Add-Content -Path $script:NetworkLogFile -Value $entry -Encoding UTF8 -ErrorAction SilentlyContinue
    }

    # ── Alert log + Event Log (ERROR / ALERT only) ────────────────────────────
    if ($Level -in 'ERROR', 'ALERT') {
        if ($script:AlertLogFile) {
            Add-Content -Path $script:AlertLogFile -Value $entry -Encoding UTF8 -ErrorAction SilentlyContinue
        }
        try {
            Write-EventLog -LogName Application -Source 'SysAdminScript' `
                -EntryType Error -EventId 9001 `
                -Message "$script:ScriptLabel on $($env:COMPUTERNAME): $Message" `
                -ErrorAction SilentlyContinue
        } catch { }
    }
}

function Close-Log {
    <#
    .SYNOPSIS
        Write a closing footer to all log files.
    .PARAMETER ExitCode
        The script exit code. 0 = success, non-zero = failure.
    #>
    [CmdletBinding()]
    param([int]$ExitCode = 0)

    $divider = '=' * 60
    $status  = if ($ExitCode -eq 0) { 'SUCCESS' } else { "FAILED (exit code $ExitCode)" }
    $footer  = ('',
                $divider,
                "  Finished : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
                "  Result   : $status",
                $divider) -join [System.Environment]::NewLine

    if ($script:LocalLogFile) {
        Add-Content -Path $script:LocalLogFile -Value $footer -Encoding UTF8 -ErrorAction SilentlyContinue
    }
    if ($script:NetworkLogFile) {
        Add-Content -Path $script:NetworkLogFile -Value $footer -Encoding UTF8 -ErrorAction SilentlyContinue
    }
}

# Backward-compatible alias — existing scripts using Write-Status continue to work
# after dot-sourcing this module without any code changes required.
function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    Write-Log -Message $Message -Level $Level
}
