> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# NTP Configuration

Manages Windows Time (W32Time) service configuration, including NTP server settings, synchronization, and client/server mode configuration. Uses the `w32tm` command-line tool for all time synchronization operations.

## Script

`Set-NTPConfiguration.ps1`

## Usage

```powershell
# Check current NTP status
.\Set-NTPConfiguration.ps1 -Action Status

# Set NTP servers
.\Set-NTPConfiguration.ps1 -Action SetServer -NTPServer "time.windows.com","pool.ntp.org"

# Force an immediate time sync
.\Set-NTPConfiguration.ps1 -Action Sync

# Resync all peers
.\Set-NTPConfiguration.ps1 -Action ResyncAll

# Configure as NTP client/server
.\Set-NTPConfiguration.ps1 -Action Configure -NTPServer "time.windows.com"

# Run against a remote computer
.\Set-NTPConfiguration.ps1 -Action Status -ComputerName "SERVER01"
```

## Parameters

| Parameter      | Type     | Required | Description                                                    |
|----------------|----------|----------|----------------------------------------------------------------|
| `-Action`      | String   | Yes      | Action to perform: `Status`, `SetServer`, `Sync`, `ResyncAll`, `Configure` |
| `-NTPServer`   | String[] | No       | One or more NTP server hostnames (e.g. `time.windows.com`)    |
| `-ComputerName`| String   | No       | Remote computer to target (defaults to local machine)          |

## Notes

- Requires administrator privileges to change NTP configuration or restart W32Time.
- `SetServer` and `Configure` will restart the W32Time service to apply changes.
- `Sync` performs an immediate resync; the system clock may jump if offset is large.
- `ResyncAll` forces a resync of all configured peers.
- On domain-joined machines, NTP is typically controlled by Group Policy; local settings may be overridden.
- Use `w32tm /query /peers` to verify peer list after setting servers.
