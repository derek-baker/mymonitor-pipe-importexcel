$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3

# Install-Module Pester -Scope CurrentUser -RequiredVersion 5.4.0 -SkipPublisherCheck (If running Windows OS, you'll need to overwrite the version of Pester that ships with Windows)
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="5.4.0" }

BeforeAll {
    $sut = (Split-Path -Leaf $PSCommandPath).Replace('.Tests.ps1', '.psm1')
    Import-Module "$PSScriptRoot\$sut" -Force

    function Convert-TestDrivePath([string] $path) {
        return $path.Replace('TestDrive:', (Get-PSDrive TestDrive).Root)
    }
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
    It 'Gets filenames as expected' {
        # Arrange
        $dataDirectory = "TestDrive:"
        $fileType = "json"
        $filePath = "$dataDirectory/$([Guid]::NewGuid().ToString()).$fileType"
        New-Item -Path $filePath -ItemType File | Out-Null
        
        # Act
        $actual = Get-InputDataFilenames -inputDataDirectory $dataDirectory
        
        #Assert
        $actual | Should -Be (Convert-TestDrivePath -path $filePath)
    }
}

Describe 'Read-InputFiles' {
    It 'Reads input files' {
        # Arrange
        $filePath = "TestDrive:/$([Guid]::NewGuid().ToString()).json"
        $testInput = @($filePath)
        New-Item -Path $filePath -ItemType File | Out-Null
        
        $expected = [PSCustomObject]@{ A = 1 }
        $expected `
            | ConvertTo-Json `
            | Out-File -FilePath $filePath `
            | Out-Null

        # Act
        $actual = Read-InputFiles -dataFilePaths $testInput

        # Assert
        $actual.A | Should -Be 1 
    }
}

Describe 'Select-InputData' {
    It 'Transforms the data as expected' {
        # Arrange
        $appName = 'App'
        $seconds = 1
        $windowTitle = 'Title'
        $testInput = @(
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
        $testInput | ForEach-Object { $expectedLength += $_.Count}

        # Act
        $actual = Select-InputData -logs $testInput
        
        # Assert
        $actual.Length | Should -Be $expectedLength
        $objectToInspect = $actual[0]
        $objectToInspect.Application | Should -Be $appName
        $objectToInspect.Seconds | Should -Be $seconds
        $objectToInspect.Title | Should -Be $windowTitle
    }
}

Describe 'Get-SummaryData' {
    It 'Gets a summary of app usage data' {
        # Arrange
        $slack = "Slack"
        $atom = "Atom"
        $logEntries = @(
            [PSCustomObject]@{ Application = $slack; Seconds = 60; Title = 'FakeTitle1'},
            [PSCustomObject]@{ Application = $slack; Seconds = 60; Title = 'FakeTitle1'},
            [PSCustomObject]@{ Application = $slack; Seconds = 60; Title = 'FakeTitle1'},
            [PSCustomObject]@{ Application = $atom; Seconds = 30; Title = 'FakeTitle2'},
            [PSCustomObject]@{ Application = $atom; Seconds = 30; Title = 'FakeTitle2'})

        # Act
        $actual = Get-SummaryData -logEntries $logEntries

        # Assert
        $actual `
            | Where-Object { $_.Application -eq $slack } `
            | Select-Object -ExpandProperty Minutes
            | Should -Be 3
        $actual `
            | Where-Object { $_.Application -eq $atom } `
            | Select-Object -ExpandProperty Minutes
            | Should -Be 1
    }
}

