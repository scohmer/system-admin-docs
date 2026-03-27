> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — TCP/IP Settings

View and configure advanced TCP/IP settings including MTU, TCP window scaling, receive window auto-tuning, and chimney offload.

## Script

`Set-TCPIPSettings.ps1`

## Usage

```powershell
# Show current TCP/IP global settings
.\Set-TCPIPSettings.ps1 -Action GetSettings

# Show MTU for all adapters
.\Set-TCPIPSettings.ps1 -Action GetMTU

# Set MTU on a specific adapter
.\Set-TCPIPSettings.ps1 -Action SetMTU -AdapterName "Ethernet" -MTU 1500

# Enable/disable TCP window scaling (auto-tuning)
.\Set-TCPIPSettings.ps1 -Action SetAutoTuning -Level normal

# Disable receive window auto-tuning (useful for some VPN/WAN issues)
.\Set-TCPIPSettings.ps1 -Action SetAutoTuning -Level disabled

# Set TCP chimney offload state
.\Set-TCPIPSettings.ps1 -Action SetChimney -State disabled

# Show TCP connection statistics
.\Set-TCPIPSettings.ps1 -Action GetStats

# Reset all TCP/IP settings to defaults
.\Set-TCPIPSettings.ps1 -Action Reset
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `GetSettings`, `GetMTU`, `SetMTU`, `SetAutoTuning`, `SetChimney`, `GetStats`, `Reset` |
| `-AdapterName` | SetMTU | Network adapter name |
| `-MTU` | SetMTU | MTU size in bytes (typical: `1500` for Ethernet, `1492` for PPPoE) |
| `-Level` | SetAutoTuning | `normal`, `experimental`, `highlyrestricted`, `restricted`, `disabled` |
| `-State` | SetChimney | `default`, `enabled`, `disabled` |

## Notes

- Uses `netsh.exe` for TCP settings — changes take effect immediately without a reboot.
- `Reset` runs `netsh int ip reset` and `netsh winsock reset` — requires reboot to complete.
- Auto-tuning `disabled` can fix throughput issues on satellite or high-latency WAN links.
