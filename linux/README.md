# Linux Administration — Ansible Playbooks

This directory contains Ansible playbooks for common Linux system administration tasks. All playbooks are designed to be run from a central **Ansible controller** and can be scheduled via cron for automated execution.

## Requirements

### Ansible Controller
- Ansible 2.14 or later
- Python 3.9 or later
- SSH access to all managed hosts (key-based authentication recommended)
- Ansible inventory file configured with target hosts

### Managed Hosts
- SSH server running and accessible from the controller
- Python 3 installed (required by Ansible)
- A user account with `sudo` privileges for the Ansible connection user

## Directory Structure

Each task folder follows this layout:

```
<task-name>/
├── README.md        # Task documentation, variables reference, and status
├── playbook.yml     # Main Ansible playbook
└── vars/
    └── main.yml     # Variable definitions — populate before running
```

## Task Index

### User & Identity Management

| Task | Playbook | Description |
|------|----------|-------------|
| [User Management](user-management/) | `playbook.yml` | Create, modify, and remove Linux users and groups |
| [Sudoers Management](sudoers-management/) | `playbook.yml` | Manage sudoers rules and drop-in files safely |
| [Password Policy](password-policy/) | `playbook.yml` | Configure pam_pwquality complexity and login.defs aging |
| [Account Lockout](account-lockout/) | `playbook.yml` | Configure pam_faillock thresholds and unlock procedures |
| [SSH Hardening](ssh-hardening/) | `playbook.yml` | Apply SSH daemon hardening best practices |

### Software & Package Management

| Task | Playbook | Description |
|------|----------|-------------|
| [Package Management](package-management/) | `playbook.yml` | Install, update, and remove software packages |
| [System Patching](system-patching/) | `playbook.yml` | Apply security and OS updates across managed hosts |
| [APT Repo Management](apt-repo-management/) | `playbook.yml` | Manage apt sources, GPG keyrings, and pinning (Debian) |
| [Yum Repo Management](yum-repo-management/) | `playbook.yml` | Manage yum/dnf repositories and GPG keys (RedHat) |
| [Docker Management](docker-management/) | `playbook.yml` | Install Docker Engine and deploy Compose projects |

### Storage & Disk

| Task | Playbook | Description |
|------|----------|-------------|
| [Disk Management](disk-management/) | `playbook.yml` | Check disk usage and manage LVM volumes |
| [LVM Snapshot](lvm-snapshot/) | `playbook.yml` | Create, mount, and remove LVM snapshots |
| [RAID Management](raid-management/) | `playbook.yml` | Create and monitor software RAID arrays with mdadm |
| [Swap Management](swap-management/) | `playbook.yml` | Create and configure swap files with vm.swappiness tuning |
| [LUKS Encryption](luks-encryption/) | `playbook.yml` | Encrypt block devices with LUKS2, manage crypttab and mounts |
| [Rsync Backup](rsync-backup/) | `playbook.yml` | Schedule rsync-based backups with log rotation |

### Networking

| Task | Playbook | Description |
|------|----------|-------------|
| [Network Configuration](network-configuration/) | `playbook.yml` | Configure network interfaces and settings |
| [Hostname Management](hostname-management/) | `playbook.yml` | Set FQDN, update /etc/hostname and /etc/hosts |
| [Hosts File](hosts-file/) | `playbook.yml` | Manage /etc/hosts entries for internal DNS overrides |
| [NFS Server](nfs-server/) | `playbook.yml` | Configure NFS exports and manage the NFS server |
| [NFS Client](nfs-client/) | `playbook.yml` | Mount NFS shares persistently via /etc/fstab |
| [Samba Server](samba-server/) | `playbook.yml` | Deploy Samba file sharing with smb.conf templating |
| [WireGuard VPN](wireguard-vpn/) | `playbook.yml` | Deploy WireGuard VPN peers and manage wg-quick |
| [BIND DNS](bind-dns/) | `playbook.yml` | Deploy and manage BIND9 zones and records |
| [DHCP Server](dhcp-server/) | `playbook.yml` | Configure ISC DHCP scopes and static reservations |
| [Postfix Relay](postfix-relay/) | `playbook.yml` | Configure Postfix as a SASL-authenticated SMTP relay |
| [TCP Tuning](tcp-tuning/) | `playbook.yml` | Apply named sysctl profiles for network performance |
| [HAProxy](haproxy/) | `playbook.yml` | Install and configure HAProxy HTTP/TCP load balancer |
| [Keepalived](keepalived/) | `playbook.yml` | Deploy Keepalived VRRP for virtual IP failover |

### Web & Application Services

