> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Node Exporter

Deploy Prometheus Node Exporter for host metrics collection (CPU, memory, disk, network).

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `node_exporter_version` | Node Exporter release version to install | `1.8.2` |
| `node_exporter_user` | System user to run the service | `node_exporter` |
| `node_exporter_port` | Port to expose metrics on | `9100` |
| `node_exporter_listen_address` | Address to bind the listener | `0.0.0.0` |
| `node_exporter_extra_args` | Additional CLI arguments passed to node_exporter | `""` |
| `node_exporter_firewall_manage` | Open the metrics port in the host firewall | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/node-exporter/playbook.yml \
  -e target_hosts=all
```

## Notes

- Node Exporter exposes metrics on port `9100` by default at `http://<host>:9100/metrics`.
- Add the following scrape config to your Prometheus configuration to collect these metrics:

  ```yaml
  scrape_configs:
    - job_name: node
      static_configs:
        - targets:
            - <host>:9100
  ```

- The binary is downloaded directly from the [GitHub releases page](https://github.com/prometheus/node_exporter/releases) and installed to `/usr/local/bin/node_exporter`.
- The service runs as the unprivileged `node_exporter` system user with a hardened systemd unit (`NoNewPrivileges`, `ProtectSystem=strict`, `PrivateTmp`, etc.).
- To pass additional collector flags, set `node_exporter_extra_args`, for example: `--collector.systemd --collector.processes`.
