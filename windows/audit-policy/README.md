> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Audit Policy

Manages Windows Advanced Audit Policy configuration using `auditpol.exe`. Supports querying current policy, configuring subcategory audit settings, generating reports, and resetting to defaults.

## Script

`Set-AuditPolicy.ps1`

## Usage

```powershell
# Get all current audit policy settings
.\Set-AuditPolicy.ps1 -Action Get

# Get policy for a specific category
.\Set-AuditPolicy.ps1 -Action Get -Category "Logon/Logoff"

# Enable success and failure auditing for a subcategory
.\Set-AuditPolicy.ps1 -Action Set -Subcategory "Logon" -AuditType Both

# Enable only failure auditing
.\Set-AuditPolicy.ps1 -Action Set -Subcategory "Logon" -AuditType Failure

# Export current policy to a CSV report
.\Set-AuditPolicy.ps1 -Action Report -ReportPath "C:\Reports\AuditPolicy.csv"

# Reset all audit policy settings to defaults
.\Set-AuditPolicy.ps1 -Action Reset
```

## Parameters

| Parameter      | Type   | Required | Description                                                              |
|----------------|--------|----------|--------------------------------------------------------------------------|
| `-Action`      | String | Yes      | `Get`, `Set`, `Report`, `Reset`                                          |
| `-Category`    | String | No       | Audit category name (e.g. `Logon/Logoff`, `Object Access`)               |
| `-Subcategory` | String | No       | Specific subcategory name (e.g. `Logon`, `File System`)                  |
| `-AuditType`   | String | No       | `Success`, `Failure`, `Both`, `None`                                     |
| `-ReportPath`  | String | No       | File path for the exported policy report (`.csv`)                        |

## Notes

- Requires administrator privileges.
- Common categories: `Account Logon`, `Account Management`, `Detailed Tracking`, `DS Access`, `Logon/Logoff`, `Object Access`, `Policy Change`, `Privilege Use`, `System`.
- Subcategory names must match exactly as shown in `auditpol /get /category:*` output.
- `Reset` calls `auditpol /clear /y` which disables all audit settings — use with caution in production.
- Changes take effect immediately without requiring a reboot or group policy refresh.
