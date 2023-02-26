#Requires -Module @{ ModuleName = 'ImportExcel'; RequiredVersion = '7.8.4' }
# To install: Install-Module -Name ImportExcel -Scope CurrentUser -RequiredVersion '7.8.4'

param(
    [Parameter(Mandatory=$false)]
    $minutesPerAppReportOutputPath = "$PSScriptRoot\MinutesPerApp.xlsx",

    [Parameter(Mandatory=$false)]
    $inputDataDirectory = "$PSScriptRoot\Logs"
)

if ([System.Environment]::OSVersion.Platform -eq 'Unix') {throw 'This script only works on Windows.'}

Set-StrictMode -Version 3

$xAxis = 'Application'
$yAxis = 'Seconds'

# $dataFilePaths = Get-ChildItem $inputDataDirectory `
#     | Where-Object { $_.Extension -eq '.json' } `
#     | ForEach-Object { $_.FullName }

# $logs = $dataFilePaths | ForEach-Object {
#     $rawJson = Get-Content $_ -Raw
#     ConvertFrom-Json -InputObject $rawJson
# }

# $logEntries = @()
# foreach ($log in $logs) {
#     foreach ($entry in $log) {
#         $logEntries += [PSCustomObject]@{Application = $entry.Application; Seconds = $entry.Time.TotalSeconds}
#     }
# }

# $distinctApps = $logEntries | Select-Object -ExpandProperty Application -Unique
# $summaryData = @()

# $distinctApps | ForEach-Object {
#     $app = $_
#     $totalSeconds = 0

#     $logEntries `
#         | Where-Object { $_.Application -eq $app } `
#         | ForEach-Object { $totalSeconds += $_.Seconds }

#     $summaryData += [PSCustomObject]@{Application = $app; Minutes = $totalSeconds / 60}
# }

# $minutesPerAppChart = New-ExcelChartDefinition -XRange $xAxis -YRange $yAxis -Title "Minutes per App" -NoLegend
# $summaryData | Export-Excel .\$reportName -AutoNameRange -ExcelChartDefinition $minutesPerAppChart -Show
# Export-Excel $xlSourcefile -WorksheetName 'Tab 2' -AutoSize -AutoFilter