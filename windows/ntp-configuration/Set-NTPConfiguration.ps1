#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manages Windows Time (W32Time) NTP configuration and synchronization.

.DESCRIPTION
    Provides actions to query NTP status, configure NTP servers, force time
    synchronization, and toggle client/server mode using the w32tm command-line
    tool and the W32Time Windows service.

.PARAMETER Action
    The operation to perform:
      Status     - Show current NTP/W32Time status
      SetServer  - Configure NTP server list
      Sync       - Force an immediate time resync
      ResyncAll  - Force resync of all configured peers
      Configure  - Set client/server mode and NTP servers

.PARAMETER NTPServer
    Array of NTP server hostnames. Required for SetServer and Configure.

.PARAMETER ComputerName
    Remote computer to target. Defaults to the local machine.

.EXAMPLE
    .\Set-NTPConfiguration.ps1 -Action Status
    .\Set-NTPConfiguration.ps1 -Action SetServer -NTPServer "time.windows.com","pool.ntp.org"
    .\Set-NTPConfiguration.ps1 -Action Sync
    .\Set-NTPConfiguration.ps1 -Action Configure -NTPServer "time.windows.com"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Status', 'SetServer', 'Sync', 'ResyncAll', 'Configure')]
    [string]$Action,

    [Parameter()]
    [string[]]$NTPServer,

    [Parameter()]
    [string]$ComputerName = $env:COMPUTERNAME
)

$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

# Helper: run w32tm, optionally on a remote machine
function Invoke-W32TM {
    param([string[]]$Arguments)

    if ($ComputerName -ne $env:COMPUTERNAME) {
        # Prepend /computer: flag for remote execution
        $Arguments = @("/computer:$ComputerName") + $Arguments
    }
    Write-Verbose "w32tm $($Arguments -join ' ')"
    & w32tm @Arguments 2>&1
}

# Helper: restart W32Time service (locally or remotely)
function Restart-W32TimeService {
    Write-Status "Restarting W32Time service on $ComputerName..." 'INFO'
    if ($PSCmdlet.ShouldProcess($ComputerName, 'Restart W32Time service')) {
        if ($ComputerName -ne $env:COMPUTERNAME) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Restart-Service W32Time -Force
            }
        } else {
            Restart-Service W32Time -Force
        }
        Write-Status "W32Time service restarted." 'SUCCESS'
    }
}

switch ($Action) {

    'Status' {
        Write-Status "Querying NTP status on $ComputerName..."

        Write-Host "`n--- W32TM Status ---" -ForegroundColor Magenta
        Invoke-W32TM @('/query', '/status') | ForEach-Object { Write-Host $_ }

        Write-Host "`n--- Peer List ---" -ForegroundColor Magenta
        Invoke-W32TM @('/query', '/peers') | ForEach-Object { Write-Host $_ }

        Write-Host "`n--- W32Time Service Status ---" -ForegroundColor Magenta
        if ($ComputerName -ne $env:COMPUTERNAME) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Get-Service W32Time | Select-Object Name, Status, StartType
            } | Format-Table -AutoSize
        } else {
            Get-Service W32Time | Select-Object Name, Status, StartType | Format-Table -AutoSize
        }
    }

    'SetServer' {
        if (-not $NTPServer -or $NTPServer.Count -eq 0) {
            Write-Status "NTPServer parameter is required for SetServer action." 'ERROR'
            exit 1
        }

        # Build the NTP server string: each server with ",0x9" flags (client + SpecialPollInterval)
        $serverList = ($NTPServer | ForEach-Object { "$_,0x9" }) -join ' '
        Write-Status "Configuring NTP servers: $serverList on $ComputerName"

        if ($PSCmdlet.ShouldProcess($ComputerName, "Set NTP servers to: $serverList")) {
            # Set the NTP server list and switch to NTP type
            Invoke-W32TM @('/config', "/manualpeerlist:$serverList", '/syncfromflags:manual', '/reliable:YES', '/update') |
                ForEach-Object { Write-Host $_ }

            Restart-W32TimeService

            Write-Status "NTP servers configured successfully." 'SUCCESS'
        }
    }

    'Sync' {
        Write-Status "Forcing immediate time resync on $ComputerName..."

        if ($PSCmdlet.ShouldProcess($ComputerName, 'Force time resync')) {
            # /force overrides any rate limits
            Invoke-W32TM @('/resync', '/force') | ForEach-Object { Write-Host $_ }
            Write-Status "Time resync completed." 'SUCCESS'
        }
    }

    'ResyncAll' {
        Write-Status "Resyncing all peers on $ComputerName..."

        if ($PSCmdlet.ShouldProcess($ComputerName, 'Resync all peers')) {
            Invoke-W32TM @('/resync', '/rediscover', '/force') | ForEach-Object { Write-Host $_ }
            Write-Status "All peers resynced." 'SUCCESS'
        }
    }

    'Configure' {
        if (-not $NTPServer -or $NTPServer.Count -eq 0) {
            Write-Status "NTPServer parameter is required for Configure action." 'ERROR'
            exit 1
        }

        $serverList = ($NTPServer | ForEach-Object { "$_,0x9" }) -join ' '
        Write-Status "Configuring W32Time client/server mode on $ComputerName with servers: $serverList"

        if ($PSCmdlet.ShouldProcess($ComputerName, "Configure NTP client/server mode")) {
            # Configure as a reliable NTP server (AnnounceFlags=5) and client
            Invoke-W32TM @(
                '/config',
                "/manualpeerlist:$serverList",
                '/syncfromflags:manual',
                '/reliable:YES',
                '/update'
            ) | ForEach-Object { Write-Host $_ }

            # Set AnnounceFlags in registry so this machine advertises as a time source
            $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config'
            if ($ComputerName -ne $env:COMPUTERNAME) {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    param($path)
                    Set-ItemProperty -Path $path -Name AnnounceFlags -Value 5
                } -ArgumentList $regPath
            } else {
                Set-ItemProperty -Path $regPath -Name AnnounceFlags -Value 5
            }

            Restart-W32TimeService
            Write-Status "NTP client/server mode configured successfully." 'SUCCESS'
        }
    }
}
