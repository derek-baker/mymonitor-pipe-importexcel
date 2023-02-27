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

function Get-InputDataFilenames(
    [Parameter(Mandatory=$true)]
    [string] $inputDataDirectory,

    [Parameter(Mandatory=$false)]
    [string] $fileExtension = '.json'
) {
    $filenames = Get-ChildItem $inputDataDirectory -Recurse `
        | Where-Object { $_.Extension -eq $fileExtension } `
        | ForEach-Object { $_.FullName }

    Write-Output $filenames
}

<#
    Returns: Array<PSCustomObject>
#>
function Read-Inputfiles(
    [Parameter(Mandatory=$true)]
    [string[]] $dataFilePaths
) {
    Write-Output $dataFilePaths | ForEach-Object {
        $rawJson = Get-Content $_ -Raw
        ConvertFrom-Json -InputObject $rawJson
    }
}

<#
    TODO: If we parse a bunch of logs, we may want something better than O(n^2).
    Returns: Array<{Application:string, Seconds:int, Title:string}>
#>
function Select-InputData(
    [Parameter(Mandatory=$true)]    
    [object[]] $logs
) {
    $data = foreach ($log in $logs) {
        foreach ($entry in $log) {
            Write-Host $entry
            [PSCustomObject]@{
                Application = $entry.Application
                Seconds = $entry.Time.TotalSeconds
                Title = $entry.WindowTitle
            }
        }
    }
    Write-Output $data
} 

Export-ModuleMember -Function "*"