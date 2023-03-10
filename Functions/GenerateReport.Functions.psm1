$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3
Import-Module "$PSScriptRoot\Shared.Functions.psm1"

<#
    Returns: Array<string>
#>
function Get-InputDataFilenames(
    [Parameter(Mandatory=$true)]
    [string] $inputDataDirectory,

    [Parameter(Mandatory=$false)]
    [string] $fileExtension = '.json'
) {
    Get-ChildItem $inputDataDirectory -Recurse `
        | Where-Object { $_.Extension -eq $fileExtension } `
        | ForEach-Object { $_.FullName } `
        | Write-Output
}

<#
    Returns: Array<PSCustomObject>
#>
function Read-InputFiles(
    [Parameter(Mandatory=$true)]
    [string[]] $dataFilePaths
) {
    $dataFilePaths | ForEach-Object {
        $rawJson = Get-Content $_ -Raw
        ConvertFrom-Json -InputObject $rawJson
    } | Write-Output
}

<#
    TODO: If we parse a bunch of logs, we may want something better than O(n^2).
    Param '$logs': Array<Array<{Application:string, Time:{TotalSeconds:int}, WindowTitle:string}>>
    Returns: Array<{Application:string, Seconds:int, Title:string}>
#>
function Select-InputData(
    [Parameter(Mandatory=$true)]    
    [object[]] $logs
) {
    $logs | ForEach-Object {
        $log = $_
        foreach ($entry in $log) {
            $obj = [PSCustomObject] @{
                Application = $entry.Application
                Seconds = $entry.Time.TotalSeconds
                Title = $entry.WindowTitle
            }
           Write-Output $obj
        }
    } | Write-Output
} 

<#   
    Computes minutes per app.
    Returns: Array<{Application:string, Minutes:int}>
#>
function Get-SummaryData(
    [Parameter(Mandatory=$true)]
    [PSCustomObject[]] $logEntries # Array<{Application:string, Seconds:int, Title:string}>
) {
    $distinctApps = $logEntries | Select-Object -ExpandProperty Application -Unique

    $distinctApps | ForEach-Object {
        $app = $_
        $totalSeconds = 0
        $logEntries `
            | Where-Object { $_.Application -eq $app } `
            | ForEach-Object { $totalSeconds += $_.Seconds }
            
        [PSCustomObject] @{
            Application = $app
            Minutes = [System.Math]::Round($totalSeconds / 60, 2)
        }
    } | Write-Output
}

Export-ModuleMember -Function "*"