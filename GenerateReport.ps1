param(
    [Parameter(Mandatory=$false)]
    $inputDataDirectory = "$PSScriptRoot\Logs",

    [Parameter(Mandatory=$false)]
    $outputReportDirectory = "$PSScriptRoot\Reports",

    [Parameter(Mandatory=$false)]
    $browserList = @("Edge", "Chrome", "Firefox")
)

$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3
Import-Module './Functions/GenerateReport.Functions.psm1' -Force 
Import-Module 'ImportExcel' -RequiredVersion 7.8.4 # https://github.com/dfinke/ImportExcel
Assert-OperatingSystem

$dataFilePaths = Get-InputDataFilenames -inputDataDirectory $inputDataDirectory
if ($null -eq $dataFilePaths) {
    throw "The directory '$dataFilePaths' does not contain any input data files. Aborting."
}

$logs = Read-InputFiles -dataFilePaths $dataFilePaths
$logEntries = Select-InputData -logs $logs

$summaryData = Get-SummaryData -logEntries $logEntries
$browsingData = $logEntries | Where-Object { $browserList.Contains($_.Application) }

$reportPathExcel = "$outputReportDirectory\MinutesPerApp_$(Get-Timestamp).xlsx"
Initialize-FoldersInPath -path $outputReportDirectory

$xAxis = 'Application'
$yAxis = 'Minutes'
$chartTitle = 'Minutes per App'

$minutesPerAppChart = New-ExcelChartDefinition -XRange $xAxis -YRange $yAxis -Title $chartTitle -NoLegend
$summaryData | Export-Excel $reportPathExcel -AutoNameRange -ExcelChartDefinition $minutesPerAppChart -WorksheetName $chartTitle
$browsingData | Export-Excel $reportPathExcel -WorksheetName 'Browsing Data' -AutoSize -AutoFilter -Show