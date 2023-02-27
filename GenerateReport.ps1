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

$dataFilePaths = Get-InputDataFilenames -inputDataDirectory $inputDataDirectory
$logs = Read-Inputfiles -dataFilePaths $dataFilePaths 
$logEntries = Parse-InputFiles -logs $logs
$distinctApps = $logEntries | Select-Object -ExpandProperty Application -Unique

$summaryData = $distinctApps | ForEach-Object {
    $app = $_

    $totalSeconds = 0
    $logEntries `
        | Where-Object { $_.Application -eq $app } `
        | ForEach-Object { $totalSeconds += $_.Seconds } 

    [PSCustomObject]@{Application = $app; Minutes = $totalSeconds / 60}
}

$reportPathExcel = "$outputReportDirectory\MinutesPerApp_$(Get-Timestamp).xlsx"
$reportPathCsv = "$outputReportDirectory\MinutesPerApp_$(Get-Timestamp).csv"

@($reportPathExcel, $reportPathCsv) | ForEach-Object {
    $path = $_
    # Create file using New-Item to ensure any parent directories are also created.
    New-Item -Path $path -ItemType File -Force | Out-Null
}

$xAxis = 'Application'
$yAxis = 'Seconds'
$chartTitle = 'Minutes per App'

$minutesPerAppChart = New-ExcelChartDefinition -XRange $xAxis -YRange $yAxis -Title $chartTitle -NoLegend
$summaryData | Export-Excel $reportPathExcel -AutoNameRange -ExcelChartDefinition $minutesPerAppChart #-Show
$summaryData | Export-Csv -Path $reportPathCsv -NoTypeInformation 

# TODO: Add additional sheet (or separate file) having data on time by webpage in Edge
# Export-Excel $reportPathExcel -WorksheetName 'Tab 2' -AutoSize -AutoFilter