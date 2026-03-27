> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Kernel Parameters (sysctl)

Configure kernel parameters via `sysctl` for performance tuning, security hardening, and network optimization.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `sysctl_params` | Key-value pairs of sysctl settings | see vars |
| `sysctl_apply_security_baseline` | Apply CIS security hardening baseline | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/kernel-parameters/playbook.yml \
  -e target_hosts=all
```

## Notes

- Parameters are written to `/etc/sysctl.d/99-ansible.conf` for persistence across reboots.
- The security baseline disables IP forwarding, source routing, ICMP redirects, and enables SYN flood protection.
- Changes take effect immediately via `sysctl --system` without a reboot.
- Check current values: `sysctl -a | grep <key>`
