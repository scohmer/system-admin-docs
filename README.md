# System Administration Documentation & Scripts

This repository contains documentation, scripts, and automation playbooks for common system administration tasks on Windows and Linux.

> **Important:** All scripts and playbooks require individual verification and senior admin board approval before use in production. Check the status header in each task folder's README before executing any script.

## Repository Structure

- [windows/](windows/) — PowerShell scripts for Windows administration
- [linux/](linux/) — Ansible playbooks for Linux administration (designed for execution from an Ansible controller)

---

## Approval Process

Before any script or playbook is used in a production environment:

1. **Verification** — A System Administrator must test the script in a non-production environment and mark it **Verified**.
2. **Approval** — A board of Senior System Administrators must review and mark it **Approved** before production use.

Each task folder displays the current status at the top of its README.

---

## Windows — How do I...

### User & Identity Management

| Task | Description |
|------|-------------|
| [... manage local users?](windows/user-management/) | Create, modify, disable, and remove local Windows user accounts |
| [... manage local groups?](windows/group-management/) | Create, list, and manage local security group membership |
| [... manage Active Directory users?](windows/active-directory-users/) | Create, disable, unlock, and move AD user accounts (requires RSAT) |
| [... manage Active Directory computers?](windows/active-directory-computers/) | List, disable, move, and remove AD computer objects (requires RSAT) |
| [... manage Group Policy?](windows/group-policy/) | List, back up, force-apply, and report on GPOs |
| [... manage Windows credentials?](windows/credential-manager/) | Add, list, and remove entries in Windows Credential Manager |
| [... configure audit policy?](windows/audit-policy/) | Configure local security audit policy for Success/Failure events |
| [... configure local security policy?](windows/local-security-policy/) | Set password policy, lockout policy, and logon rights via secedit |

### Software & Features

| Task | Description |
|------|-------------|
| [... install software?](windows/software-install/) | Install software packages using winget |
| [... install Windows updates?](windows/windows-updates/) | Check for and install Windows updates via PowerShell |
| [... manage Windows features?](windows/windows-features/) | Enable and disable optional Windows features (DISM/RSAT) |
| [... manage IIS websites?](windows/iis-management/) | Create, start, stop, and configure IIS websites and app pools |
| [... configure WSUS client?](windows/wsus-client/) | Set a WSUS server for update delivery and trigger detection |
| [... manage Windows activation?](windows/windows-activation/) | Check and activate Windows licenses including KMS configuration |

### Storage & Disk

| Task | Description |
|------|-------------|
| [... clean up disk space?](windows/disk-cleanup/) | Remove temporary files, clear caches, and report disk usage |
| [... manage disk partitions?](windows/disk-partition/) | Create, format, resize, and assign drive letters to disk partitions |
| [... manage Storage Spaces?](windows/storage-spaces/) | Create and manage Windows Storage Spaces pools and virtual disks |
| [... manage shadow copies?](windows/shadow-copy/) | Create and manage VSS shadow copies (volume snapshots) |
| [... backup files?](windows/backup-restore/) | Backup and restore directories using Robocopy |
| [... manage NFS client?](windows/nfs-client/) | Install NFS client and mount NFS shares on Windows |
| [... map network drives?](windows/network-drive-mapping/) | Map and disconnect persistent network drives |

### Networking

| Task | Description |
|------|-------------|
| [... configure network settings?](windows/network-configuration/) | Set static IP addresses, DNS servers, and default gateways |
| [... manage firewall rules?](windows/firewall-management/) | Add, remove, enable, disable, and list Windows Firewall rules |
| [... configure NTP time sync?](windows/ntp-configuration/) | Configure NTP servers and force time synchronization via w32tm |
| [... configure system proxy?](windows/proxy-configuration/) | Set system-wide proxy for WinHTTP and WinINET |
| [... configure TCP/IP settings?](windows/tcp-ip-settings/) | Tune TCP auto-tuning, RSS, MTU, and NIC offload settings |
| [... manage DNS server?](windows/dns-server/) | Manage DNS zones and records on a Windows DNS server (RSAT) |
| [... manage DHCP server?](windows/dhcp-server/) | Manage DHCP scopes, leases, and reservations (RSAT) |
| [... configure WinRM?](windows/winrm-configuration/) | Enable and configure Windows Remote Management for PowerShell remoting |

