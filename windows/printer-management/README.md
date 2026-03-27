> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Printer Management

List, install, remove, and manage printers and print queues on Windows.

## Script

`Manage-Printers.ps1`

**Must be run as Administrator for install/remove/clear operations.**

## Usage

```powershell
# List all installed printers
.\Manage-Printers.ps1 -Action List

# Show queue for a specific printer
.\Manage-Printers.ps1 -Action GetQueue -PrinterName "HP LaserJet"

# Set a printer as default
.\Manage-Printers.ps1 -Action SetDefault -PrinterName "HP LaserJet"

# Clear all jobs from a print queue
.\Manage-Printers.ps1 -Action ClearQueue -PrinterName "HP LaserJet"

# Add a TCP/IP network printer
.\Manage-Printers.ps1 -Action Add `
  -PrinterName "HP LaserJet Lobby" `
  -PortAddress "192.168.1.100" `
  -DriverName "HP Universal Printing PCL 6"

# Remove a printer
.\Manage-Printers.ps1 -Action Remove -PrinterName "HP LaserJet Lobby"

# List available printer drivers
.\Manage-Printers.ps1 -Action ListDrivers
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `Add`, `Remove`, `SetDefault`, `GetQueue`, `ClearQueue`, `ListDrivers` |
| `-PrinterName` | Context | Display name of the printer |
| `-PortAddress` | Add | IP address or hostname of the network printer |
| `-DriverName` | Add | Exact driver name (use `ListDrivers` to find) |

## Notes

- The printer driver must be installed on the system before adding a printer that uses it.
- `ClearQueue` cancels all pending and paused print jobs without waiting for completion.
- For shared print servers, manage printers on the print server itself rather than per-client.
