#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage BitLocker drive encryption: enable, disable, suspend, and manage keys.
.NOTES
    See README.md for usage examples and important notes on recovery key backup.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Status','Enable','Suspend','Resume','Disable','GetKey','BackupToAD')]
    [string]$Action,

    [Parameter()]
    [string]$Drive = 'C:',

    [Parameter()]
    [switch]$UsePIN
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

# Normalize drive letter
$Drive = $Drive.TrimEnd('\').ToUpper()
if ($Drive -notmatch ':$') { $Drive += ':' }

switch ($Action) {

    'Status' {
        $volumes = if ($Drive) { Get-BitLockerVolume -MountPoint $Drive -ErrorAction SilentlyContinue }
                   else { Get-BitLockerVolume }
        $volumes | Select-Object MountPoint, VolumeStatus, EncryptionPercentage,
            ProtectionStatus, LockStatus, EncryptionMethod |
            Format-Table -AutoSize
    }

    'Enable' {
        $vol = Get-BitLockerVolume -MountPoint $Drive -ErrorAction SilentlyContinue
        if ($vol.VolumeStatus -eq 'FullyEncrypted') {
            Write-Status "Drive $Drive is already fully encrypted." 'WARN'; return
        }
        if ($PSCmdlet.ShouldProcess($Drive, 'Enable BitLocker')) {
            Write-Status "Adding recovery password protector to $Drive..." 'WARN'
            Add-BitLockerKeyProtector -MountPoint $Drive -RecoveryPasswordProtector | Out-Null

            if ($UsePIN) {
                $pin = Read-Host "Enter BitLocker PIN (min 6 digits)" -AsSecureString
                Add-BitLockerKeyProtector -MountPoint $Drive -TPMAndPinProtector -Pin $pin | Out-Null
                Write-Status "TPM+PIN protector added."
            } else {
                Add-BitLockerKeyProtector -MountPoint $Drive -TpmProtector | Out-Null
                Write-Status "TPM protector added."
            }

            Enable-BitLocker -MountPoint $Drive -EncryptionMethod XtsAes256 -SkipHardwareTest | Out-Null
            Write-Status "BitLocker encryption started on $Drive. Encryption runs in the background." 'SUCCESS'
            Write-Status "IMPORTANT: Save the recovery key below before rebooting." 'WARN'

            # Show recovery key immediately
            $recoveryKey = (Get-BitLockerVolume -MountPoint $Drive).KeyProtector |
                           Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
            Write-Host "`n  Recovery Password ID:  $($recoveryKey.KeyProtectorId)"
            Write-Host "  Recovery Password:     $($recoveryKey.RecoveryPassword)`n"
        }
    }

    'Suspend' {
        if ($PSCmdlet.ShouldProcess($Drive, 'Suspend BitLocker')) {
            Suspend-BitLocker -MountPoint $Drive -RebootCount 1
            Write-Status "BitLocker suspended on $Drive for 1 reboot (auto-resumes after)." 'WARN'
        }
    }

    'Resume' {
        if ($PSCmdlet.ShouldProcess($Drive, 'Resume BitLocker')) {
            Resume-BitLocker -MountPoint $Drive
            Write-Status "BitLocker protection resumed on $Drive." 'SUCCESS'
        }
    }

    'Disable' {
        Write-Status "Disabling BitLocker will DECRYPT $Drive. This is a long background process." 'WARN'
        if ($PSCmdlet.ShouldProcess($Drive, 'Disable BitLocker (decrypt)')) {
            Disable-BitLocker -MountPoint $Drive
            Write-Status "Decryption started on $Drive. Check progress with: -Action Status" 'SUCCESS'
        }
    }

    'GetKey' {
        Write-Status "Recovery key(s) for $Drive:"
        $vol = Get-BitLockerVolume -MountPoint $Drive -ErrorAction Stop
        $vol.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' } |
            Select-Object @{N='ID';E={$_.KeyProtectorId}}, RecoveryPassword |
            Format-List
    }

    'BackupToAD' {
        $vol = Get-BitLockerVolume -MountPoint $Drive -ErrorAction Stop
        $protectors = $vol.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
        if (-not $protectors) {
            throw "No recovery password protector found on $Drive. Enable BitLocker first."
        }
        foreach ($p in $protectors) {
            if ($PSCmdlet.ShouldProcess($Drive, "Backup key $($p.KeyProtectorId) to AD")) {
                Backup-BitLockerKeyProtector -MountPoint $Drive -KeyProtectorId $p.KeyProtectorId
                Write-Status "Recovery key $($p.KeyProtectorId) backed up to Active Directory." 'SUCCESS'
            }
        }
    }
}
