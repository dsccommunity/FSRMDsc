$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMClassificationPropertyValue'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Unit Test Template Version: 1.1.0
[System.String] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\FSRMDsc'
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $script:DSCResourceName {
        $script:DSCResourceName = 'DSR_FSRMClassificationPropertyValue'

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

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'Classification Property does not exist' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw ClassificationPropertyNotFoundError exception' {
                    $getTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()
                    $null = $getTargetResourceParameters.Remove('Description')

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.ClassificationPropertyNotFoundError) -f $getTargetResourceParameters.PropertyName) `
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

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'Classification Property does not exist' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock -CommandName Set-FsrmClassificationPropertyDefinition

                It 'Should throw ClassificationPropertyNotFound exception' {
                    $setTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.ClassificationPropertyNotFoundError) -f $setTargetResourceParameters.PropertyName) `
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

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'Classification Property does not exist' {
                Mock -CommandName Get-FsrmClassificationPropertyDefinition -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw ClassificationPropertyNotFound exception' {
                    $testTargetResourceParameters = $script:ClassificationPossibleValue1.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.ClassificationPropertyNotFoundError) -f $testTargetResourceParameters.PropertyName) `
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
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
