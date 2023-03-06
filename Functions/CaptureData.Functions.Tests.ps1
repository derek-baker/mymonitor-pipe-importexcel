$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3

# Install-Module Pester -Scope CurrentUser -RequiredVersion 5.4.0 -SkipPublisherCheck (If running Windows OS, you'll need to overwrite the version of Pester that ships with Windows)
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="5.4.0" }

BeforeAll {
    $sut = (Split-Path -Leaf $PSCommandPath).Replace('.Tests.ps1', '.psm1')
    Import-Module "$PSScriptRoot\$sut" -Force
}

Describe 'CaptureData.Functions module' {
    It 'Contains the expected functions' {
        $expectedFunctions = @(
            'Get-Timestamp', 
            'Assert-OperatingSystem', 
            'Initialize-FoldersInPath')

        $actual = Get-Module | Where-Object { $_.Name -eq 'CaptureData.Functions' } 
        $actual.ExportedFunctions.Values `
            | Where-Object { $expectedFunctions.Contains($_.Name) } `
            | Should -HaveCount $expectedFunctions.Count
    }
}
