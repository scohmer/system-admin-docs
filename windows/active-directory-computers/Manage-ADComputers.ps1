#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Active Directory computer accounts.

.DESCRIPTION
    List, search, disable, enable, move, delete, and retrieve last logon
    information for Active Directory computer objects. Requires the RSAT
    ActiveDirectory PowerShell module and appropriate AD permissions.

.PARAMETER Action
    The operation to perform.

.PARAMETER ComputerName
    Name of the target computer account (SAMAccountName without trailing $).

.PARAMETER OU
    Distinguished name of the target Organizational Unit (for Move action).

.PARAMETER SearchFilter
    LDAP-style filter string for the Search action.

.EXAMPLE
    .\Manage-ADComputers.ps1 -Action List
    .\Manage-ADComputers.ps1 -Action Disable -ComputerName WORKSTATION01
    .\Manage-ADComputers.ps1 -Action Move -ComputerName WORKSTATION01 -OU "OU=Retired,DC=corp,DC=local"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List', 'Search', 'Disable', 'Enable', 'Move', 'Delete', 'GetLastLogon')]
    [string]$Action,

    [string]$ComputerName,
    [string]$OU,
    [string]$SearchFilter = '*'
)

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-ADComputers'

# ─── Ensure ActiveDirectory module is available ──────────────────────────────
function Assert-ADModule {
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        Write-Status "ActiveDirectory module not found. Install RSAT." 'ERROR'
        Write-Status "Run: Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" 'WARN'
        exit 1
    }
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Status "ActiveDirectory module loaded." 'SUCCESS'
}

# ─── Helper: require a parameter ────────────────────────────────────────────
function Assert-Param {
    param([string]$Value, [string]$ParamName)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Write-Status "-$ParamName is required for this action." 'ERROR'
        exit 1
    }
}

Assert-ADModule

switch ($Action) {

    'List' {
        # Retrieve all computer accounts with key attributes
        Write-Status "Listing all AD computer accounts..."
        Get-ADComputer -Filter * -Properties OperatingSystem, OperatingSystemVersion, LastLogonDate, Enabled |
            Select-Object Name, OperatingSystem, OperatingSystemVersion, Enabled, LastLogonDate |
            Sort-Object Name |
            Format-Table -AutoSize
    }

    'Search' {
        Write-Status "Searching AD computers with filter: $SearchFilter"
        try {
            $results = Get-ADComputer -Filter $SearchFilter -Properties OperatingSystem, LastLogonDate, Enabled
            if ($results.Count -eq 0) { Write-Status "No computers matched the filter." 'WARN'; return }
            $results | Select-Object Name, OperatingSystem, Enabled, LastLogonDate | Format-Table -AutoSize
        }
        catch {
            Write-Status "Filter error: $_" 'ERROR'
        }
    }

    'Disable' {
        Assert-Param $ComputerName 'ComputerName'
        if ($PSCmdlet.ShouldProcess($ComputerName, 'Disable AD Computer')) {
            Disable-ADAccount -Identity $ComputerName
            Write-Status "Computer '$ComputerName' disabled." 'SUCCESS'
        }
    }

    'Enable' {
        Assert-Param $ComputerName 'ComputerName'
        if ($PSCmdlet.ShouldProcess($ComputerName, 'Enable AD Computer')) {
            Enable-ADAccount -Identity $ComputerName
            Write-Status "Computer '$ComputerName' enabled." 'SUCCESS'
        }
    }

    'Move' {
        Assert-Param $ComputerName 'ComputerName'
        Assert-Param $OU 'OU'
        $computer = Get-ADComputer -Identity $ComputerName
        if ($PSCmdlet.ShouldProcess($ComputerName, "Move to $OU")) {
            Move-ADObject -Identity $computer.DistinguishedName -TargetPath $OU
            Write-Status "Computer '$ComputerName' moved to '$OU'." 'SUCCESS'
        }
    }

    'Delete' {
        Assert-Param $ComputerName 'ComputerName'
        $computer = Get-ADComputer -Identity $ComputerName
        if ($PSCmdlet.ShouldProcess($ComputerName, 'DELETE AD Computer account (irreversible)')) {
            Remove-ADComputer -Identity $computer.DistinguishedName -Confirm:$false
            Write-Status "Computer '$ComputerName' deleted." 'SUCCESS'
        }
    }

    'GetLastLogon' {
        Assert-Param $ComputerName 'ComputerName'
        Write-Status "Retrieving last logon for '$ComputerName'..."
        $computer = Get-ADComputer -Identity $ComputerName -Properties LastLogonDate, LastLogon, OperatingSystem, Enabled
        [PSCustomObject]@{
            Name            = $computer.Name
            Enabled         = $computer.Enabled
            OperatingSystem = $computer.OperatingSystem
            # LastLogonDate is the replicated attribute (updated every 14 days)
            LastLogonDate   = $computer.LastLogonDate
            # LastLogon is non-replicated; this DC value may not be current
            LastLogon_ThisDC = if ($computer.LastLogon) { [DateTime]::FromFileTime($computer.LastLogon) } else { 'Never' }
            DaysSinceLogon  = if ($computer.LastLogonDate) { (New-TimeSpan -Start $computer.LastLogonDate -End (Get-Date)).Days } else { 'N/A' }
        } | Format-List
    }
}
Close-Log
