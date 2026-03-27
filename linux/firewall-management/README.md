> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Firewall Management

Configure firewall rules across managed hosts using Ansible. Supports **firewalld** (RHEL/CentOS/Rocky/Alma) and **ufw** (Debian/Ubuntu) automatically.

## Playbook

`playbook.yml`

## Variables

Populate `vars/main.yml` before running.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `target_hosts` | string | Yes | — | Ansible inventory group or host |
| `firewall_rules` | list | No | `[]` | Rules to add or remove (see structure below) |
| `firewalld_default_zone` | string | No | `public` | Default firewalld zone to apply rules to |
| `firewall_flush_rules` | bool | No | `false` | Reset all rules before applying (destructive) |

### `firewall_rules` item structure

```yaml
firewall_rules:
  - port: 443              # Port number
    protocol: tcp          # tcp or udp (default: tcp)
    state: enabled         # enabled or disabled
    zone: public           # firewalld zone (ignored for ufw)
    comment: "HTTPS"       # Description (used in ufw rules)
    source: ""             # Restrict to source IP/range (optional)
```

## Usage

```bash
# Preview
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml --check

# Apply firewall rules
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml

# Apply to specific group
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml -l webservers
```

## Notes

- The playbook detects the available firewall daemon automatically.
- Both firewalld and ufw persist rules across reboots.
- Setting `firewall_flush_rules: true` will remove **all** existing rules before applying the new ones — use with extreme caution on remote systems to avoid locking yourself out.
- Always ensure port `22` (SSH) is included in your rules before applying changes to remote hosts.
- Rules are permanent by default (survive reboot).
