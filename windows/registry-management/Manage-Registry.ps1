<#
.SYNOPSIS
    Manage Windows registry keys and values.

.DESCRIPTION
    Get, Set, Delete, Export, Import, and List Windows registry entries.
    Admin is required for HKLM and system hives; HKCU does not require elevation.

.PARAMETER Action
    The operation to perform.

.PARAMETER RegistryPath
    Registry path in PowerShell drive format (e.g. HKLM:\SOFTWARE\MyApp).

.PARAMETER Name
    Name of the registry value.

.PARAMETER Value
    Data to write (for Set action).

.PARAMETER Type
    Registry value type: String, DWord, QWord, Binary, MultiString.

.PARAMETER ExportPath
    File path for Export (.reg) output or Import source file.

.EXAMPLE
    .\Manage-Registry.ps1 -Action Get -RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName"
    .\Manage-Registry.ps1 -Action Set -RegistryPath "HKCU:\SOFTWARE\MyApp" -Name "Theme" -Value "Dark" -Type String
    .\Manage-Registry.ps1 -Action Export -RegistryPath "HKCU:\SOFTWARE\MyApp" -ExportPath "C:\Backups\MyApp.reg"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Get', 'Set', 'Delete', 'Export', 'Import', 'ListKeys')]
    [string]$Action,

    [string]$RegistryPath,
    [string]$Name,
    [object]$Value,
    [ValidateSet('String', 'DWord', 'QWord', 'Binary', 'MultiString', 'ExpandString')]
    [string]$Type = 'String',
    [string]$ExportPath
)

$ErrorActionPreference = 'Stop'

# ─── Helper: coloured timestamped output ────────────────────────────────────
function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

function Assert-Param {
    param([string]$Value, [string]$ParamName)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Write-Status "-$ParamName is required for this action." 'ERROR'
        exit 1
    }
}

# ─── Convert PowerShell drive path to reg.exe native path ─────────────────
function Convert-ToRegPath {
    param([string]$PSPath)
    $PSPath `
        -replace '^HKLM:\\', 'HKEY_LOCAL_MACHINE\' `
        -replace '^HKCU:\\', 'HKEY_CURRENT_USER\' `
        -replace '^HKCR:\\', 'HKEY_CLASSES_ROOT\' `
        -replace '^HKU:\\',  'HKEY_USERS\' `
        -replace '^HKCC:\\', 'HKEY_CURRENT_CONFIG\'
}

switch ($Action) {

    'Get' {
        Assert-Param $RegistryPath 'RegistryPath'
        Assert-Param $Name 'Name'

        if (-not (Test-Path $RegistryPath)) {
            Write-Status "Registry path not found: $RegistryPath" 'ERROR'; exit 1
        }
        $item = Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue
        if ($null -eq $item) {
            Write-Status "Value '$Name' not found at '$RegistryPath'." 'WARN'
        }
        else {
            [PSCustomObject]@{
                Path  = $RegistryPath
                Name  = $Name
                Value = $item.$Name
                Type  = (Get-Item $RegistryPath).GetValueKind($Name)
            } | Format-List
        }
    }

    'Set' {
        Assert-Param $RegistryPath 'RegistryPath'
        Assert-Param $Name 'Name'
        if ($null -eq $Value) { Write-Status "-Value is required for Set action." 'ERROR'; exit 1 }

        # Create the key hierarchy if it does not exist
        if (-not (Test-Path $RegistryPath)) {
            if ($PSCmdlet.ShouldProcess($RegistryPath, 'Create registry key')) {
                New-Item -Path $RegistryPath -Force | Out-Null
                Write-Status "Created registry key: $RegistryPath"
            }
        }

        if ($PSCmdlet.ShouldProcess("$RegistryPath\$Name", "Set value ($Type) = $Value")) {
            Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Type $Type
            Write-Status "Set '$Name' = '$Value' [$Type] at '$RegistryPath'." 'SUCCESS'
        }
    }

    'Delete' {
        Assert-Param $RegistryPath 'RegistryPath'

        if ($Name) {
            # Delete a specific value
            if ($PSCmdlet.ShouldProcess("$RegistryPath\$Name", 'Delete registry value')) {
                Remove-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction Stop
                Write-Status "Deleted value '$Name' from '$RegistryPath'." 'SUCCESS'
            }
        }
        else {
            # Delete the entire key and all subkeys
            Write-Status "No -Name specified; deleting entire key '$RegistryPath' and all subkeys." 'WARN'
            if ($PSCmdlet.ShouldProcess($RegistryPath, 'Delete registry key (recursive)')) {
                Remove-Item -Path $RegistryPath -Recurse -Force
                Write-Status "Deleted key '$RegistryPath'." 'SUCCESS'
            }
        }
    }

    'ListKeys' {
        Assert-Param $RegistryPath 'RegistryPath'

        if (-not (Test-Path $RegistryPath)) {
            Write-Status "Registry path not found: $RegistryPath" 'ERROR'; exit 1
        }

        Write-Status "Values at '$RegistryPath':"
        $regKey = Get-Item -Path $RegistryPath
        $values = $regKey.GetValueNames() | ForEach-Object {
            [PSCustomObject]@{
                Name  = if ($_ -eq '') { '(Default)' } else { $_ }
                Type  = $regKey.GetValueKind($_)
                Value = $regKey.GetValue($_)
            }
        }
        if ($values.Count -eq 0) { Write-Status "No values found." 'WARN' }
        else { $values | Format-Table -AutoSize }

        Write-Status "Subkeys:"
        Get-ChildItem -Path $RegistryPath -ErrorAction SilentlyContinue |
            Select-Object Name | Format-Table -AutoSize
    }

    'Export' {
        Assert-Param $RegistryPath 'RegistryPath'
        Assert-Param $ExportPath 'ExportPath'

        $nativePath = Convert-ToRegPath $RegistryPath
        $exportDir = Split-Path $ExportPath -Parent
        if (-not (Test-Path $exportDir)) { New-Item -ItemType Directory -Path $exportDir -Force | Out-Null }

        Write-Status "Exporting '$nativePath' to '$ExportPath'..."
        if ($PSCmdlet.ShouldProcess($RegistryPath, "Export to $ExportPath")) {
            # reg.exe export creates a Unicode .reg file readable by regedit
            $result = & reg.exe export $nativePath $ExportPath /y 2>&1
            if ($LASTEXITCODE -ne 0) { Write-Status "reg.exe export failed: $result" 'ERROR'; exit 1 }
            Write-Status "Exported to '$ExportPath'." 'SUCCESS'
        }
    }

    'Import' {
        Assert-Param $ExportPath 'ExportPath'

        if (-not (Test-Path $ExportPath)) {
            Write-Status "Import file not found: $ExportPath" 'ERROR'; exit 1
        }

        Write-Status "Importing '$ExportPath'..."
        if ($PSCmdlet.ShouldProcess($ExportPath, 'Import registry file')) {
            $result = & reg.exe import $ExportPath 2>&1
            if ($LASTEXITCODE -ne 0) { Write-Status "reg.exe import failed: $result" 'ERROR'; exit 1 }
            Write-Status "Registry file '$ExportPath' imported successfully." 'SUCCESS'
        }
    }
}
