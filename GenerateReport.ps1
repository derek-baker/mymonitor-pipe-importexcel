param(
    [Parameter(Mandatory=$false)]
    $inputDataDirectory = "$PSScriptRoot\Logs",

    [Parameter(Mandatory=$false)]
    $outputReportDirectory = "$PSScriptRoot\Reports"
)
$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3
Import-Module './Functions/GenerateReport.Functions.psm1' -Force 
Install-Dependency -moduleName 'ImportExcel' -moduleVersion 7.8.4
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

$xAxis = 'Application'
$yAxis = 'Seconds'
$minutesPerAppChart = New-ExcelChartDefinition -XRange $xAxis -YRange $yAxis -Title "Minutes per App" -NoLegend

$reportPath = "$outputReportDirectory\MinutesPerApp.xlsx"
#Create file using New-Item to ensure the parent directory is also created.
New-Item -Path $reportPath -ItemType File -Force | Out-Null
$summaryData | Export-Excel $reportPath -AutoNameRange -ExcelChartDefinition $minutesPerAppChart #-Show
# Export-Excel $xlSourcefile -WorksheetName 'Tab 2' -AutoSize -AutoFilter