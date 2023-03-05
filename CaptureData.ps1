param(
    [Parameter(Mandatory=$true)]
    $sessionLengthInMinutes,

    [Parameter(Mandatory=$false)]
    $outputLogsDirectory = "$PSScriptRoot\Logs"
)

$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3
Import-Module './Submodules/MyMonitor/MyMonitor.psm1' -Force
Import-Module './Functions/CaptureData.Functions.psm1' -Force 

Assert-OperatingSystem

$data = Get-WindowTime -Minutes $sessionLengthInMinutes
$outputLocation = "$outputLogsDirectory\AppUsageData$(Get-Timestamp).json"

Initialize-FoldersInPath -path $outputLogsDirectory

$data | ConvertTo-Json | Out-File -FilePath $outputLocation -Force

# [Console]::Beep(2000, 3000)