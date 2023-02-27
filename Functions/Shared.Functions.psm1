$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3

function Install-Dependency(
    [Parameter(mandatory=$true)]
    [string] $moduleName,

    [Parameter(mandatory=$true)]
    [string] $moduleVersion
) {
    # This assumes that $env:PSModulePath contains ~\Documents\WindowsPowershell\Modules
    if ($null -eq (Get-Module -Name $moduleName -ErrorAction SilentlyContinue)) { # TODO: Also check version?
        Install-Module $moduleName `
            -Scope CurrentUser `
            -RequiredVersion $moduleVersion `
            -Force `
            -AllowClobber | Out-Null
    }
    
    # Refresh list of modules.
    Get-Module -ListAvailable -Refresh | Out-Null

    Import-Module $moduleName -Force
}

function Get-Timestamp() {
    Get-Date -Format "dd-MM-yyyy_HHmmss"
}

function Assert-OperatingSystem([string] $expectedOs = 'Win32NT') {
    $actualOs = [System.Environment]::OSVersion.Platform
    if ($actualOs -ne $expectedOs) {
        throw "This script only works when [System.Environment]::OSVersion.Platform is $expectedOs"
    }
}

Export-ModuleMember -Function "*"