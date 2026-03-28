# Windows Administration Scripts

This directory contains PowerShell scripts for common Windows system administration tasks.

## Requirements

- Windows 10 / Windows Server 2016 or later
- PowerShell 5.1 or PowerShell 7+
- Scripts that manage users, services, or system settings must be run as **Administrator**
- Some scripts require RSAT modules (Active Directory, DNS, DHCP, IIS) — see individual READMEs

## Task Index

### User & Identity Management

| Task | Script | Description |
|------|--------|-------------|
| [User Management](user-management/) | `Manage-LocalUsers.ps1` | Create, modify, disable, and remove local user accounts |
| [Group Management](group-management/) | `Manage-LocalGroups.ps1` | Create, list, and manage local security group membership |
| [Active Directory Users](active-directory-users/) | `Manage-ADUsers.ps1` | Create, disable, unlock, and move AD user accounts (RSAT) |
| [Active Directory Computers](active-directory-computers/) | `Manage-ADComputers.ps1` | List, disable, move, and remove AD computer objects (RSAT) |
| [Group Policy](group-policy/) | `Manage-GroupPolicy.ps1` | List, back up, force-apply, and report on GPOs |
| [Credential Manager](credential-manager/) | `Manage-CredentialManager.ps1` | Add, list, and remove Windows Credential Manager entries |
| [Audit Policy](audit-policy/) | `Set-AuditPolicy.ps1` | Configure local audit policy for Success/Failure events |
| [Local Security Policy](local-security-policy/) | `Set-LocalSecurityPolicy.ps1` | Set password policy, lockout policy, and logon rights |

### Software & Features

| Task | Script | Description |
|------|--------|-------------|
| [Software Install](software-install/) | `Install-Software.ps1` | Install software packages using winget |
| [Windows Updates](windows-updates/) | `Invoke-WindowsUpdates.ps1` | Check for and install Windows updates |
| [Windows Features](windows-features/) | `Manage-WindowsFeatures.ps1` | Enable and disable optional Windows features (DISM/RSAT) |
| [IIS Management](iis-management/) | `Manage-IIS.ps1` | Create, start, stop, and configure IIS websites and app pools |
| [WSUS Client](wsus-client/) | `Set-WSUSClient.ps1` | Set WSUS server for update delivery and trigger detection |
| [Windows Activation](windows-activation/) | `Manage-WindowsActivation.ps1` | Check and manage Windows licenses including KMS |

### Storage & Disk

| Task | Script | Description |
|------|--------|-------------|
| [Disk Cleanup](disk-cleanup/) | `Invoke-DiskCleanup.ps1` | Remove temporary files, clear caches, report disk usage |
| [Disk Partitions](disk-partition/) | `Manage-DiskPartitions.ps1` | Create, format, resize, and assign drive letters to partitions |
| [Storage Spaces](storage-spaces/) | `Manage-StorageSpaces.ps1` | Create and manage Windows Storage Spaces pools and virtual disks |
| [Shadow Copies](shadow-copy/) | `Manage-ShadowCopies.ps1` | Create and manage VSS shadow copies (volume snapshots) |
| [Backup & Restore](backup-restore/) | `Invoke-Backup.ps1` | Backup and restore directories using Robocopy |
| [NFS Client](nfs-client/) | `Manage-NFSClient.ps1` | Install NFS client and mount NFS shares on Windows |
| [Network Drive Mapping](network-drive-mapping/) | `Manage-NetworkDrives.ps1` | Map and disconnect persistent network drives |

### Networking

| Task | Script | Description |
|------|--------|-------------|
| [Network Configuration](network-configuration/) | `Set-NetworkConfiguration.ps1` | Set static IP addresses, DNS servers, and default gateways |
| [Firewall Management](firewall-management/) | `Manage-FirewallRules.ps1` | Add, remove, enable, disable, and list Windows Firewall rules |
| [NTP Configuration](ntp-configuration/) | `Set-NTPConfiguration.ps1` | Configure NTP servers and force time synchronization |
| [Proxy Configuration](proxy-configuration/) | `Set-ProxyConfiguration.ps1` | Set system-wide proxy for WinHTTP and WinINET |
| [TCP/IP Settings](tcp-ip-settings/) | `Set-TCPIPSettings.ps1` | Tune TCP auto-tuning, MTU, and NIC offload settings |
| [DNS Server](dns-server/) | `Manage-DNSServer.ps1` | Manage DNS zones and records on a Windows DNS server (RSAT) |
| [DHCP Server](dhcp-server/) | `Manage-DHCPServer.ps1` | Manage DHCP scopes, leases, and reservations (RSAT) |
| [WinRM Configuration](winrm-configuration/) | `Set-WinRMConfiguration.ps1` | Enable and configure Windows Remote Management |

