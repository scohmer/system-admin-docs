<#
.SYNOPSIS
    Manages Windows HTTP proxy settings for WinINET (current user) and WinHTTP (system-wide).

.DESCRIPTION
    Provides actions to get, set, and clear proxy configuration at the current-user
    level (via registry / WinINET) and optionally at the system level (WinHTTP via netsh).

.PARAMETER Action
    Get            - Display current proxy settings
    SetManual      - Set a specific proxy server (host:port)
    SetAutoDetect  - Enable WPAD auto-detection
    SetPAC         - Use a PAC file URL
    Clear          - Remove all proxy settings
    SetSystemWide  - Configure WinHTTP proxy (system-wide, requires admin)

.PARAMETER ProxyServer
    Proxy server address in host:port format (e.g. proxy.corp.local:8080).

.PARAMETER BypassList
    Array of hosts/patterns to bypass the proxy.

.PARAMETER PACUrl
    URL to a Proxy Auto-Configuration (PAC) file.

.PARAMETER ApplyToWinHTTP
    When set, also applies changes to WinHTTP via netsh (requires administrator).

.EXAMPLE
    .\Set-ProxyConfiguration.ps1 -Action Get
    .\Set-ProxyConfiguration.ps1 -Action SetManual -ProxyServer "proxy.corp.local:8080" -BypassList "*.corp.local","localhost"
    .\Set-ProxyConfiguration.ps1 -Action SetPAC -PACUrl "http://proxy.corp.local/proxy.pac"
    .\Set-ProxyConfiguration.ps1 -Action Clear -ApplyToWinHTTP
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Get', 'SetManual', 'SetAutoDetect', 'SetPAC', 'Clear', 'SetSystemWide')]
    [string]$Action,

    [Parameter()]
    [string]$ProxyServer,

    [Parameter()]
    [string[]]$BypassList,

    [Parameter()]
    [string]$PACUrl,

    [Parameter()]
    [switch]$ApplyToWinHTTP
)

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Set-ProxyConfiguration'

# Registry path for WinINET/IE proxy settings (current user)
$regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'

# Helper: read and display current WinINET proxy registry values
function Show-WinINETSettings {
    $settings = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        ProxyEnable     = $settings.ProxyEnable
        ProxyServer     = $settings.ProxyServer
        ProxyOverride   = $settings.ProxyOverride
        AutoConfigURL   = $settings.AutoConfigURL
        AutoDetect      = $settings.AutoDetect
    } | Format-List
}

# Helper: set a registry value, creating it if missing
function Set-ProxyReg {
    param([string]$Name, $Value)
    Set-ItemProperty -Path $regPath -Name $Name -Value $Value -Force
}

# Helper: remove a registry value if it exists
function Remove-ProxyReg {
    param([string]$Name)
    if (Get-ItemProperty -Path $regPath -Name $Name -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $regPath -Name $Name -Force -ErrorAction SilentlyContinue
    }
}

# Helper: apply settings to WinHTTP via netsh
function Set-WinHTTPProxy {
    param([string]$Server, [string]$Bypass)

    Write-Status "Configuring WinHTTP proxy (requires administrator)..."

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Status "Administrator rights required to configure WinHTTP proxy." 'ERROR'
        return
    }

    if ($PSCmdlet.ShouldProcess('WinHTTP', "Set proxy to $Server")) {
        if ($Bypass) {
            & netsh winhttp set proxy proxy-server="$Server" bypass-list="$Bypass" 2>&1 |
                ForEach-Object { Write-Host $_ }
        } else {
            & netsh winhttp set proxy proxy-server="$Server" 2>&1 |
                ForEach-Object { Write-Host $_ }
        }
        Write-Status "WinHTTP proxy configured." 'SUCCESS'
    }
}

# Helper: clear WinHTTP proxy
function Clear-WinHTTPProxy {
    Write-Status "Clearing WinHTTP proxy settings..."
    if ($PSCmdlet.ShouldProcess('WinHTTP', 'Reset proxy')) {
        & netsh winhttp reset proxy 2>&1 | ForEach-Object { Write-Host $_ }
        Write-Status "WinHTTP proxy cleared." 'SUCCESS'
    }
}

