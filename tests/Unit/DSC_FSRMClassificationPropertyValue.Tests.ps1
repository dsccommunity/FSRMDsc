$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMClassificationPropertyValue'

function Invoke-TestSetup
{
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
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

# Begin Testing
try
{
    InModuleScope $script:dscResourceName {
        # Create the Mock -CommandName Objects that will be used for running tests
        $script:MockClassificationPossibleValue1 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Top Secret'
                DisplayName = 'Top Secret'
                Description = 'Top Secret Description'
            }

        $script:MockClassificationPossibleValue2 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Secret'
                DisplayName = 'Secret'
                Description = 'Secret Description'
            }

        $script:MockClassificationPossibleValue3 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Confidential'
                DisplayName = 'Confidential'
                Description = 'Confidential Description'
            }

        $script:ClassificationProperty = [PSObject]@{
            Name = 'Privacy'
            DisplayName = 'File Privacy'
            Type = 'SingleChoice'
            Ensure = 'Present'
            Description = 'File Privacy Property'
            PossibleValue = @( $script:MockClassificationPossibleValue1.Name, $script:MockClassificationPossibleValue2.Name, $script:MockClassificationPossibleValue3.Name )
            Parameters = @( 'Parameter1=Value1', 'Parameter2=Value2')
            Verbose = $true
        }

        $script:MockClassificationProperty = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionDefinition' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = $script:ClassificationProperty.Name
                DisplayName = $script:ClassificationProperty.DisplayName
                Type = $script:ClassificationProperty.Type
                Description = $script:ClassificationProperty.Description
                Parameters = $script:ClassificationProperty.Parameters
                PossibleValue = [Microsoft.Management.Infrastructure.CimInstance[]]@( $script:MockClassificationPossibleValue1, $script:MockClassificationPossibleValue2, $script:MockClassificationPossibleValue3 )
            }

        $script:ClassificationPossibleValue1 = [PSObject]@{
            Name = $script:MockClassificationPossibleValue1.Name
            PropertyName = $script:ClassificationProperty.Name
            Description = $script:MockClassificationPossibleValue1.Description
            Verbose = $true
        }

        Describe 'DSC_FSRMClassificationPropertyValue\Get-TargetResource' {
            Context 'Classification Property does not exist' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw ClassificationPropertyNotFoundError exception' {
                    $getTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    $null = $getTargetResourceParameters.Remove('Description')

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($script:localizedData.ClassificationPropertyNotFoundError) -f $getTargetResourceParameters.PropertyName) `
                        -ArgumentName $getTargetResourceParameters.PropertyName

                    { $result = Get-TargetResource @getTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty exists but value does not' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return absent Classification Property value' {
                    $getTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    $null = $getTargetResourceParameters.Remove('Description')
                    $getTargetResourceParameters.Name = 'NotExist'
                    $result = Get-TargetResource @getTargetResourceParameters
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty and value exists' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return correct Classification Property value' {
                    $getTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    $null = $getTargetResourceParameters.Remove('Description')
                    $result = Get-TargetResource @getTargetResourceParameters
                    $result.Ensure | Should -Be 'Present'
                    $result.Name | Should -Be $script:MockClassificationPossibleValue1.Name
                    $result.DisplayName | Should -Be $script:MockClassificationPossibleValue1.DisplayName
                    $result.Description | Should -Be $script:MockClassificationPossibleValue1.Description
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }
        }

        Describe 'DSC_FSRMClassificationPropertyValue\Set-TargetResource' {
            Context 'Classification Property does not exist' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock -CommandName Set-FsrmClassificationPropertyDefinition

                It 'Should throw ClassificationPropertyNotFound exception' {
                    $setTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($script:localizedData.ClassificationPropertyNotFoundError) -f $setTargetResourceParameters.PropertyName) `
                        -ArgumentName $setTargetResourceParameters.PropertyName

                    { Set-TargetResource @setTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'Classification Property exists but value does not' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }
                Mock -CommandName Set-FsrmClassificationPropertyDefinition

                It 'Should not throw exception' {
                    $setTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    $setTargetResourceParameters.Name = 'NotExist'
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty exists and value exists' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }
                Mock -CommandName Set-FsrmClassificationPropertyDefinition

                It 'Should not throw exception' {
                    $setTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty exists and value exists but should not' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }
                Mock -CommandName Set-FsrmClassificationPropertyDefinition

                It 'Should not throw exception' {
                    $setTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    $setTargetResourceParameters.Ensure = 'Absent'
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }
        }

        Describe 'DSC_FSRMClassificationPropertyValue\Test-TargetResource' {
            Context 'Classification Property does not exist' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw ClassificationPropertyNotFound exception' {
                    $testTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($script:localizedData.ClassificationPropertyNotFoundError) -f $testTargetResourceParameters.PropertyName) `
                        -ArgumentName $testTargetResourceParameters.PropertyName

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists but value does not' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    $testTargetResourceParameters.Name = 'NotExist'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists and matching value exists' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return true' {
                    $testTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $true
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists and value with different Description exists' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    $testTargetResourceParameters.Description = 'Different'
                    $testTargetResourceParameters.Ensure = 'Absent'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists and value exists but should not' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    $testTargetResourceParameters.Ensure = 'Absent'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
