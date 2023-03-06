$ErrorActionPreference = "Stop";
Set-StrictMode -Version 3

function Get-Timestamp(
    [Parameter(Mandatory=$false)]
    [string] $timestampFormat = "dd-MM-yyyy_HHmmss"
) {
    Get-Date -Format $timestampFormat
}

function Assert-OperatingSystem(
    [Parameter(Mandatory=$false)]
    [string[]] $expectedOperatingSystems = @('Win32NT', 'Unix')
) {
    $actualOs = [System.Environment]::OSVersion.Platform.ToString()
    if (-not $expectedOperatingSystems.Contains($actualOs)) {
        throw "This script only works when [System.Environment]::OSVersion.Platform is one of: $([string]::Join(", ", $expectedOperatingSystems))"
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