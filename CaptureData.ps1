param(
    [Parameter(Mandatory=$true)]
    [int] $sessionLengthInMinutes,

    [Parameter(Mandatory=$false)]
    [string] $outputLogsDirectory = "$PSScriptRoot\Logs"
)

$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3
Assert-OperatingSystem

[ScriptBlock] $jobScriptBlock = { 
    param($minutes, $workingDir) 
    Import-Module "$workingDir/Submodules/MyMonitor/MyMonitor.psm1" -Force
    Import-Module "$workingDir/Functions/CaptureData.Functions.psm1" -Force
    Get-WindowTime -Minutes $minutes 
}
[DateTime] $jobStartTime = Get-Date 

$job = Start-Job `
    -ScriptBlock $jobScriptBlock `
    -ArgumentList @($sessionLengthInMinutes, $PSScriptRoot) `
    -Verbose

while ($job.State -eq 'Running') {
    [DateTime] $currentTime = Get-Date
    [TimeSpan] $timespan = $currentTime - $jobStartTime
    [int] $secondsPassed = $timespan.Seconds
    
    $progress = (($secondsPassed / ($sessionLengthInMinutes * 60)) * 100)
    Write-Progress `
        -Activity "App Usage Data Capture" `
        -Status "Progress: $progress%" `
        -PercentComplete $progress
}

$data = Receive-Job -Job $job
Initialize-FoldersInPath -path $outputLogsDirectory
$outputDataLocation = "$outputLogsDirectory\AppUsageData$(Get-Timestamp).json"
$data | ConvertTo-Json | Out-File -FilePath $outputDataLocation -Force

# If you want an audio cue for completion:
# [Console]::Beep(2000, 3000)