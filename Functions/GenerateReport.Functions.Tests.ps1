$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3

# Install-Module Pester -Scope CurrentUser -RequiredVersion 5.4.0 -SkipPublisherCheck (If running Windows OS, you'll need to overwrite the version of Pester that ships with Windows)
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="5.4.0" }

BeforeAll {
    $sut = (Split-Path -Leaf $PSCommandPath).Replace('.Tests.ps1', '.psm1')
    Import-Module "$PSScriptRoot\$sut" -Force
}

Describe 'GenerateReport.Functions module' {
    It 'Contains the expected functions' {
        $expectedFunctions = @(
            'Get-Timestamp', 
            'Assert-OperatingSystem', 
            'Initialize-FoldersInPath')

        $actual = Get-Module | Where-Object { $_.Name -eq 'GenerateReport.Functions' } 
        $actual.ExportedFunctions.Values `
            | Where-Object { $expectedFunctions.Contains($_.Name) } `
            | Should -HaveCount $expectedFunctions.Count
    }
}

Describe 'Get-InputDataFilenames' {
    It 'TODO' {
    }
}

Describe 'Read-Inputfiles' {
    It 'TODO' {
    }
}

Describe 'Select-InputData' {
    It 'Transforms the data as expected' {
        # Arrange
        $appName = 'App'
        $seconds = 1
        $windowTitle = 'Title'
        $input = @(
            @(
                [PSCustomObject] @{Application=$appName; Time=[PSCustomObject]@{TotalSeconds=$seconds}; WindowTitle=$windowTitle},
                [PSCustomObject] @{Application=$appName; Time=[PSCustomObject]@{TotalSeconds=$seconds}; WindowTitle=$windowTitle},
                [PSCustomObject] @{Application=$appName; Time=[PSCustomObject]@{TotalSeconds=$seconds}; WindowTitle=$windowTitle}
            ),
            @(
                [PSCustomObject] @{Application=$appName; Time=[PSCustomObject]@{TotalSeconds=$seconds}; WindowTitle=$windowTitle},
                [PSCustomObject] @{Application=$appName; Time=[PSCustomObject]@{TotalSeconds=$seconds}; WindowTitle=$windowTitle}
            )
        )
        
        $expectedLength = 0
        $input | ForEach-Object { $expectedLength += $_.Count}

        # Act
        $actual = Select-InputData -logs $input
        
        # Assert
        $actual.Length | Should -Be $expectedLength
        $objectToInspect = $actual[0]
        $objectToInspect.Application | Should -Be $appName
        $objectToInspect.Seconds | Should -Be $seconds
        $objectToInspect.Title | Should -Be $windowTitle
    }
}

Describe 'Get-SummaryData' {
    It 'TODO' {
    }
}

