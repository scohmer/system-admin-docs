> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — ISC DHCP Server

Install and configure ISC DHCP server with subnets, pools, and static host reservations.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `dhcp_domain_name` | Default domain name for clients | `corp.local` |
| `dhcp_dns_servers` | List of DNS servers to assign | `[]` |
| `dhcp_default_lease_time` | Default lease time in seconds | `86400` |
| `dhcp_max_lease_time` | Maximum lease time in seconds | `604800` |
| `dhcp_subnets` | List of subnet definitions | see vars |
| `dhcp_host_reservations` | Static IP reservations by MAC | `[]` |
| `dhcp_interface` | Interface to listen on | `eth0` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/dhcp-server/playbook.yml \
  -e target_hosts=dhcp_servers
```

## Notes

- Service name is `isc-dhcp-server` on Debian and `dhcpd` on RHEL.
- Only one DHCP server should be active per subnet to avoid conflicts.
- Static reservations use MAC address matching — clients receive the same IP regardless of lease expiry.
- Failover configuration for HA DHCP is not included — see ISC DHCP documentation for failover setup.
