> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — WireGuard VPN

Install and configure WireGuard VPN as a server or client peer.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `wg_interface` | WireGuard interface name | `wg0` |
| `wg_port` | WireGuard listen port | `51820` |
| `wg_address` | VPN IP address/CIDR for this host | `10.10.0.1/24` |
| `wg_private_key` | Private key (use Ansible Vault) | — |
| `wg_peers` | List of peer definitions | `[]` |
| `wg_enable_ip_forward` | Enable IP forwarding (for gateway/server) | `true` |
| `wg_post_up` | Commands to run after interface up | iptables masquerade |
| `wg_post_down` | Commands to run after interface down | remove masquerade |

## Usage

```bash
# Generate keys on each host first:
# wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey

ansible-playbook -i inventory/hosts.ini linux/wireguard-vpn/playbook.yml \
  -e target_hosts=vpn_servers --ask-vault-pass
```

## Notes

- Private keys must be generated on each host and stored in Ansible Vault — never share private keys.
- Public keys are derived from private keys: `wg pubkey < privatekey`
- The WireGuard interface is managed by `wg-quick` via a systemd service.
- For a road-warrior VPN, the server needs IP forwarding and NAT (masquerade) to route client traffic.
