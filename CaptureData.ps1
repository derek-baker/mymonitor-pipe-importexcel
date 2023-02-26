# Depends on: 
#   https://github.com/jdhitsolutions/MyMonitor#   
#   https://jdhitsolutions.com/blog/powershell/3971/tracking-your-day-with-powershell/
param(
    [Parameter(Mandatory=$true)]
    $sessionLengthInMinutes,

    [Parameter(Mandatory=$false)]
    $outputLogsDirectory = "$PSScriptRoot\Logs"
)

if ([System.Environment]::OSVersion.Platform -eq 'Unix') {throw 'This script only works on Windows.'}

Set-StrictMode -Version 3
Import-Module './Vendor/MyMonitor/MyMonitor.psm1' -Force

function Get-Timestamp() {
   Get-Date -Format "dd-MM-yyyy_HHmmss"
}

$data = Get-WindowTime -Minutes $sessionLengthInMinutes
$data | ConvertTo-Json | Out-File -FilePath "$outputLogsDirectory\AppUsageData$(Get-Timestamp).json"

[Console]::Beep(2000, 3000)