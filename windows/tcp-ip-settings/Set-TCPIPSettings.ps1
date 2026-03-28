#Requires -RunAsAdministrator
<#
.SYNOPSIS
    View and configure advanced TCP/IP settings: MTU, auto-tuning, chimney offload.
.NOTES
    See README.md for usage. Uses netsh.exe for TCP/IP configuration.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('GetSettings','GetMTU','SetMTU','SetAutoTuning','SetChimney','GetStats','Reset')]
    [string]$Action,

    [Parameter()] [string]$AdapterName,
    [Parameter()] [int]$MTU = 1500,
    [Parameter()] [ValidateSet('normal','experimental','highlyrestricted','restricted','disabled')] [string]$Level = 'normal',
    [Parameter()] [ValidateSet('default','enabled','disabled')] [string]$State = 'disabled'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Set-TCPIPSettings'

switch ($Action) {

    'GetSettings' {
        Write-Status "TCP global settings:"
        netsh int tcp show global
        Write-Host ""
        Write-Status "IP global settings:"
        netsh int ip show global
    }

    'GetMTU' {
        Write-Status "Interface MTU settings:"
        netsh int ipv4 show subinterfaces
    }

    'SetMTU' {
        if (-not $AdapterName) { throw "-AdapterName required." }
        if ($PSCmdlet.ShouldProcess($AdapterName, "Set MTU to $MTU")) {
            netsh int ipv4 set subinterface $AdapterName mtu=$MTU store=persistent
            Write-Status "MTU set to $MTU on adapter '$AdapterName'." 'SUCCESS'
        }
    }

    'SetAutoTuning' {
        Write-Status "Current receive window auto-tuning:"
        netsh int tcp show global | Select-String 'Receive Window'
        if ($PSCmdlet.ShouldProcess('TCP receive window auto-tuning', "Set to $Level")) {
            netsh int tcp set global autotuninglevel=$Level
            Write-Status "TCP receive window auto-tuning set to '$Level'." 'SUCCESS'
        }
    }

    'SetChimney' {
        if ($PSCmdlet.ShouldProcess('TCP chimney offload', "Set to $State")) {
            netsh int tcp set global chimney=$State
            Write-Status "TCP chimney offload set to '$State'." 'SUCCESS'
        }
    }

    'GetStats' {
        Write-Status "TCP connection statistics:"
        $conns = Get-NetTCPConnection | Group-Object State | Sort-Object Count -Descending
        $conns | Select-Object Count, Name | Format-Table -AutoSize
        Write-Host ""
        Write-Status "Active TCP connections:"
        Get-NetTCPConnection -State Established |
            Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort,
                @{N='Process';E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name}} |
            Format-Table -AutoSize
    }

    'Reset' {
        Write-Status "This will reset all TCP/IP and Winsock settings to defaults. A reboot is required." 'WARN'
        if ($PSCmdlet.ShouldProcess('TCP/IP stack', 'Reset to defaults')) {
            netsh int ip reset
            netsh int ipv6 reset
            netsh winsock reset
            Write-Status "TCP/IP and Winsock reset complete. Please reboot the system." 'SUCCESS'
        }
    }
}
Close-Log