### Security & Certificates

| Task | Script | Description |
|------|--------|-------------|
| [SSL Certificates](ssl-certificate/) | `Manage-SSLCertificates.ps1` | Request, import, export, and check expiry of SSL certificates |
| [Certificate Management](certificate-management/) | `Manage-Certificates.ps1` | Manage certificates in the Windows certificate store |
| [BitLocker](bitlocker/) | `Manage-BitLocker.ps1` | Enable, suspend, and manage BitLocker drive encryption |
| [Windows Defender](windows-defender/) | `Invoke-DefenderManagement.ps1` | Run scans, update definitions, and manage exclusions |
| [Remote Desktop Config](remote-desktop-config/) | `Set-RemoteDesktop.ps1` | Enable/disable RDP, configure NLA, manage allowed users |
| [NTFS Permissions](ntfs-permissions/) | `Set-NTFSPermissions.ps1` | Add, remove, and replace NTFS ACLs on files and folders |
| [File Share Management](file-share-management/) | `Manage-FileShares.ps1` | Create, modify, and remove SMB file shares |

### Monitoring, Alerting & Diagnostics

| Task | Script | Description |
|------|--------|-------------|
| [Event Log Query](event-log-query/) | `Get-EventLogEntries.ps1` | Search and export Windows Event Log entries with filters |
| [Event Log Management](event-log-management/) | `Manage-EventLogs.ps1` | Clear, resize, back up, and create Windows Event Logs |
| [Performance Monitoring](performance-monitoring/) | `Get-PerformanceMetrics.ps1` | Collect CPU, memory, disk, and network performance metrics |
| [Disk Space Alerting](disk-space-alert/) | `Get-DiskSpaceAlert.ps1` | Alert when drive usage exceeds warn/alert thresholds; logs to network share |
| [Service Health Monitor](service-health-monitor/) | `Get-ServiceHealth.ps1` | Alert on stopped auto-start services; optional auto-restart |
| [Certificate Expiry Monitor](certificate-expiry-monitor/) | `Get-CertificateExpiry.ps1` | Alert on certificates approaching expiry in any cert store |
| [Process Management](process-management/) | `Manage-Processes.ps1` | List, filter, kill, and diagnose Windows processes |
| [System Information](system-info/) | `Get-SystemInfo.ps1` | Collect hardware, OS, software, and network information |
| [Memory Diagnostics](memory-diagnostics/) | `Invoke-MemoryDiagnostic.ps1` | Schedule Windows Memory Diagnostic and retrieve results |
| [Hyper-V Management](hyper-v-management/) | `Manage-HyperV.ps1` | Start, stop, checkpoint, and export Hyper-V virtual machines |

### System Configuration

| Task | Script | Description |
|------|--------|-------------|
| [Service Management](service-management/) | `Manage-Services.ps1` | Start, stop, restart, and configure Windows services |
| [Scheduled Tasks](scheduled-tasks/) | `Manage-ScheduledTasks.ps1` | Create, list, run, and remove Windows Scheduled Tasks |
| [Registry Management](registry-management/) | `Manage-Registry.ps1` | Read, write, delete, and export Windows registry keys |
| [Environment Variables](environment-variables/) | `Manage-EnvironmentVariables.ps1` | Get, set, and remove system and user environment variables |
| [Hosts File](hosts-file/) | `Manage-HostsFile.ps1` | Add, remove, and list entries in the Windows hosts file |
| [Power Management](power-management/) | `Set-PowerManagement.ps1` | Configure power plans, sleep timeouts, and shutdown policies |
| [Printer Management](printer-management/) | `Manage-Printers.ps1` | Install, list, remove printers, and manage print queues |

### Shared Modules

| Module | File | Description |
|--------|------|-------------|
| [Logging Module](shared/) | `Write-Log.ps1` | Shared logging to console, local file, network share, and alert log |

## Adding a New Task

1. Create a new folder: `windows/<task-name>/`
2. Add a `README.md` using this status header template at the top:

```markdown
> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —
```

3. Add your PowerShell script with inline comments explaining each section.
4. Document all parameters in the README.