| Task | Playbook | Description |
|------|----------|-------------|
| [Nginx Management](nginx-management/) | `playbook.yml` | Install Nginx and deploy virtual host configurations |
| [Apache Management](apache-management/) | `playbook.yml` | Install Apache and deploy virtual host configurations |
| [MySQL Management](mysql-management/) | `playbook.yml` | Install and configure MariaDB, users, and databases |
| [PostgreSQL Management](postgresql-management/) | `playbook.yml` | Install and configure PostgreSQL, users, and databases |
| [Redis Management](redis-management/) | `playbook.yml` | Install Redis with persistence, memory limits, and auth |

### Security & Hardening

| Task | Playbook | Description |
|------|----------|-------------|
| [Firewall Management](firewall-management/) | `playbook.yml` | Configure firewalld and UFW rules |
| [Fail2ban](fail2ban/) | `playbook.yml` | Deploy Fail2ban with jail configuration |
| [SELinux Management](selinux-management/) | `playbook.yml` | Set SELinux mode, booleans, file contexts, and ports |
| [AppArmor Management](apparmor-management/) | `playbook.yml` | Enforce, complain, and disable AppArmor profiles |
| [Auditd](auditd/) | `playbook.yml` | Configure auditd with CIS baseline and custom rules |
| [AIDE Integrity](aide-integrity/) | `playbook.yml` | Deploy AIDE file integrity monitoring with scheduled checks |
| [LUKS Encryption](luks-encryption/) | `playbook.yml` | Encrypt block devices with LUKS2 |
| [Certificate Management](certificate-management/) | `playbook.yml` | Deploy PEM certificates and update CA trust stores |
| [GRUB Management](grub-management/) | `playbook.yml` | Configure GRUB options and set boot password |
| [SNMP Configuration](snmp-configuration/) | `playbook.yml` | Configure SNMPv2c/v3 for network monitoring |

### Monitoring & Observability

| Task | Playbook | Description |
|------|----------|-------------|
| [Log Management](log-management/) | `playbook.yml` | Configure rsyslog forwarding and log rotation |
| [Journald Configuration](journald-configuration/) | `playbook.yml` | Configure systemd-journald retention and persistence |
| [Node Exporter](node-exporter/) | `playbook.yml` | Deploy Prometheus Node Exporter for host metrics |
| [Performance Monitoring](performance-monitoring/) | `playbook.yml` | Collect and report system performance metrics |

### System Configuration

| Task | Playbook | Description |
|------|----------|-------------|
| [Service Management](service-management/) | `playbook.yml` | Start, stop, enable, and disable systemd services |
| [Systemd Unit](systemd-unit/) | `playbook.yml` | Deploy and manage custom systemd service units |
| [Cron Management](cron-management/) | `playbook.yml` | Create and remove cron jobs on target hosts |
| [Scheduled Tasks](scheduled-tasks/) | `playbook.yml` | Manage complex scheduled task configurations |
| [Environment Variables](environment-variables/) | `playbook.yml` | Manage system-wide and profile environment variables |
| [Kernel Parameters](kernel-parameters/) | `playbook.yml` | Apply sysctl kernel parameters persistently |
| [Ulimits](ulimits/) | `playbook.yml` | Configure system and user resource limits via PAM |
| [Timezone Management](timezone-management/) | `playbook.yml` | Set system timezone and sync hardware clock |
| [Locale Management](locale-management/) | `playbook.yml` | Configure system locale and language settings |
| [Hostname Management](hostname-management/) | `playbook.yml` | Set FQDN, update /etc/hostname and /etc/hosts |
| [MOTD Banner](motd-banner/) | `playbook.yml` | Deploy dynamic MOTD and SSH login banners |
| [Ansible Controller Setup](ansible-controller/) | `playbook.yml` | Configure automated playbook scheduling on the controller |

## Running a Playbook

```bash
# Run with variables from the vars file
ansible-playbook -i /etc/ansible/hosts <task-name>/playbook.yml \
  -e @<task-name>/vars/main.yml

# Dry run (check mode — no changes made)
ansible-playbook -i /etc/ansible/hosts <task-name>/playbook.yml \
  -e @<task-name>/vars/main.yml --check

# Target a specific host group
ansible-playbook -i /etc/ansible/hosts <task-name>/playbook.yml \
  -e @<task-name>/vars/main.yml -l webservers
```

## Adding a New Task

1. Create a new folder: `linux/<task-name>/`
2. Add a `README.md` using the status header template:

```markdown
> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —
```

3. Add `playbook.yml` and `vars/main.yml` with all variables documented.
4. Document every variable in the README with type, default, and description.
