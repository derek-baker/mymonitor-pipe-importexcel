$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3

# Install-Module Pester -Scope CurrentUser -RequiredVersion 5.4.0 -SkipPublisherCheck (If running Windows OS, you'll need to overwrite the version of Pester that ships with Windows)
#Requires -Modules  @{ ModuleName="Pester"; ModuleVersion="5.4.0" }
$testDrive = 'TestDrive:'

BeforeAll {
    $sut = (Split-Path -Leaf $PSCommandPath).Replace('.Tests.ps1', '.psm1')
    Import-Module "$PSScriptRoot\$sut" -Force
}

Describe 'Get-Timestamp' {
    It 'Returns a timestamp that can be used for a file.' {
        # Act
        $timestamp = Get-Timestamp
        $newFile = New-Item "$testDrive\tmp_$timestamp.tmp" 

        # Assert
        [string]::IsNullOrWhiteSpace($timestamp) | Should -Be $false
        $newFile | Should -Not -Be $null   
    }
}

Describe 'Assert-OperatingSystem' {
    It 'Throws when an unexpected operating system is detected.' {
        # Act
        $actual = { Assert-OperatingSystem -expectedOperatingSystems @('Lunix') }

        # Assert
        $actual | Should -Throw
    }
    It 'Does not throw when an expected operating system is detected.' {
        # Act
        $actual = { Assert-OperatingSystem }

        # Assert
        $actual | Should -Not -Throw
    }
}

Describe 'Initialize-FoldersInPath' {
    It 'Creates folders in path if they do not exist.' {
        # Arrange
        $dir1 = 'new1'
        $dir2 = 'new2'

        #Act
        Initialize-FoldersInPath -path "$testDrive\$dir1\$dir2"

        # Assert
        Test-Path -Path "$testDrive\$dir1" | Should -Be $true
        Test-Path -Path "$testDrive\$dir1\$dir2" | Should -Be $true
    }
}

