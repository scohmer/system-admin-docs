> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Group Policy Management

Manage Group Policy Objects (GPOs) using PowerShell and the RSAT GroupPolicy module. Supports listing GPOs, forcing remote updates, generating HTML reports, backing up GPOs, and retrieving Resultant Set of Policy (RSoP) data.

## Script

`Manage-GroupPolicy.ps1`

Requires the RSAT Group Policy Management Tools. Run on a domain-joined machine with appropriate permissions.

## Usage

```powershell
# List all GPOs in the domain
.\Manage-GroupPolicy.ps1 -Action List

# Force a Group Policy update on a remote computer
.\Manage-GroupPolicy.ps1 -Action ForceUpdate -ComputerName WORKSTATION01

# Generate an HTML report for a specific GPO
.\Manage-GroupPolicy.ps1 -Action Report -GPOName "Default Domain Policy" -ReportPath "C:\Reports\GPO-Report.html"

# Backup all GPOs to a folder
.\Manage-GroupPolicy.ps1 -Action Backup -BackupPath "C:\GPOBackups"

# Backup a specific GPO
.\Manage-GroupPolicy.ps1 -Action Backup -GPOName "Default Domain Policy" -BackupPath "C:\GPOBackups"

# Get Resultant Set of Policy for a remote computer
.\Manage-GroupPolicy.ps1 -Action GetResultantSet -ComputerName WORKSTATION01 -ReportPath "C:\Reports\RSoP.html"
```

## Parameters

| Parameter      | Type   | Required | Description                                                    |
|----------------|--------|----------|----------------------------------------------------------------|
| `-Action`      | String | Yes      | Action to perform: List, ForceUpdate, Report, Backup, GetResultantSet |
| `-ComputerName`| String | Varies   | Target remote computer name                                    |
| `-GPOName`     | String | No       | Name of a specific GPO (omit to target all GPOs)              |
| `-BackupPath`  | String | Varies   | Folder path for GPO backups                                    |
| `-ReportPath`  | String | Varies   | File path for HTML report output                               |

## Notes

- Requires RSAT: Group Policy Management Tools
- Install RSAT: `Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0`
- `ForceUpdate` uses `Invoke-GPUpdate` which requires WinRM/PS Remoting on the target
- `GetResultantSet` requires the target computer to be online and accessible
- Backup files are stored per-GPO in subfolders; a manifest XML is included automatically
- Use `-WhatIf` to preview actions without making changes
