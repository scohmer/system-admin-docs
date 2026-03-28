#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Enable, disable, and configure Windows Remote Management (WinRM).
.NOTES
    See README.md for domain vs workgroup considerations.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Status','Enable','Disable','ListTrustedHosts','AddTrustedHost','RemoveTrustedHost','Test')]
    [string]$Action,

    [Parameter()]
    [string]$RemoteHost
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Set-WinRMConfiguration'

switch ($Action) {

    'Status' {
        Write-Status "WinRM status on $env:COMPUTERNAME:"
        try {
            $service = Get-Service WinRM
            Write-Host "  WinRM Service:   $($service.Status)"

            $listeners = & winrm enumerate winrm/config/listener 2>&1
            Write-Host "`n  Listeners:"
            $listeners | ForEach-Object { Write-Host "    $_" }

            $trustedHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction SilentlyContinue).Value
            Write-Host "`n  TrustedHosts: $(if ($trustedHosts) { $trustedHosts } else { '(empty)' })"
        } catch {
            Write-Status "WinRM does not appear to be configured. Run -Action Enable to set it up." 'WARN'
        }
    }

    'Enable' {
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Enable WinRM / PowerShell Remoting')) {
            Write-Status "Enabling WinRM..."
            Enable-PSRemoting -Force -SkipNetworkProfileCheck
            Set-Service WinRM -StartupType Automatic
            Write-Status "WinRM enabled. PowerShell remoting is now available." 'SUCCESS'
        }
    }

    'Disable' {
        Write-Status "Disabling WinRM will prevent all PowerShell remoting to this machine." 'WARN'
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Disable WinRM')) {
            Disable-PSRemoting -Force
            Stop-Service WinRM -Force
            Set-Service WinRM -StartupType Disabled
            Write-Status "WinRM disabled." 'SUCCESS'
        }
    }

    'ListTrustedHosts' {
        $hosts = (Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction Stop).Value
        if (-not $hosts) {
            Write-Status "TrustedHosts list is empty." 'WARN'
        } else {
            Write-Host "`n  TrustedHosts: $hosts`n"
            $hosts -split ',' | ForEach-Object { Write-Host "    - $($_.Trim())" }
        }
    }

    'AddTrustedHost' {
        if (-not $RemoteHost) { throw "-RemoteHost required." }
        if ($PSCmdlet.ShouldProcess($RemoteHost, 'Add to WinRM TrustedHosts')) {
            $current = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
            if ($current -eq '*') {
                Write-Status "TrustedHosts is already set to '*' (all hosts)." 'WARN'
            } elseif ($RemoteHost -eq '*') {
                Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force
                Write-Status "TrustedHosts set to '*' (all hosts — use in isolated environments only)." 'WARN'
            } else {
                $new = if ($current) { "$current,$RemoteHost" } else { $RemoteHost }
                Set-Item WSMan:\localhost\Client\TrustedHosts -Value $new -Force
                Write-Status "Added '$RemoteHost' to TrustedHosts." 'SUCCESS'
            }
        }
    }

    'RemoveTrustedHost' {
        if (-not $RemoteHost) { throw "-RemoteHost required." }
        if ($PSCmdlet.ShouldProcess($RemoteHost, 'Remove from WinRM TrustedHosts')) {
            $current = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
            $entries = ($current -split ',') | Where-Object { $_.Trim() -ne $RemoteHost }
            $new = $entries -join ','
            Set-Item WSMan:\localhost\Client\TrustedHosts -Value $new -Force
            Write-Status "Removed '$RemoteHost' from TrustedHosts." 'SUCCESS'
        }
    }

    'Test' {
        if (-not $RemoteHost) { throw "-RemoteHost required." }
        Write-Status "Testing WinRM connection to '$RemoteHost'..."
        try {
            $result = Test-WSMan -ComputerName $RemoteHost -ErrorAction Stop
            Write-Status "WinRM is reachable on '$RemoteHost'." 'SUCCESS'
            Write-Host "  Protocol Version: $($result.ProductVersion)"
        } catch {
            Write-Status "Cannot reach WinRM on '$RemoteHost': $_" 'ERROR'
        }
    }
}
Close-Log
