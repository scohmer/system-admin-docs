> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Proxy Configuration

Manages Windows HTTP proxy settings at both the current-user level (WinINET / IE settings) and system-wide level (WinHTTP). Supports manual proxy, auto-detect (WPAD), and PAC file URL configuration.

## Script

`Set-ProxyConfiguration.ps1`

## Usage

```powershell
# Get current proxy settings
.\Set-ProxyConfiguration.ps1 -Action Get

# Set a manual proxy for the current user
.\Set-ProxyConfiguration.ps1 -Action SetManual -ProxyServer "proxy.corp.local:8080"

# Set a manual proxy with bypass list
.\Set-ProxyConfiguration.ps1 -Action SetManual -ProxyServer "proxy.corp.local:8080" -BypassList "*.corp.local","10.*","localhost"

# Enable auto-detect (WPAD)
.\Set-ProxyConfiguration.ps1 -Action SetAutoDetect

# Set a PAC file URL
.\Set-ProxyConfiguration.ps1 -Action SetPAC -PACUrl "http://proxy.corp.local/proxy.pac"

# Clear all proxy settings
.\Set-ProxyConfiguration.ps1 -Action Clear

# Set system-wide proxy via WinHTTP (requires admin)
.\Set-ProxyConfiguration.ps1 -Action SetSystemWide -ProxyServer "proxy.corp.local:8080" -ApplyToWinHTTP
```

## Parameters

| Parameter        | Type     | Required | Description                                                        |
|------------------|----------|----------|--------------------------------------------------------------------|
| `-Action`        | String   | Yes      | `Get`, `SetManual`, `SetAutoDetect`, `SetPAC`, `Clear`, `SetSystemWide` |
| `-ProxyServer`   | String   | No       | Proxy server in `host:port` format                                 |
| `-BypassList`    | String[] | No       | Hosts to bypass the proxy (e.g. `*.corp.local`, `localhost`)       |
| `-PACUrl`        | String   | No       | URL to a PAC (Proxy Auto-Configuration) file                       |
| `-ApplyToWinHTTP`| Switch   | No       | Also apply settings to WinHTTP (system-wide, requires admin)       |

## Notes

- WinINET (HKCU) settings apply only to the **current user** and affect IE, Edge, and apps using WinINET.
- WinHTTP settings (`netsh winhttp`) apply **system-wide** and affect services and apps using WinHTTP.
- `SetSystemWide` imports the current WinINET settings into WinHTTP automatically if no server is specified.
- Changing WinHTTP settings requires administrator privileges.
- After changing proxy settings, applications may need to be restarted to pick up the new values.
