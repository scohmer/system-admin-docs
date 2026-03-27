> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — BIND DNS Server

Install and configure BIND9 as an authoritative or recursive DNS server.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `bind_listen_on` | Interfaces to listen on | `any` |
| `bind_allow_query` | ACL for which clients can query | `localhost` |
| `bind_allow_recursion` | ACL for recursive queries | `localhost` |
| `bind_forwarders` | Upstream DNS servers for forwarding | `[]` |
| `bind_zones` | List of authoritative zones to serve | `[]` |
| `bind_firewall_manage` | Open DNS port in firewall | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/bind-dns/playbook.yml \
  -e target_hosts=dns_servers
```

## Notes

- Service name is `bind9` on Debian and `named` on RHEL.
- Zone files are deployed to `/etc/bind/zones/` (Debian) or `/var/named/` (RHEL).
- Configuration is validated with `named-checkconf` and zone files with `named-checkzone` before reload.
- For internal recursive resolver, set `allow_query` and `allow_recursion` to your internal subnets.
