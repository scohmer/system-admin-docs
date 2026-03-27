> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Firewall Management

Add, remove, enable, disable, and list Windows Firewall rules.

## Script

`Manage-FirewallRules.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# List all firewall rules
.\Manage-FirewallRules.ps1 -Action List

# List only enabled inbound rules
.\Manage-FirewallRules.ps1 -Action List -Direction Inbound -Enabled True

# Show details of a specific rule
.\Manage-FirewallRules.ps1 -Action Show -RuleName "My App Rule"

# Add an inbound allow rule for a TCP port
.\Manage-FirewallRules.ps1 -Action Add `
  -RuleName "Allow HTTPS Inbound" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 443 `
  -RuleAction Allow

# Add a block rule for a remote IP
.\Manage-FirewallRules.ps1 -Action Add `
  -RuleName "Block Bad Actor" `
  -Direction Inbound `
  -RemoteAddress "10.20.30.40" `
  -RuleAction Block

# Enable or disable a rule
.\Manage-FirewallRules.ps1 -Action Enable  -RuleName "My App Rule"
.\Manage-FirewallRules.ps1 -Action Disable -RuleName "My App Rule"

# Remove a rule
.\Manage-FirewallRules.ps1 -Action Remove -RuleName "My App Rule"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | One of: `List`, `Show`, `Add`, `Enable`, `Disable`, `Remove` |
| `-RuleName` | Yes (except List) | Display name of the firewall rule |
| `-Direction` | No | `Inbound` or `Outbound` (default: `Inbound`) |
| `-Protocol` | No | `TCP`, `UDP`, or `Any` (default: `Any`) |
| `-LocalPort` | No | Local port number (e.g., `80`, `443`, `3389`) |
| `-RemoteAddress` | No | Remote IP or range to match (e.g., `192.168.1.0/24`) |
| `-RuleAction` | No | `Allow` or `Block` (default: `Allow`) |
| `-Enabled` | No | Filter for `List`: `True` or `False` |

## Notes

- Rule names must be unique. The script will error if a rule with the same name already exists.
- Removing rules is permanent. Verify the rule name with `-Action List` first.
- Port `3389` is Remote Desktop — removing or blocking it will cut off RDP access.