switch ($Action) {

    'Get' {
        Write-Status "Current WinINET (per-user) proxy settings:"
        Show-WinINETSettings

        Write-Host "`n--- WinHTTP (system-wide) ---" -ForegroundColor Magenta
        & netsh winhttp show proxy 2>&1 | ForEach-Object { Write-Host $_ }
    }

    'SetManual' {
        if (-not $ProxyServer) {
            Write-Status "ProxyServer parameter is required for SetManual action." 'ERROR'
            exit 1
        }

        $bypassStr = if ($BypassList) { ($BypassList -join ';') + ';<local>' } else { '<local>' }

        Write-Status "Setting manual proxy: $ProxyServer (bypass: $bypassStr)"

        if ($PSCmdlet.ShouldProcess('WinINET', "Set manual proxy $ProxyServer")) {
            Set-ProxyReg 'ProxyEnable'   1
            Set-ProxyReg 'ProxyServer'   $ProxyServer
            Set-ProxyReg 'ProxyOverride' $bypassStr
            Remove-ProxyReg 'AutoConfigURL'
            Set-ProxyReg 'AutoDetect' 0
            Write-Status "Manual proxy configured for current user." 'SUCCESS'
        }

        if ($ApplyToWinHTTP) {
            Set-WinHTTPProxy -Server $ProxyServer -Bypass $bypassStr
        }
    }

    'SetAutoDetect' {
        Write-Status "Enabling proxy auto-detection (WPAD)..."

        if ($PSCmdlet.ShouldProcess('WinINET', 'Enable auto-detect')) {
            Set-ProxyReg 'ProxyEnable' 0
            Set-ProxyReg 'AutoDetect' 1
            Remove-ProxyReg 'ProxyServer'
            Remove-ProxyReg 'AutoConfigURL'
            Write-Status "Auto-detect proxy enabled." 'SUCCESS'
        }
    }

    'SetPAC' {
        if (-not $PACUrl) {
            Write-Status "PACUrl parameter is required for SetPAC action." 'ERROR'
            exit 1
        }

        Write-Status "Setting PAC URL: $PACUrl"

        if ($PSCmdlet.ShouldProcess('WinINET', "Set PAC URL $PACUrl")) {
            Set-ProxyReg 'ProxyEnable'   0
            Set-ProxyReg 'AutoConfigURL' $PACUrl
            Set-ProxyReg 'AutoDetect'    0
            Remove-ProxyReg 'ProxyServer'
            Write-Status "PAC URL configured for current user." 'SUCCESS'
        }
    }

    'Clear' {
        Write-Status "Clearing all proxy settings for current user..."

        if ($PSCmdlet.ShouldProcess('WinINET', 'Clear all proxy settings')) {
            Set-ProxyReg 'ProxyEnable' 0
            Set-ProxyReg 'AutoDetect'  0
            Remove-ProxyReg 'ProxyServer'
            Remove-ProxyReg 'AutoConfigURL'
            Remove-ProxyReg 'ProxyOverride'
            Write-Status "Proxy settings cleared for current user." 'SUCCESS'
        }

        if ($ApplyToWinHTTP) {
            Clear-WinHTTPProxy
        }
    }

    'SetSystemWide' {
        if (-not $ProxyServer) {
            # Import current WinINET settings into WinHTTP
            Write-Status "No ProxyServer specified; importing WinINET settings into WinHTTP..."
            if ($PSCmdlet.ShouldProcess('WinHTTP', 'Import IE proxy settings')) {
                & netsh winhttp import proxy source=ie 2>&1 | ForEach-Object { Write-Host $_ }
                Write-Status "WinHTTP proxy imported from IE/WinINET settings." 'SUCCESS'
            }
        } else {
            $bypassStr = if ($BypassList) { ($BypassList -join ';') + ';<local>' } else { '<local>' }
            Set-WinHTTPProxy -Server $ProxyServer -Bypass $bypassStr
        }
    }
}
Close-Log
