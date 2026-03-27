> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Local Security Policy

View and configure local security policy settings including password policy, account lockout, and user rights assignments.

## Script

`Set-LocalSecurityPolicy.ps1`

## Usage

```powershell
# Export current security policy to a file
.\Set-LocalSecurityPolicy.ps1 -Action Export -ExportPath "C:\Backup\secpol.cfg"

# Import a security policy configuration
.\Set-LocalSecurityPolicy.ps1 -Action Import -ImportPath "C:\Backup\secpol.cfg"

# Get password policy settings
.\Set-LocalSecurityPolicy.ps1 -Action GetPasswordPolicy

# Set password policy (minimum length 12, max age 90 days, complexity required)
.\Set-LocalSecurityPolicy.ps1 -Action SetPasswordPolicy -MinPasswordLength 12 -MaxPasswordAge 90 -PasswordComplexity 1

# Get account lockout policy
.\Set-LocalSecurityPolicy.ps1 -Action GetLockoutPolicy

# Set account lockout (5 attempts, 30 min lockout duration)
.\Set-LocalSecurityPolicy.ps1 -Action SetLockoutPolicy -LockoutThreshold 5 -LockoutDuration 30 -LockoutWindow 30

# List user rights assignments (e.g., who can log on locally)
.\Set-LocalSecurityPolicy.ps1 -Action GetUserRights -Right SeInteractiveLogonRight
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `Export`, `Import`, `GetPasswordPolicy`, `SetPasswordPolicy`, `GetLockoutPolicy`, `SetLockoutPolicy`, `GetUserRights` |
| `-ExportPath` | Export | File path for policy export |
| `-ImportPath` | Import | File path for policy import |
| `-MinPasswordLength` | SetPasswordPolicy | Minimum password length (0–14) |
| `-MaxPasswordAge` | SetPasswordPolicy | Maximum password age in days (0 = never expires) |
| `-PasswordComplexity` | SetPasswordPolicy | `1` = enabled, `0` = disabled |
| `-LockoutThreshold` | SetLockoutPolicy | Failed logon attempts before lockout (0 = never) |
| `-LockoutDuration` | SetLockoutPolicy | Lockout duration in minutes (0 = until admin unlocks) |
| `-LockoutWindow` | SetLockoutPolicy | Reset lockout counter after N minutes |
| `-Right` | GetUserRights | Security right constant (e.g., `SeInteractiveLogonRight`) |

## Notes

- Uses `secedit.exe` for export/import and `net accounts` for password/lockout policy queries.
- On domain members, domain policy overrides local policy for password and lockout settings.
- Common rights: `SeInteractiveLogonRight` (local logon), `SeRemoteInteractiveLogonRight` (RDP), `SeShutdownPrivilege` (shutdown).
