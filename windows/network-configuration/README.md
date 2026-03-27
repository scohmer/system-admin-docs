> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Network Configuration

Configure network adapters with static IP addresses, DNS servers, and default gateways, or switch to DHCP.

## Script

`Set-NetworkConfiguration.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# List all network adapters
.\Set-NetworkConfiguration.ps1 -Action List

# Show current configuration for a specific adapter
.\Set-NetworkConfiguration.ps1 -Action Show -AdapterName "Ethernet"

# Set a static IP address
.\Set-NetworkConfiguration.ps1 -Action SetStatic `
  -AdapterName "Ethernet" `
  -IPAddress "192.168.1.50" `
  -PrefixLength 24 `
  -DefaultGateway "192.168.1.1" `
  -DNSServers "8.8.8.8","8.8.4.4"

# Switch an adapter to DHCP
.\Set-NetworkConfiguration.ps1 -Action SetDHCP -AdapterName "Ethernet"

# Set DNS servers only (keep existing IP)
.\Set-NetworkConfiguration.ps1 -Action SetDNS -AdapterName "Ethernet" -DNSServers "10.0.0.1","10.0.0.2"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | One of: `List`, `Show`, `SetStatic`, `SetDHCP`, `SetDNS` |
| `-AdapterName` | Yes (except List) | Name of the network adapter (use `List` to find names) |
| `-IPAddress` | Yes for SetStatic | IPv4 address to assign |
| `-PrefixLength` | Yes for SetStatic | Subnet prefix length (e.g., `24` for /24, `255.255.255.0`) |
| `-DefaultGateway` | No | Default gateway IP address |
| `-DNSServers` | No | Array of DNS server IPs (e.g., `"8.8.8.8","8.8.4.4"`) |

## Notes

- Changing IP settings on a remote session may disconnect your session. Test on local console first.
- Use `PrefixLength` values: `8` = /8, `16` = /16, `24` = /24, `25` = /25, etc.
- All changes take effect immediately without requiring a reboot.
