> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Network Configuration

Configure network interface settings across managed hosts using Ansible. Supports NetworkManager (nmcli) on both Debian and RHEL-based systems.

## Playbook

`playbook.yml`

## Variables

Populate `vars/main.yml` before running.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `target_hosts` | string | Yes | — | Ansible inventory group or host |
| `network_interfaces` | list | No | `[]` | Network interface configurations (see structure below) |
| `dns_servers` | list | No | `[]` | Global DNS servers to apply (overridden per-interface if set) |
| `hostname` | string | No | `""` | Set the system hostname (leave empty to skip) |

### `network_interfaces` item structure

```yaml
network_interfaces:
  - name: eth0                        # Interface/connection name
    type: ethernet                    # ethernet, bond, vlan (default: ethernet)
    address: 192.168.1.100/24         # CIDR notation (leave empty for DHCP)
    gateway: 192.168.1.1              # Default gateway (optional)
    dns: ["8.8.8.8", "8.8.4.4"]      # Per-interface DNS (optional)
    state: present                    # present or absent
    autoconnect: true                 # Connect at boot (default: true)
```

## Usage

```bash
# Preview changes
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml --check

# Apply
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml

# Target a specific host
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml -l server01
```

## Notes

- **Changing the IP of the interface used for Ansible's SSH connection will disconnect the session.** Run such changes from the local console, or use a secondary management interface.
- The playbook uses `community.general.nmcli` which requires `NetworkManager` to be running on target hosts.
- Changes take effect immediately without a reboot.
- For servers without NetworkManager, use `/etc/network/interfaces` (Debian) or `/etc/sysconfig/network-scripts/` (RHEL) templates instead — this playbook does not support that case.
