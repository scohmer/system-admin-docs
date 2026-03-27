> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Keepalived

Deploy Keepalived for VRRP-based virtual IP failover between MASTER and BACKUP nodes. Provides a floating virtual IP address that automatically migrates between hosts when the MASTER becomes unavailable.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `keepalived_vrrp_instances` | List of VRRP instance definitions | see below |
| `keepalived_vrrp_instances[].name` | VRRP instance name (e.g. `VI_1`) | — |
| `keepalived_vrrp_instances[].state` | Role of this node: `MASTER` or `BACKUP` | `MASTER` |
| `keepalived_vrrp_instances[].interface` | Network interface to bind VRRP on | `eth0` |
| `keepalived_vrrp_instances[].virtual_router_id` | VRRP group ID (1–255, must match across nodes) | `51` |
| `keepalived_vrrp_instances[].priority` | Election priority — higher wins (MASTER > BACKUP) | `100` |
| `keepalived_vrrp_instances[].advert_int` | Advertisement interval in seconds | `1` |
| `keepalived_vrrp_instances[].auth_pass` | VRRP authentication password (max 8 chars) | `changeme` |
| `keepalived_vrrp_instances[].virtual_ipaddresses` | List of virtual IPs to manage | — |
| `keepalived_vrrp_instances[].track_scripts` | Optional list of track script names to attach | `[]` |
| `keepalived_track_scripts` | Optional health-check script definitions | `[]` |
| `keepalived_track_scripts[].name` | Script identifier name | — |
| `keepalived_track_scripts[].script` | Shell command to run as health check | — |
| `keepalived_track_scripts[].interval` | Check interval in seconds | `2` |
| `keepalived_track_scripts[].weight` | Priority adjustment on failure | `2` |
| `keepalived_firewall_manage` | Open VRRP protocol in firewall (firewalld/UFW) | `true` |

## Usage

```bash
# Run on the MASTER node (default vars):
ansible-playbook -i inventory/hosts.ini linux/keepalived/playbook.yml

# Run on the BACKUP node (override state and priority):
ansible-playbook -i inventory/hosts.ini linux/keepalived/playbook.yml \
  -e "keepalived_vrrp_instances[0].state=BACKUP keepalived_vrrp_instances[0].priority=90"
```

## Notes

- Run with `-e "keepalived_vrrp_instances[0].state=BACKUP keepalived_vrrp_instances[0].priority=90"` on the backup node to set the correct role and priority without editing `vars/main.yml`.
- `virtual_router_id` must match across all nodes participating in the same VRRP group. Mismatched IDs will cause split-brain.
- The VRRP authentication password (`auth_pass`) is limited to 8 characters by the VRRP specification. Longer values will be silently truncated.
- This playbook enables `net.ipv4.ip_nonlocal_bind`, which is required for services (e.g. HAProxy, Nginx) bound to the virtual IP to start successfully on the BACKUP node before the VIP is assigned.
- Pairs well with `haproxy` for a high-availability load balancer setup — run keepalived alongside HAProxy on both nodes, and use a `track_script` to trigger failover when HAProxy becomes unhealthy.
