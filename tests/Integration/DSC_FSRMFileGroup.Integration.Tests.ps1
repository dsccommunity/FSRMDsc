$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMFileGroup'

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

try
{
    Describe "$($script:DSCResourceName) Integration Tests" {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).Config.ps1"
        . $configFile

        Describe "$($script:DSCResourceName)_Integration" {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & "$($script:DSCResourceName)_Config" -OutputPath $TestDrive
                    Start-DscConfiguration `
                        -Path $TestDrive `
                        -ComputerName localhost `
                        -Wait `
                        -Verbose `
                        -Force `
                        -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -throw
            }

            It 'Should have set the resource and all the parameters should match' {
                # Get the Rule details
                $filegroupNew = Get-FSRMFileGroup -Name $filegroup.Name
                $filegroup.Name | Should -Be $filegroupNew.Name
                $filegroup.Description | Should -Be $filegroupNew.Description
                $filegroup.IncludePattern | Should -Be $filegroupNew.IncludePattern
                $filegroup.ExcludePattern | Should -Be $filegroupNew.ExcludePattern
            }

            # Clean up
            Remove-FSRMFileGroup `
                -Name $filegroup.Name `
                -Confirm:$false
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
