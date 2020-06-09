$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMClassificationRule'

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
        $script:MockClassificationRule = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationRule' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Test Rule'
                Description = 'Test Rule Description'
                ClassificationMechanism  = 'Content Classifier'
                ContentRegularExpression = @( 'Regex1','Regex2' )
                ContentString = @( 'String1','String2' )
                ContentStringCaseSensitive = @( 'String1','String2' )
                Disabled = $false
                Flags = @( 1024 )
                Namespace = @( '[FolderUsage_MS=User Files]','d:\Users' )
                Parameters = @( 'FileName=*.doc','FSRMClearruleInternal=0' )
                Property = 'Privacy'
                PropertyValue = 'Confidential'
                ReevaluateProperty = 'Never'
            }

        $script:ClassificationRule = [PSObject]@{
            Name = $MockClassificationRule.Name
            Description = $MockClassificationRule.Description
            ClassificationMechanism  = $MockClassificationRule.ClassificationMechanism
            ContentRegularExpression = $MockClassificationRule.ContentRegularExpression
            ContentString = $MockClassificationRule.ContentString
            ContentStringCaseSensitive = $MockClassificationRule.ContentStringCaseSensitive
            Disabled = $MockClassificationRule.Disabled
            Flags = $MockClassificationRule.Flags
            Namespace = $MockClassificationRule.Namespace
            Parameters = $MockClassificationRule.Parameters
            Property = $MockClassificationRule.Property
            PropertyValue = $MockClassificationRule.PropertyValue
            ReevaluateProperty = $MockClassificationRule.ReevaluateProperty
            Verbose = $true
        }

        Describe 'DSC_FSRMClassificationRule\Get-TargetResource' {
            Context 'No classification rules exist' {
                Mock -CommandName Get-FSRMClassificationRule

                It 'Should return absent classification rule' {
                    $result = Get-TargetResource -Name $script:ClassificationRule.Name -Verbose
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'Requested classification rule does exist' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return correct classification rule' {
                    $result = Get-TargetResource -Name $script:ClassificationRule.Name -Verbose
                    $result.Ensure | Should -Be 'Present'
                    $result.Name | Should -Be $script:ClassificationRule.Name
                    $result.Description | Should -Be $script:ClassificationRule.Description
                    $result.ClassificationMechanism | Should -Be $script:ClassificationRule.ClassificationMechanism
                    $result.ContentRegularExpression | Should -Be $script:ClassificationRule.ContentRegularExpression
                    $result.ContentString | Should -Be $script:ClassificationRule.ContentString
                    $result.ContentStringCaseSensitive | Should -Be $script:ClassificationRule.ContentStringCaseSensitive
                    $result.Disabled | Should -Be $script:ClassificationRule.Disabled
                    $result.Flags | Should -Be $script:ClassificationRule.Flags
                    $result.Namespace | Should -Be $script:ClassificationRule.Namespace
                    $result.Parameters | Should -Be $script:ClassificationRule.Parameters
                    $result.Property | Should -Be $script:ClassificationRule.Property
                    $result.PropertyValue | Should -Be $script:ClassificationRule.PropertyValue
                    $result.ReevaluateProperty | Should -Be $script:ClassificationRule.ReevaluateProperty
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }
        }

        Describe 'DSC_FSRMClassificationRule\Set-TargetResource' {
            Context 'classification rule does not exist but should' {
                Mock -CommandName Get-FSRMClassificationRule
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Description' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.Description = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different ClassificationMechanism' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.ClassificationMechanism = 'Folder Classifier'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different ContentRegularExpression' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.ContentRegularExpression = @( 'Regex3','Regex4' )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different ContentString' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.ContentString = @( 'String3','String4' )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different ContentStringCaseSensitive' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.ContentStringCaseSensitive = @( 'String3','String4' )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Disabled' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.Disabled = (-not $setTargetResourceParameters.Disabled)
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Flags' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.Flags = @( 'ClearManuallyClassifiedProperty' )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Namespace' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.Namespace = @( 'Different' )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Parameters' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.Parameters = @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Property' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.Property = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different PropertyValue' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.PropertyValue = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different ReevaluateProperty' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.ReevaluateProperty = 'Aggregate'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and but should not' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule does not exist and should not' {
                Mock -CommandName Get-FSRMClassificationRule
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationRule.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -CommandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Set-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -CommandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
        }

        Describe 'DSC_FSRMClassificationRule\Test-TargetResource' {
            Context 'classification rule does not exist but should' {
                Mock -CommandName Get-FSRMClassificationRule

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationRule.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Description' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.Description = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different ClassificationMechanism' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.ClassificationMechanism = 'Folder Classifier'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different ContentRegularExpression' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.ContentRegularExpression =  @( 'Regex3','Regex4' )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different ContentString' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.ContentString =  @( 'String3','String4' )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different ContentStringCaseSensitive' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.ContentStringCaseSensitive =  @( 'String3','String4' )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Disabled' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.Disabled = (-not $testTargetResourceParameters.Disabled)
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Flags' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.Flags = @( 'ClearManuallyClassifiedProperty' )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Namespace' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.Namespace = @( 'Different' )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Parameters' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.Parameters =  @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Property' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.Property = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different PropertyValue' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.PropertyValue = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different ReevaluateProperty' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.ReevaluateProperty = 'Aggregate'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should and all parameters match' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and but should not' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule does not exist and should not' {
                Mock -CommandName Get-FSRMClassificationRule

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:ClassificationRule.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
