> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — DHCP Server Management

Manage DHCP scopes, leases, and reservations on a Windows DHCP server. Requires the `DhcpServer` PowerShell module.

## Prerequisites

```powershell
# On a DHCP server
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# RSAT on Windows 10/11
Add-WindowsCapability -Online -Name Rsat.DHCP.Tools~~~~0.0.1.0
```

## Script

`Manage-DHCPServer.ps1`

**Must be run as Administrator or with DHCP admin rights.**

## Usage

```powershell
# List all scopes
.\Manage-DHCPServer.ps1 -Action ListScopes

# List active leases in a scope
.\Manage-DHCPServer.ps1 -Action GetLeases -ScopeId "192.168.1.0"

# List reservations
.\Manage-DHCPServer.ps1 -Action ListReservations -ScopeId "192.168.1.0"

# Add a reservation
.\Manage-DHCPServer.ps1 -Action AddReservation -ScopeId "192.168.1.0" `
  -IPAddress "192.168.1.200" -MACAddress "AA-BB-CC-DD-EE-FF" -ClientName "PrinterLobby"

# Remove a reservation
.\Manage-DHCPServer.ps1 -Action RemoveReservation -ScopeId "192.168.1.0" `
  -IPAddress "192.168.1.200"

# Activate or deactivate a scope
.\Manage-DHCPServer.ps1 -Action ActivateScope   -ScopeId "192.168.1.0"
.\Manage-DHCPServer.ps1 -Action DeactivateScope -ScopeId "192.168.1.0"

# Target a remote DHCP server
.\Manage-DHCPServer.ps1 -Action ListScopes -ComputerName "dhcpsrv01"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `ListScopes`, `GetLeases`, `ListReservations`, `AddReservation`, `RemoveReservation`, `ActivateScope`, `DeactivateScope` |
| `-ScopeId` | Context | Scope network address (e.g., `192.168.1.0`) |
| `-IPAddress` | Reservation | IP address to reserve |
| `-MACAddress` | AddReservation | Client MAC address (`AA-BB-CC-DD-EE-FF` format) |
| `-ClientName` | No | Friendly name for the reservation |
| `-ComputerName` | No | DHCP server to manage (default: local) |

## Notes

- MAC addresses can be formatted as `AA-BB-CC-DD-EE-FF` or `AABBCCDDEEFF` — the script normalizes them.
- Deactivating a scope stops the server from issuing leases but does not revoke existing ones.
- Only one DHCP server should be authoritative for any given subnet.
