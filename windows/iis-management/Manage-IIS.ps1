#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage IIS websites and application pools.
.NOTES
    Requires the Web-Server feature and WebAdministration module.
    See README.md for usage examples.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('ListSites','ListAppPools','StartSite','StopSite','RestartSite',
                 'StartAppPool','StopAppPool','RestartAppPool','CreateSite','RemoveSite')]
    [string]$Action,

    [Parameter()] [string]$SiteName,
    [Parameter()] [string]$AppPoolName,
    [Parameter()] [string]$PhysicalPath,
    [Parameter()] [int]$Port = 80,
    [Parameter()] [string]$HostHeader = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

if (-not (Get-Module -ListAvailable WebAdministration)) {
    throw "WebAdministration module not found. Install IIS with: Install-WindowsFeature -Name Web-Server -IncludeManagementTools"
}
Import-Module WebAdministration -ErrorAction Stop

switch ($Action) {

    'ListSites' {
        Get-Website | Select-Object Name, State, PhysicalPath,
            @{N='Bindings';E={($_.Bindings.Collection | ForEach-Object { $_.bindingInformation }) -join ', '}} |
            Format-Table -AutoSize
    }

    'ListAppPools' {
        Get-WebConfiguration '/system.applicationHost/applicationPools/add' |
            Select-Object Name, State, ManagedRuntimeVersion, ManagedPipelineMode,
                @{N='IdentityType';E={$_.processModel.userName}} |
            Format-Table -AutoSize
    }

    'StartSite' {
        if (-not $SiteName) { throw "-SiteName required." }
        if ($PSCmdlet.ShouldProcess($SiteName, 'Start site')) {
            Start-Website -Name $SiteName
            Write-Status "Site '$SiteName' started." 'SUCCESS'
        }
    }

    'StopSite' {
        if (-not $SiteName) { throw "-SiteName required." }
        if ($PSCmdlet.ShouldProcess($SiteName, 'Stop site')) {
            Stop-Website -Name $SiteName
            Write-Status "Site '$SiteName' stopped." 'SUCCESS'
        }
    }

    'RestartSite' {
        if (-not $SiteName) { throw "-SiteName required." }
        if ($PSCmdlet.ShouldProcess($SiteName, 'Restart site')) {
            Stop-Website -Name $SiteName
            Start-Website -Name $SiteName
            Write-Status "Site '$SiteName' restarted." 'SUCCESS'
        }
    }

    'StartAppPool' {
        if (-not $AppPoolName) { throw "-AppPoolName required." }
        if ($PSCmdlet.ShouldProcess($AppPoolName, 'Start app pool')) {
            Start-WebAppPool -Name $AppPoolName
            Write-Status "App pool '$AppPoolName' started." 'SUCCESS'
        }
    }

    'StopAppPool' {
        if (-not $AppPoolName) { throw "-AppPoolName required." }
        if ($PSCmdlet.ShouldProcess($AppPoolName, 'Stop app pool')) {
            Stop-WebAppPool -Name $AppPoolName
            Write-Status "App pool '$AppPoolName' stopped." 'SUCCESS'
        }
    }

    'RestartAppPool' {
        if (-not $AppPoolName) { throw "-AppPoolName required." }
        if ($PSCmdlet.ShouldProcess($AppPoolName, 'Recycle app pool')) {
            Restart-WebAppPool -Name $AppPoolName
            Write-Status "App pool '$AppPoolName' recycled." 'SUCCESS'
        }
    }

    'CreateSite' {
        if (-not $SiteName)    { throw "-SiteName required." }
        if (-not $PhysicalPath) { throw "-PhysicalPath required." }
        if (-not $AppPoolName) { $AppPoolName = $SiteName }

        if (-not (Test-Path $PhysicalPath)) {
            New-Item -ItemType Directory -Path $PhysicalPath -Force | Out-Null
            Write-Status "Created directory: $PhysicalPath"
        }

        if ($PSCmdlet.ShouldProcess($SiteName, 'Create IIS site')) {
            # Create app pool if it doesn't exist
            if (-not (Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' `
                      -filter "system.applicationHost/applicationPools/add[@name='$AppPoolName']" -name name `
                      -ErrorAction SilentlyContinue)) {
                New-WebAppPool -Name $AppPoolName | Out-Null
                Write-Status "App pool '$AppPoolName' created."
            }
            # Create binding string
            $binding = "*:${Port}:$HostHeader"
            New-Website -Name $SiteName -PhysicalPath $PhysicalPath `
                        -ApplicationPool $AppPoolName -Port $Port | Out-Null
            Write-Status "Site '$SiteName' created on port $Port at $PhysicalPath" 'SUCCESS'
        }
    }

    'RemoveSite' {
        if (-not $SiteName) { throw "-SiteName required." }
        if ($PSCmdlet.ShouldProcess($SiteName, 'Remove site')) {
            Write-Status "Removing site '$SiteName'..." 'WARN'
            Remove-Website -Name $SiteName
            Write-Status "Site '$SiteName' removed." 'SUCCESS'
        }
    }
}
