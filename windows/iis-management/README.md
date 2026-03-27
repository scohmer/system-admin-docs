> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — IIS Management

Manage IIS websites and application pools via PowerShell. Requires the `Web-Server` Windows feature and the `WebAdministration` module.

## Prerequisites

IIS must be installed:
```powershell
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
```

## Script

`Manage-IIS.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# List all sites
.\Manage-IIS.ps1 -Action ListSites

# List all app pools
.\Manage-IIS.ps1 -Action ListAppPools

# Start, stop, restart a site
.\Manage-IIS.ps1 -Action StartSite   -SiteName "Default Web Site"
.\Manage-IIS.ps1 -Action StopSite    -SiteName "Default Web Site"
.\Manage-IIS.ps1 -Action RestartSite -SiteName "Default Web Site"

# Start, stop, restart an app pool
.\Manage-IIS.ps1 -Action StartAppPool   -AppPoolName "DefaultAppPool"
.\Manage-IIS.ps1 -Action StopAppPool    -AppPoolName "DefaultAppPool"
.\Manage-IIS.ps1 -Action RestartAppPool -AppPoolName "DefaultAppPool"

# Create a new site with its own app pool
.\Manage-IIS.ps1 -Action CreateSite `
  -SiteName "MyApp" `
  -PhysicalPath "C:\inetpub\myapp" `
  -Port 8080 `
  -AppPoolName "MyAppPool"

# Remove a site
.\Manage-IIS.ps1 -Action RemoveSite -SiteName "MyApp"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `ListSites`, `ListAppPools`, `StartSite`, `StopSite`, `RestartSite`, `StartAppPool`, `StopAppPool`, `RestartAppPool`, `CreateSite`, `RemoveSite` |
| `-SiteName` | Context | IIS site name |
| `-AppPoolName` | Context | Application pool name |
| `-PhysicalPath` | CreateSite | Filesystem path for site content |
| `-Port` | No | HTTP port (default: `80`) |
| `-HostHeader` | No | Optional host header binding |

## Notes

- Stopping the Default Web Site affects all sites sharing its bindings.
- App pools run worker processes (w3wp.exe) — recycling an app pool is safer than restarting IIS entirely.
- Use `iisreset` only as a last resort; prefer site/pool-level operations.
