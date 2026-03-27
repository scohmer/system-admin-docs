> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — BitLocker Management

Enable, suspend, resume, and manage BitLocker drive encryption, including recovery key backup.

## Script

`Manage-BitLocker.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# Check BitLocker status on all drives
.\Manage-BitLocker.ps1 -Action Status

# Check status for a specific drive
.\Manage-BitLocker.ps1 -Action Status -Drive C:

# Enable BitLocker on C: with a recovery password protector
.\Manage-BitLocker.ps1 -Action Enable -Drive C:

# Enable on D: with TPM + PIN
.\Manage-BitLocker.ps1 -Action Enable -Drive D: -UsePIN

# Suspend BitLocker (for patching — auto-resumes after 1 reboot)
.\Manage-BitLocker.ps1 -Action Suspend -Drive C:

# Resume BitLocker (re-enable after suspension)
.\Manage-BitLocker.ps1 -Action Resume -Drive C:

# Disable BitLocker (decrypt the drive — takes time)
.\Manage-BitLocker.ps1 -Action Disable -Drive D:

# Show recovery key for a drive
.\Manage-BitLocker.ps1 -Action GetKey -Drive C:

# Back up recovery key to Active Directory
.\Manage-BitLocker.ps1 -Action BackupToAD -Drive C:
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `Status`, `Enable`, `Suspend`, `Resume`, `Disable`, `GetKey`, `BackupToAD` |
| `-Drive` | Context | Drive letter (e.g., `C:`, `D:`). Default: `C:` for Status |
| `-UsePIN` | No | Prompt for a PIN in addition to TPM during Enable |

## Notes

- `Enable` adds a recovery password protector — **save the recovery key before encrypting**.
- `Suspend` pauses BitLocker for the next reboot only (useful before firmware/BIOS updates).
- `Disable` begins decryption, which is a long background process. The drive is accessible during decryption.
- `BackupToAD` requires the computer to be domain-joined and the AD schema to support BitLocker recovery.
