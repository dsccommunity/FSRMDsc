$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMClassificationPropertyValue'

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

        Describe "$($script:dscResourceName)_Integration" {
            $configData = @{
                AllNodes = @(
                    @{
                        NodeName     = 'localhost'
                        Name         = 'IntegrationTest'
                        PropertyName = 'IntegrationTest'
                        Description  = 'Top Secret Description'
                    }
                )
            }

            # Create the Classification Property that will be worked with
            New-FSRMClassificationPropertyDefinition `
                -Name $configData.AllNodes[0].Name `
                -Type 'SingleChoice' `
                -PossibleValue @(New-FSRMClassificationPropertyValue -Name 'None')

            It 'Should compile and apply the MOF without throwing' {
                {
                    & "$($script:dscResourceName)_Config" `
                        -OutputPath $TestDrive `
                        -ConfigurationData $configData

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $current = Get-DscConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq "$($script:dscResourceName)_Config"
                }
                $current.Name | Should -BeExactly $configData.AllNodes[0].Name
                $current.PropertyName | Should -BeExactly $configData.AllNodes[0].PropertyName
                $current.Description | Should -BeExactly $configData.AllNodes[0].Description
            }

            # Clean up
            Remove-FSRMClassificationPropertyDefinition `
                -Name $configData.AllNodes[0].Name `
                -Confirm:$false
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
