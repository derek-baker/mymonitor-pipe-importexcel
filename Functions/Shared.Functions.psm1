function Get-Timestamp() {
    Get-Date -Format "dd-MM-yyyy_HHmmss"
}

function Assert-OperatingSystem([string] $expectedOs = 'Win32NT') {
    $actualOs = [System.Environment]::OSVersion.Platform
    if ($actualOs -ne $expectedOs) {
        throw "This script only works when [System.Environment]::OSVersion.Platform is $expectedOs"
    }
}

Export-ModuleMember -Function "*"