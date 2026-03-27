> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Credential Manager

List, add, and remove stored credentials in Windows Credential Manager (both Windows and Generic credentials).

## Script

`Manage-CredentialManager.ps1`

## Usage

```powershell
# List all stored credentials
.\Manage-CredentialManager.ps1 -Action List

# List only Windows credentials
.\Manage-CredentialManager.ps1 -Action List -Type Windows

# List only Generic credentials
.\Manage-CredentialManager.ps1 -Action List -Type Generic

# Add or update a generic credential
.\Manage-CredentialManager.ps1 -Action Add -Target "\\fileserver\share" -UserName "DOMAIN\user"

# Add a credential non-interactively (for scripts — use with caution)
.\Manage-CredentialManager.ps1 -Action Add -Target "MyApp" -UserName "svcaccount" -PasswordPlain "P@ssword"

# Remove a credential by target name
.\Manage-CredentialManager.ps1 -Action Remove -Target "\\fileserver\share"

# Remove all stored credentials (use with extreme caution)
.\Manage-CredentialManager.ps1 -Action RemoveAll
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `List`, `Add`, `Remove`, `RemoveAll` |
| `-Target` | Add/Remove | Credential target name (server name, URL, or arbitrary label) |
| `-UserName` | Add | Username to store |
| `-Type` | No | `Windows`, `Generic` (default: `Generic`) |
| `-PasswordPlain` | No | Password as plain text (script use only — prompts interactively if omitted) |

## Notes

- Uses `cmdkey.exe` for Add/Remove operations (built-in Windows tool).
- `List` uses the `CredEnumerateW` Win32 API via .NET P/Invoke for richer output than `cmdkey /list`.
- Credentials are stored per-user in the Windows Vault — they are not shared across user accounts.
- Avoid storing credentials as plain text in scripts; use `-PasswordPlain` only in secured automation contexts.
