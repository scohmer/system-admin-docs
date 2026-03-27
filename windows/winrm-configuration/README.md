> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — WinRM Configuration

Enable and configure Windows Remote Management (WinRM) for PowerShell Remoting. Manage trusted hosts and test remote connectivity.

## Script

`Set-WinRMConfiguration.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# Check WinRM status
.\Set-WinRMConfiguration.ps1 -Action Status

# Enable WinRM (quick setup for domain environments)
.\Set-WinRMConfiguration.ps1 -Action Enable

# Disable WinRM
.\Set-WinRMConfiguration.ps1 -Action Disable

# List trusted hosts (for workgroup environments)
.\Set-WinRMConfiguration.ps1 -Action ListTrustedHosts

# Add a host to TrustedHosts
.\Set-WinRMConfiguration.ps1 -Action AddTrustedHost -RemoteHost "192.168.1.50"

# Add all hosts (workgroup use only — reduces security)
.\Set-WinRMConfiguration.ps1 -Action AddTrustedHost -RemoteHost "*"

# Remove a trusted host
.\Set-WinRMConfiguration.ps1 -Action RemoveTrustedHost -RemoteHost "192.168.1.50"

# Test connectivity to a remote host
.\Set-WinRMConfiguration.ps1 -Action Test -RemoteHost "SERVER01"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | `Status`, `Enable`, `Disable`, `ListTrustedHosts`, `AddTrustedHost`, `RemoveTrustedHost`, `Test` |
| `-RemoteHost` | Context | Remote host IP or name for trusted host management or testing |

## Notes

- In domain environments, all domain computers are implicitly trusted — `TrustedHosts` is for workgroup/non-domain connections.
- `Enable-PSRemoting` creates the WinRM listener, configures firewall rules, and starts the service.
- Use `Invoke-Command -ComputerName SERVER01 -ScriptBlock {...}` to run commands remotely after enabling WinRM.
- HTTPS-based WinRM requires a valid certificate. For domain environments, HTTP over Kerberos is secured adequately.
