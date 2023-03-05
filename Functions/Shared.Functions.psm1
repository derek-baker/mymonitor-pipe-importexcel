$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3

function Get-Timestamp() {
    Get-Date -Format "dd-MM-yyyy_HHmmss"
}

function Assert-OperatingSystem(
    [Parameter(Mandatory=$false)]
    [string] $expectedOs = 'Win32NT'
) {
    $actualOs = [System.Environment]::OSVersion.Platform
    if ($actualOs -ne $expectedOs) {
        throw "This script only works when [System.Environment]::OSVersion.Platform is $expectedOs"
    }
}

function Initialize-FoldersInPath(
    [Parameter(Mandatory=$true)]
    [string] $path
) {
    $tempFile = 'tmp.txt'
    # Create file using New-Item to ensure any parent directories are also created.
    New-Item -Path "$path\$tempFile" -ItemType File -Force | Out-Null
    Remove-Item -Path $path\$tempFile -Force | Out-Null
}

Export-ModuleMember -Function "*"