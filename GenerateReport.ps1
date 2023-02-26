# TODO: Support alternative 
param(
    [Parameter(Mandatory=$false)]
    $inputDataDirectory = "$PSScriptRoot\Logs",

    [Parameter(Mandatory=$false)]
    $outputReportDirectory = "$PSScriptRoot\Reports"
)

$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3
Import-Module './Functions/GenerateReport.Functions.psm1' -Force 
Install-Dependency -moduleName 'ImportExcel' -moduleVersion 7.8.4 # https://github.com/dfinke/ImportExcel
Assert-OperatingSystem

$dataFilePaths = Get-ChildItem $inputDataDirectory -Recurse `
    | Where-Object { $_.Extension -eq '.json' } `
    | ForEach-Object { $_.FullName }

$logs = $dataFilePaths | ForEach-Object {
    $rawJson = Get-Content $_ -Raw
    ConvertFrom-Json -InputObject $rawJson
}

$logEntries = @()
foreach ($log in $logs) {
    foreach ($entry in $log) {
        # TODO: Do this so it isn't slow
        $logEntries += [PSCustomObject]@{Application = $entry.Application; Seconds = $entry.Time.TotalSeconds}
    }
}

$distinctApps = $logEntries | Select-Object -ExpandProperty Application -Unique
$summaryData = @()

$distinctApps | ForEach-Object {
    $app = $_
    $totalSeconds = 0

    $logEntries `
        | Where-Object { $_.Application -eq $app } `
        | ForEach-Object { $totalSeconds += $_.Seconds } # TODO: Do this so it isn't slow

    $summaryData += [PSCustomObject]@{Application = $app; Minutes = $totalSeconds / 60}
}

$reportPathExcel = "$outputReportDirectory\MinutesPerApp_$(Get-Timestamp).xlsx"
$reportPathCsv = "$outputReportDirectory\MinutesPerApp_$(Get-Timestamp).csv"

# Create file using New-Item to ensure the parent directory is also created.
@($reportPathExcel, $reportPathCsv) | ForEach-Object {
    $path = $_
    New-Item -Path $path -ItemType File -Force | Out-Null
}

$xAxis = 'Application'
$yAxis = 'Seconds'
$chartTitle = 'Minutes per App'

$minutesPerAppChart = New-ExcelChartDefinition -XRange $xAxis -YRange $yAxis -Title $chartTitle -NoLegend
$summaryData | Export-Excel $reportPathExcel -AutoNameRange #-ExcelChartDefinition $minutesPerAppChart #-Show
$summaryData | Export-Csv -Path $reportPathCsv -NoTypeInformation 
# Export-Excel $reportPathExcel -WorksheetName 'Tab 2' -AutoSize -AutoFilter