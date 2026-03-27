> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — SNMP Configuration

Install and configure Net-SNMP (snmpd) for monitoring integration with SNMP-based NMS tools.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `snmp_community` | SNMPv2c community string (use Vault) | `public` |
| `snmp_location` | System location string | `''` |
| `snmp_contact` | System contact string | `root` |
| `snmp_allowed_sources` | IPs/subnets allowed to query | `localhost` |
| `snmp_version` | SNMP version to enable (`v2c`, `v3`, `both`) | `v2c` |
| `snmp_v3_users` | SNMPv3 users (auth + priv) | `[]` |
| `snmp_traps_enabled` | Enable SNMP traps | `false` |
| `snmp_trap_sink` | Trap destination host | `''` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/snmp-configuration/playbook.yml \
  -e target_hosts=all --ask-vault-pass
```

## Notes

- **SNMPv2c community strings are sent in plaintext** — restrict access to trusted monitoring IPs and use SNMPv3 for production.
- SNMPv3 provides authentication and encryption — use `authPriv` security level for maximum security.
- Common monitoring tools: Zabbix, Nagios, LibreNMS, PRTG, Prometheus (via snmp_exporter).
- Test after deployment: `snmpwalk -v2c -c <community> <host> 1.3.6.1.2.1.1`
