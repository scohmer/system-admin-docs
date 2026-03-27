> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — SSL Certificate Management

Request, import, export, delete, and check expiry of SSL/TLS certificates in the Windows certificate store.

## Script

`Manage-SSLCertificates.ps1`

**Must be run as Administrator for Machine store operations.**

## Usage

```powershell
# List all certificates in LocalMachine\My
.\Manage-SSLCertificates.ps1 -Action List

# List certificates expiring within 30 days
.\Manage-SSLCertificates.ps1 -Action ListExpiring -DaysWarning 30

# Create a self-signed certificate
.\Manage-SSLCertificates.ps1 -Action CreateSelfSigned `
  -Subject "CN=myserver.corp.local" `
  -SANs "myserver.corp.local","myserver","192.168.1.10"

# Export a certificate to PFX (includes private key)
.\Manage-SSLCertificates.ps1 -Action ExportPFX `
  -Thumbprint "A1B2C3..." -ExportPath "C:\Certs\myserver.pfx"

# Export certificate only (no private key) as CER
.\Manage-SSLCertificates.ps1 -Action ExportCER `
  -Thumbprint "A1B2C3..." -ExportPath "C:\Certs\myserver.cer"

# Import a PFX certificate
.\Manage-SSLCertificates.ps1 -Action ImportPFX -ExportPath "C:\Certs\myserver.pfx"

# Delete a certificate by thumbprint
.\Manage-SSLCertificates.ps1 -Action Delete -Thumbprint "A1B2C3..."
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `ListExpiring`, `CreateSelfSigned`, `ExportPFX`, `ExportCER`, `ImportPFX`, `Delete` |
| `-Thumbprint` | Context | Certificate thumbprint (from `List`) |
| `-Subject` | CreateSelfSigned | CN for the certificate (e.g., `CN=server.corp.local`) |
| `-SANs` | No | Subject Alternative Names (array of DNS names and IPs) |
| `-ExportPath` | Export/Import | File path for PFX or CER file |
| `-DaysWarning` | ListExpiring | Flag certs expiring within N days (default: `30`) |
| `-StoreLocation` | No | `LocalMachine` (default) or `CurrentUser` |
| `-StoreName` | No | `My` (default), `Root`, `CA`, `TrustedPublisher` |

## Notes

- PFX export includes the private key and requires a password. The script prompts securely.
- Self-signed certificates are for testing only — use your org's PKI for production.
- Import a CA certificate into `Root` to make it trusted system-wide.
