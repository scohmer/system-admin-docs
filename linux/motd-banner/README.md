> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — MOTD and Login Banner

Configure the Message of the Day (MOTD) and SSH pre-login banner for legal notice and system information.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `motd_content` | Static MOTD content | system info script |
| `motd_dynamic` | Generate dynamic MOTD with system info | `true` |
| `ssh_banner_content` | SSH pre-login legal notice | see vars |
| `ssh_banner_enabled` | Enable SSH pre-login banner | `true` |
| `motd_disable_default` | Disable distro default MOTD scripts | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/motd-banner/playbook.yml \
  -e target_hosts=all
```

## Notes

- The SSH pre-login banner (`/etc/issue.net`) is displayed before authentication.
- MOTD (`/etc/motd`) is displayed after successful login.
- Dynamic MOTD scripts in `/etc/update-motd.d/` (Debian) run at login to show current system state.
- Pre-login banners are required by many compliance frameworks (PCI-DSS, HIPAA, CIS) as legal warning notice.