### Security & Certificates

| Task | Description |
|------|-------------|
| [... manage SSL certificates?](windows/ssl-certificate/) | Request, import, export, and check expiry of SSL certificates |
| [... manage certificate store?](windows/certificate-management/) | List, import, export, and delete certificates from the Windows cert store |
| [... configure BitLocker?](windows/bitlocker/) | Enable, suspend, and manage BitLocker drive encryption |
| [... manage Windows Defender?](windows/windows-defender/) | Run scans, update definitions, and manage exclusions |
| [... configure Remote Desktop?](windows/remote-desktop-config/) | Enable/disable RDP, configure NLA, manage allowed users |
| [... manage NTFS permissions?](windows/ntfs-permissions/) | Add, remove, and replace NTFS ACLs on files and folders |
| [... manage file shares?](windows/file-share-management/) | Create, modify, and remove SMB file shares and share permissions |

### Monitoring & Diagnostics

| Task | Description |
|------|-------------|
| [... query event logs?](windows/event-log-query/) | Search and export Windows Event Log entries with filters |
| [... manage event logs?](windows/event-log-management/) | Clear, resize, back up, and create Windows Event Logs |
| [... monitor performance?](windows/performance-monitoring/) | Collect CPU, memory, disk, and network performance metrics |
| [... manage processes?](windows/process-management/) | List, filter, kill, and diagnose Windows processes |
| [... generate a system report?](windows/system-info/) | Collect hardware, OS, software, and network information |
| [... run memory diagnostics?](windows/memory-diagnostics/) | Schedule Windows Memory Diagnostic and retrieve results |

### System Configuration

| Task | Description |
|------|-------------|
| [... manage Windows services?](windows/service-management/) | Start, stop, restart, and configure Windows services |
| [... manage scheduled tasks?](windows/scheduled-tasks/) | Create, list, run, and remove Windows Scheduled Tasks |
| [... manage the registry?](windows/registry-management/) | Read, write, delete, and export Windows registry keys and values |
| [... manage environment variables?](windows/environment-variables/) | Get, set, and remove system and user environment variables |
| [... manage the hosts file?](windows/hosts-file/) | Add, remove, and list entries in the Windows hosts file |
| [... manage power settings?](windows/power-management/) | Configure power plans, sleep timeouts, and shutdown policies |
| [... manage printers?](windows/printer-management/) | Install, list, remove printers, and manage print queues |
| [... manage Hyper-V VMs?](windows/hyper-v-management/) | Start, stop, checkpoint, and export Hyper-V virtual machines |

---

## Linux — How do I...

### User & Access Management

| Task | Description |
|------|-------------|
| [... manage users?](linux/user-management/) | Create, modify, and remove Linux users and groups via Ansible |
| [... configure sudo access?](linux/sudoers-management/) | Manage sudo rules and privileges via drop-in sudoers files |
| [... manage SELinux?](linux/selinux-management/) | Set SELinux mode, manage booleans and file contexts |
| [... manage AppArmor?](linux/apparmor-management/) | Enforce, complain, and disable AppArmor profiles |
| [... configure password policy?](linux/password-policy/) | Set PAM password complexity requirements |
| [... configure account lockout?](linux/account-lockout/) | Configure PAM faillock for brute-force protection |

### Software & Packages

| Task | Description |
|------|-------------|
| [... manage packages?](linux/package-management/) | Install, update, and remove software packages via Ansible |
| [... manage DNF/YUM repositories?](linux/yum-repo-management/) | Add, enable, and remove YUM/DNF package repositories |
| [... manage APT repositories?](linux/apt-repo-management/) | Add, enable, and remove APT package repositories |
| [... manage Docker containers?](linux/docker-management/) | Install Docker Engine and manage containers via Ansible |

### Storage & Disk

| Task | Description |
|------|-------------|
| [... manage disks?](linux/disk-management/) | Check disk usage and manage LVM logical volumes |
| [... manage LVM snapshots?](linux/lvm-snapshot/) | Create, mount, and merge LVM snapshots |
| [... manage software RAID?](linux/raid-management/) | Create and monitor mdadm software RAID arrays |
| [... manage swap?](linux/swap-management/) | Create and configure swap files and set swappiness |
| [... back up with rsync?](linux/rsync-backup/) | Configure rsync-based backups to remote hosts |

