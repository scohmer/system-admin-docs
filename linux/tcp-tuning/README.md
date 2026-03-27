> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — TCP/IP Network Tuning

Optimize TCP/IP stack parameters for high-throughput or low-latency server workloads.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `tcp_tuning_profile` | Tuning profile: `web_server`, `database`, `storage`, `custom` | `web_server` |
| `tcp_custom_params` | Custom sysctl params (used when profile is `custom`) | `{}` |

## Usage

```bash
# Apply web server profile
ansible-playbook -i inventory/hosts.ini linux/tcp-tuning/playbook.yml \
  -e target_hosts=webservers \
  -e tcp_tuning_profile=web_server

# Apply database server profile
ansible-playbook -i inventory/hosts.ini linux/tcp-tuning/playbook.yml \
  -e target_hosts=dbservers \
  -e tcp_tuning_profile=database
```

## Notes

- Parameters are written to `/etc/sysctl.d/99-tcp-tuning.conf` and take effect immediately.
- Profile descriptions:
  - `web_server`: High concurrency, large connection queues, BBR congestion control
  - `database`: Low latency, reduced keepalive times, optimized memory
  - `storage`: High throughput for file servers and NAS
  - `custom`: Use `tcp_custom_params` dict to set specific values
- Test with `ss -s` and `netstat -s` to verify tuning effectiveness.
