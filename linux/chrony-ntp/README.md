> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Chrony NTP Configuration

Install and configure Chrony as the NTP client/server for time synchronization.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `ntp_servers` | List of NTP server addresses | pool.ntp.org servers |
| `chrony_allow_clients` | Subnets allowed to use this host as NTP server | `[]` |
| `chrony_makestep` | Allow large time step on startup | `1 3` |
| `chrony_rtcsync` | Keep hardware clock in sync | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/chrony-ntp/playbook.yml \
  -e target_hosts=all
```

## Notes

- Chrony is the default NTP implementation on RHEL 8+, Ubuntu 20.04+, and Debian 11+.
- To use this host as an NTP server for internal clients, add subnets to `chrony_allow_clients`.
- `makestep 1 3` allows stepping the clock (rather than slewing) for up to 3 corrections at startup — prevents issues when system time is far off.