### Networking

| Task | Description |
|------|-------------|
| [... configure networking?](linux/network-configuration/) | Configure network interfaces via NetworkManager |
| [... manage the firewall?](linux/firewall-management/) | Configure firewalld or ufw rules |
| [... configure NTP/Chrony?](linux/chrony-ntp/) | Configure Chrony time synchronization |
| [... configure DNS (BIND)?](linux/bind-dns/) | Deploy and configure a BIND9 DNS server |
| [... configure DHCP server?](linux/dhcp-server/) | Deploy and configure an ISC DHCP server |
| [... configure WireGuard VPN?](linux/wireguard-vpn/) | Deploy WireGuard VPN interfaces and peers |
| [... configure NFS server?](linux/nfs-server/) | Configure NFS exports and start the NFS server |
| [... mount NFS shares?](linux/nfs-client/) | Mount NFS shares and persist them in fstab |
| [... configure Samba?](linux/samba-server/) | Deploy Samba for SMB file sharing with Linux/Windows clients |
| [... tune TCP/IP settings?](linux/tcp-tuning/) | Apply TCP/IP kernel parameter tuning profiles |

### Security & Hardening

| Task | Description |
|------|-------------|
| [... harden SSH?](linux/ssh-hardening/) | Apply SSH daemon hardening best practices |
| [... configure fail2ban?](linux/fail2ban/) | Deploy fail2ban for automated intrusion prevention |
| [... configure auditd?](linux/auditd/) | Set up Linux audit daemon rules and log settings |
| [... manage TLS certificates?](linux/certificate-management/) | Generate, distribute, and install TLS certificates |
| [... configure a mail relay?](linux/postfix-relay/) | Configure Postfix as an authenticated SMTP relay |
| [... configure SNMP?](linux/snmp-configuration/) | Deploy and configure snmpd for monitoring |

### Services & Applications

| Task | Description |
|------|-------------|
| [... manage services?](linux/service-management/) | Start, stop, enable, and disable systemd services |
| [... create systemd units?](linux/systemd-unit/) | Write and deploy custom systemd service unit files |
| [... manage Nginx?](linux/nginx-management/) | Install Nginx and configure virtual hosts |
| [... manage Apache?](linux/apache-management/) | Install Apache httpd and configure virtual hosts |
| [... manage MySQL/MariaDB?](linux/mysql-management/) | Create databases and users in MySQL/MariaDB |
| [... manage PostgreSQL?](linux/postgresql-management/) | Create databases and users in PostgreSQL |

### System Configuration & Tuning

| Task | Description |
|------|-------------|
| [... patch systems?](linux/system-patching/) | Apply security and OS updates across managed hosts |
| [... manage cron jobs?](linux/cron-management/) | Create and remove cron jobs on target hosts |
| [... tune kernel parameters?](linux/kernel-parameters/) | Set sysctl kernel parameters persistently |
| [... configure ulimits?](linux/ulimits/) | Set system resource limits via PAM limits.conf |
| [... configure the GRUB bootloader?](linux/grub-management/) | Set GRUB timeout, kernel parameters, and password |
| [... configure journald?](linux/journald-configuration/) | Set systemd journal storage, retention, and rate limits |
| [... manage environment variables?](linux/environment-variables/) | Set system-wide environment variables via /etc/environment |
| [... set the system timezone?](linux/timezone-management/) | Configure the system timezone across managed hosts |
| [... set the system locale?](linux/locale-management/) | Configure system locale and language settings |
| [... manage the MOTD and login banner?](linux/motd-banner/) | Configure pre-login and post-login banners |
| [... manage /etc/hosts?](linux/hosts-file/) | Add and remove entries in the /etc/hosts file |
| [... manage logs?](linux/log-management/) | Configure rsyslog forwarding and logrotate policies |

### Automation

| Task | Description |
|------|-------------|
| [... schedule Ansible playbooks automatically?](linux/ansible-controller/) | Configure cron-based Ansible automation on a controller node |

---

## Contributing

When adding a new task:

1. Create a new folder under the appropriate OS directory.
2. Add a `README.md` using the template from the OS-level README.
3. Include the script or playbook with inline comments.
4. Set both status flags to **Not Verified** and **Not Approved**.
5. Open a pull request for peer review.
