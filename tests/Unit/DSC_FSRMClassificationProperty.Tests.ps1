$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMClassificationProperty'

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
            Name        = 'Top Secret'
            Description = ''
        }

        $script:MockClassificationPossibleValue2 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Name        = 'Secret'
            Description = ''
        }

        $script:MockClassificationPossibleValue3 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Name        = 'Confidential'
            Description = ''
        }

        $script:ClassificationProperty = [PSObject]@{
            Name          = 'Privacy'
            DisplayName   = 'File Privacy'
            Type          = 'SingleChoice'
            Ensure        = 'Present'
            Description   = 'File Privacy Property'
            PossibleValue = @( $script:MockClassificationPossibleValue1.Name, $script:MockClassificationPossibleValue2.Name, $script:MockClassificationPossibleValue3.Name )
            Parameters    = @( 'Parameter1=Value1', 'Parameter2=Value2')
            Verbose       = $true
        }

        $script:MockClassificationProperty = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionDefinition' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Name          = $script:ClassificationProperty.Name
            DisplayName   = $script:ClassificationProperty.DisplayName
            Type          = $script:ClassificationProperty.Type
            Description   = $script:ClassificationProperty.Description
            Parameters    = $script:ClassificationProperty.Parameters
            PossibleValue = [Microsoft.Management.Infrastructure.CimInstance[]]@( $script:MockClassificationPossibleValue1, $script:MockClassificationPossibleValue2, $script:MockClassificationPossibleValue3 )
        }

        Describe 'DSC_FSRMClassificationProperty\Get-TargetResource' {
            Context 'No classification properties exist' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition

                It 'Should return absent classification property' {
                    $result = Get-TargetResource -Name $script:ClassificationProperty.Name -Type $script:ClassificationProperty.Type -Verbose
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Requested classification property does exist' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return correct classification property' {
                    $result = Get-TargetResource -Name $script:ClassificationProperty.Name -Type $script:ClassificationProperty.Type -Verbose
                    $result.Ensure | Should -Be 'Present'
                    $result.Name | Should -Be $script:ClassificationProperty.Name
                    $result.DisplayName | Should -Be $script:ClassificationProperty.DisplayName
                    $result.Description | Should -Be $script:ClassificationProperty.Description
                    $result.Type | Should -Be $script:ClassificationProperty.Type
                    $result.PossibleValue | Should -Be $script:ClassificationProperty.PossibleValue
                    $result.Parameters | Should -Be $script:ClassificationProperty.Parameters
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
        }

        Describe 'DSC_FSRMClassificationProperty\Set-TargetResource' {
            Context 'classification property does not exist but should' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition
                Mock -CommandName New-FSRMClassificationPropertyDefinition
                Mock -CommandName Set-FSRMClassificationPropertyDefinition
                Mock -CommandName Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationProperty.Clone()
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -CommandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'classification property exists and should but has a different DisplayName' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock -CommandName New-FSRMClassificationPropertyDefinition
                Mock -CommandName Set-FSRMClassificationPropertyDefinition
                Mock -CommandName Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $setTargetResourceParameters.DisplayName = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'classification property exists and should but has a different Description' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock -CommandName New-FSRMClassificationPropertyDefinition
                Mock -CommandName Set-FSRMClassificationPropertyDefinition
                Mock -CommandName Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $setTargetResourceParameters.Description = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'classification property exists and should but has a different Type' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock -CommandName New-FSRMClassificationPropertyDefinition
                Mock -CommandName Set-FSRMClassificationPropertyDefinition
                Mock -CommandName Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $setTargetResourceParameters.Type = 'YesNo'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -CommandName Remove-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different PossibleValue' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock -CommandName New-FSRMClassificationPropertyDefinition
                Mock -CommandName Set-FSRMClassificationPropertyDefinition
                Mock -CommandName Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $setTargetResourceParameters.PossibleValue = @( $script:MockClassificationPossibleValue1.Name, $script:MockClassificationPossibleValue2.Name )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'classification property exists and should but has a different Parameters' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock -CommandName New-FSRMClassificationPropertyDefinition
                Mock -CommandName Set-FSRMClassificationPropertyDefinition
                Mock -CommandName Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $setTargetResourceParameters.Parameters = @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'classification property exists and but should not' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock -CommandName New-FSRMClassificationPropertyDefinition
                Mock -CommandName Set-FSRMClassificationPropertyDefinition
                Mock -CommandName Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -CommandName Remove-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property does not exist and should not' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition
                Mock -CommandName New-FSRMClassificationPropertyDefinition
                Mock -CommandName Set-FSRMClassificationPropertyDefinition
                Mock -CommandName Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -CommandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }
        }

        Describe 'DSC_FSRMClassificationProperty\Test-TargetResource' {
            Context 'classification property does not exist but should' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationProperty.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different DisplayName' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $testTargetResourceParameters.DisplayName = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different Description' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $testTargetResourceParameters.Description = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different Type' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $testTargetResourceParameters.Type = 'YesNo'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different PossibleValue' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $testTargetResourceParameters.PossibleValue = @( $script:MockClassificationPossibleValue1.Name, $script:MockClassificationPossibleValue2.Name )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different Parameters' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $testTargetResourceParameters.Parameters = @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should and all parameters match' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:ClassificationProperty.Clone()
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and but should not' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property does not exist and should not' {
                Mock -CommandName Get-FSRMClassificationPropertyDefinition

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:ClassificationProperty.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
