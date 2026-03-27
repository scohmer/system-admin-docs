> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Certificate Management

Manage Windows certificate stores using PowerShell. Supports listing certificates, exporting (PFX or CER), importing, deleting, checking expiry, and creating self-signed certificates.

## Script

`Manage-Certificates.ps1`

Uses the PowerShell `Cert:` drive and standard certificate cmdlets. Some operations (LocalMachine store) require Administrator privileges.

## Usage

```powershell
# List all certificates in the Personal store (LocalMachine)
.\Manage-Certificates.ps1 -Action List -StoreLocation LocalMachine -StoreName My

# List certificates in CurrentUser root store
.\Manage-Certificates.ps1 -Action List -StoreLocation CurrentUser -StoreName Root

# Check for certificates expiring within 30 days
.\Manage-Certificates.ps1 -Action CheckExpiry -StoreLocation LocalMachine -StoreName My -DaysWarning 30

# Export a certificate as PFX (with private key)
.\Manage-Certificates.ps1 -Action Export -StoreLocation LocalMachine -StoreName My -Thumbprint "ABC123..." -ExportPath "C:\Certs\mycert.pfx" -Password (Read-Host -AsSecureString "PFX Password")

# Export a certificate as CER (public key only)
.\Manage-Certificates.ps1 -Action Export -StoreLocation LocalMachine -StoreName My -Thumbprint "ABC123..." -ExportPath "C:\Certs\mycert.cer"

# Import a PFX certificate
.\Manage-Certificates.ps1 -Action Import -StoreLocation LocalMachine -StoreName My -ExportPath "C:\Certs\mycert.pfx" -Password (Read-Host -AsSecureString "PFX Password")

# Delete a certificate by thumbprint
.\Manage-Certificates.ps1 -Action Delete -StoreLocation LocalMachine -StoreName My -Thumbprint "ABC123..."

# Create a self-signed certificate
.\Manage-Certificates.ps1 -Action Request -SubjectName "CN=myserver.corp.local" -StoreLocation LocalMachine -StoreName My
```

## Parameters

| Parameter        | Type           | Required | Description                                                     |
|------------------|----------------|----------|-----------------------------------------------------------------|
| `-Action`        | String         | Yes      | Action: List, Export, Import, Delete, CheckExpiry, Request      |
| `-StoreLocation` | String         | No       | LocalMachine or CurrentUser (default: LocalMachine)             |
| `-StoreName`     | String         | No       | Store name: My, Root, CA, TrustedPublisher, etc. (default: My) |
| `-Thumbprint`    | String         | Varies   | Certificate thumbprint (for Export/Delete)                      |
| `-ExportPath`    | String         | Varies   | File path for Export/Import (.pfx or .cer)                      |
| `-Password`      | SecureString   | No       | Password for PFX operations                                     |
| `-DaysWarning`   | Int            | No       | Days threshold for CheckExpiry (default: 30)                    |
| `-SubjectName`   | String         | Varies   | Subject name for self-signed cert (e.g. CN=myserver)            |

## Notes

- LocalMachine store operations require Administrator privileges
- Export as .cer (no -Password) exports the public certificate only (no private key)
- Export as .pfx (with -Password) exports the full certificate with private key
- Self-signed certificates are not trusted by default; add to Trusted Root if needed
- `CheckExpiry` outputs warnings for certificates expiring within the specified window
- Use `-WhatIf` to preview Delete and Import actions
