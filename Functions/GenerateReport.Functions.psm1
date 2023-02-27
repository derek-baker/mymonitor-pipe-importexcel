$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3
Import-Module "$PSScriptRoot\Shared.Functions.psm1"

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