> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — HAProxy

Install and configure HAProxy as an HTTP/TCP load balancer.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `haproxy_firewall_manage` | Open frontend and stats ports in the host firewall | `true` |
| `haproxy_global.log` | Global syslog target and facility | `127.0.0.1 local0` |
| `haproxy_global.maxconn` | Global maximum connections | `50000` |
| `haproxy_global.user` | OS user HAProxy runs as | `haproxy` |
| `haproxy_global.group` | OS group HAProxy runs as | `haproxy` |
| `haproxy_global.daemon` | Run HAProxy in background (daemon mode) | `true` |
| `haproxy_defaults.mode` | Default proxy mode (`http` or `tcp`) | `http` |
| `haproxy_defaults.timeout_connect` | Connection timeout | `5s` |
| `haproxy_defaults.timeout_client` | Client inactivity timeout | `50s` |
| `haproxy_defaults.timeout_server` | Server inactivity timeout | `50s` |
| `haproxy_defaults.option_httplog` | Enable HTTP request logging | `true` |
| `haproxy_defaults.option_dontlognull` | Suppress logging of null connections | `true` |
| `haproxy_defaults.option_forwardfor` | Insert X-Forwarded-For header | `true` |
| `haproxy_defaults.option_http_server_close` | Enable HTTP connection close on server side | `true` |
| `haproxy_frontends` | List of frontend definitions (name, bind, default_backend) | see vars |
| `haproxy_backends` | List of backend definitions (name, balance, servers list) | see vars |
| `haproxy_stats_enable` | Enable the HAProxy stats frontend | `true` |
| `haproxy_stats_port` | Port for the stats page | `8404` |
| `haproxy_stats_uri` | URI path for the stats page | `/stats` |
| `haproxy_stats_user` | Basic auth username for stats page | `admin` |
| `haproxy_stats_password` | Basic auth password for stats page | `changeme` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/haproxy/playbook.yml \
  -e target_hosts=loadbalancers
```

## Notes

- The HAProxy configuration is validated with `haproxy -c -f <file>` before being applied — an invalid config will abort the play without touching the running service.
- The stats page is accessible at `http://<host>:8404/stats` with the credentials set in `haproxy_stats_user` / `haproxy_stats_password`. Change `haproxy_stats_password` before deploying to production.
- To enable SSL termination, uncomment the `https_front` example in `vars/main.yml` and set the bind to `*:443 ssl crt /etc/ssl/certs/haproxy.pem`. Ensure the PEM bundle (certificate + key) is in place before running the playbook — use the `certificate-management` playbook to provision it.
- Frontend ports are automatically opened in firewalld (RedHat) or UFW (Debian) when `haproxy_firewall_manage: true`. The stats port is also opened when `haproxy_stats_enable: true`.
- Backend server addresses are defined under `haproxy_backends[].servers` as `address: "ip:port"` entries. Add `options: "check"` to each server to enable active health checks.
