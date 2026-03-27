> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — DNS Server Management

Manage DNS zones and resource records on a Windows DNS server. Requires the `DnsServer` PowerShell module (installed with the DNS Server role or via RSAT).

## Prerequisites

```powershell
# On a DNS server (Server OS)
Install-WindowsFeature -Name DNS -IncludeManagementTools

# RSAT on Windows 10/11
Add-WindowsCapability -Online -Name Rsat.Dns.Tools~~~~0.0.1.0
```

## Script

`Manage-DNSServer.ps1`

**Must be run as Administrator or with DNS admin rights.**

## Usage

```powershell
# List all zones
.\Manage-DNSServer.ps1 -Action ListZones

# List all records in a zone
.\Manage-DNSServer.ps1 -Action ListRecords -ZoneName "corp.local"

# Add an A record
.\Manage-DNSServer.ps1 -Action AddRecord -ZoneName "corp.local" `
  -RecordName "webserver01" -RecordType A -RecordData "192.168.1.50"

# Add a CNAME record
.\Manage-DNSServer.ps1 -Action AddRecord -ZoneName "corp.local" `
  -RecordName "www" -RecordType CNAME -RecordData "webserver01.corp.local."

# Remove a record
.\Manage-DNSServer.ps1 -Action RemoveRecord -ZoneName "corp.local" `
  -RecordName "webserver01" -RecordType A

# Add a forward lookup zone
.\Manage-DNSServer.ps1 -Action AddZone -ZoneName "newdomain.local"

# Query a remote DNS server
.\Manage-DNSServer.ps1 -Action ListZones -ComputerName "dc01.corp.local"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `ListZones`, `ListRecords`, `AddRecord`, `RemoveRecord`, `AddZone`, `RemoveZone` |
| `-ZoneName` | Context | DNS zone name (e.g., `corp.local`) |
| `-RecordName` | Context | Record host name (relative to zone, e.g., `webserver01`) |
| `-RecordType` | Context | `A`, `AAAA`, `CNAME`, `MX`, `PTR`, `TXT`, `NS` |
| `-RecordData` | AddRecord | Record value (IP for A, FQDN for CNAME, etc.) |
| `-TTL` | No | Time-to-live (default: `1:00:00`) |
| `-ComputerName` | No | DNS server to manage (default: local) |

## Notes

- CNAME record data must end with a trailing dot (`.`) for FQDN.
- PTR records belong in reverse lookup zones (e.g., `1.168.192.in-addr.arpa`).
- Removing a zone is irreversible — export records first if needed.
