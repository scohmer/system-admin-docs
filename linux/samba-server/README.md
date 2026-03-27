> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Samba Server

Install and configure a Samba SMB/CIFS file server for sharing files with Windows clients.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `samba_workgroup` | Workgroup or domain name | `WORKGROUP` |
| `samba_server_string` | Server description | `Samba Server` |
| `samba_shares` | List of share definitions | see vars |
| `samba_users` | List of Samba users (username + password) | `[]` |
| `samba_firewall_manage` | Open Samba ports in firewall | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/samba-server/playbook.yml \
  -e target_hosts=fileservers
```

## Notes

- Samba users must also be Linux system users. The playbook creates both.
- Passwords for Samba users are set separately via `smbpasswd` — stored in `vars/main.yml` (use Ansible Vault for production).
- For domain membership (Active Directory integration), additional configuration is required beyond what this playbook provides.
