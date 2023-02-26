$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3
Import-Module "$PSScriptRoot\Shared.Functions.psm1"

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

Export-ModuleMember -Function "*"