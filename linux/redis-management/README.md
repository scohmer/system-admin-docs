> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Redis Management

Install and configure Redis with persistence, memory limits, and optional authentication.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `redis_bind` | IP address Redis listens on | `127.0.0.1` |
| `redis_port` | TCP port Redis listens on | `6379` |
| `redis_password` | Authentication password (empty = no auth) | `""` |
| `redis_maxmemory` | Maximum memory Redis may use | `256mb` |
| `redis_maxmemory_policy` | Eviction policy when memory limit is reached | `allkeys-lru` |
| `redis_save_enabled` | Enable RDB snapshot persistence | `true` |
| `redis_save_intervals` | List of `seconds keys` RDB save thresholds | see vars |
| `redis_appendonly` | Enable AOF persistence | `false` |
| `redis_loglevel` | Redis log verbosity | `notice` |
| `redis_logfile` | Path to the Redis log file | `/var/log/redis/redis-server.log` |
| `redis_databases` | Number of databases | `16` |
| `redis_firewall_manage` | Open the Redis port in the host firewall | `false` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/redis-management/playbook.yml \
  -e target_hosts=all
```

Deploy with a password stored in Ansible Vault:

```bash
ansible-playbook -i inventory/hosts.ini linux/redis-management/playbook.yml \
  -e target_hosts=all \
  --ask-vault-pass
```

## Notes

- By default Redis binds to `127.0.0.1` only — change `redis_bind` and set `redis_firewall_manage: true` to expose the service to other hosts.
- Always set `redis_password` when binding to a non-loopback address — store the value with Ansible Vault rather than in plain text.
- `allkeys-lru` eviction is recommended for cache use cases; use `noeviction` for queue or persistence use cases where key loss is unacceptable.
- The OS-specific service name and config path are set automatically: `redis-server` / `/etc/redis/redis.conf` on Debian-family systems and `redis` / `/etc/redis.conf` on RedHat-family systems.
- Firewall rules are only applied when `redis_firewall_manage: true` **and** `redis_bind` is not `127.0.0.1`. UFW is used on Debian; firewalld is used on RedHat.
