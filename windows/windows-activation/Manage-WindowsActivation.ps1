#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Check and manage Windows activation status using slmgr.vbs.
.NOTES
    See README.md for usage. Uses slmgr.vbs for all activation operations.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Status','Activate','InstallKey','SetKMSServer','ActivateKMS','RemoveKey','GetLicenseInfo')]
    [string]$Action,

    [Parameter()] [string]$ProductKey,
    [Parameter()] [string]$KMSServer,
    [Parameter()] [int]$KMSPort = 1688
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

function Invoke-Slmgr {
    param([string[]]$Arguments)
    $result = & cscript.exe //Nologo "$env:SystemRoot\System32\slmgr.vbs" @Arguments 2>&1
    return $result -join "`n"
}

switch ($Action) {

    'Status' {
        Write-Status "Windows activation status:"
        $status = Invoke-Slmgr '/dli'
        Write-Host $status
        $licensed = $status -match 'Licensed'
        if ($licensed) {
            Write-Status "Windows is activated." 'SUCCESS'
        } else {
            Write-Status "Windows may not be activated." 'WARN'
        }
    }

    'GetLicenseInfo' {
        Write-Status "Detailed license information (slmgr /dlv):"
        $info = Invoke-Slmgr '/dlv'
        Write-Host $info
    }

    'Activate' {
        if ($PSCmdlet.ShouldProcess('Windows', 'Activate online')) {
            Write-Status "Activating Windows online..."
            $result = Invoke-Slmgr '/ato'
            Write-Host $result
            if ($result -match 'successfully') {
                Write-Status "Windows activated successfully." 'SUCCESS'
            } else {
                Write-Status "Activation may have failed. Review output above." 'WARN'
            }
        }
    }

    'InstallKey' {
        if (-not $ProductKey) { throw "-ProductKey required." }
        if ($ProductKey -notmatch '^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$') {
            throw "Invalid product key format. Expected: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
        }
        if ($PSCmdlet.ShouldProcess('Windows', 'Install product key')) {
            $result = Invoke-Slmgr '/ipk', $ProductKey
            Write-Host $result
            Write-Status "Product key installed. Run -Action Activate to activate." 'SUCCESS'
        }
    }

    'SetKMSServer' {
        if (-not $KMSServer) { throw "-KMSServer required." }
        if ($PSCmdlet.ShouldProcess($KMSServer, 'Set KMS server')) {
            $result = Invoke-Slmgr '/skms', "${KMSServer}:${KMSPort}"
            Write-Host $result
            Write-Status "KMS server set to ${KMSServer}:${KMSPort}. Run -Action ActivateKMS to activate." 'SUCCESS'
        }
    }

    'ActivateKMS' {
        if ($PSCmdlet.ShouldProcess('Windows', 'Activate via KMS')) {
            Write-Status "Activating via KMS server..."
            $result = Invoke-Slmgr '/ato'
            Write-Host $result
            if ($result -match 'successfully') {
                Write-Status "KMS activation successful." 'SUCCESS'
            } else {
                Write-Status "KMS activation may have failed. Review output above." 'WARN'
            }
        }
    }

    'RemoveKey' {
        Write-Status "This removes the installed product key from the registry." 'WARN'
        if ($PSCmdlet.ShouldProcess('Windows product key', 'Remove from registry')) {
            $result = Invoke-Slmgr '/upk'
            Write-Host $result
            Write-Status "Product key removed from registry." 'SUCCESS'
        }
    }
}
