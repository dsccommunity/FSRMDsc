$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMClassificationRule'

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
        $script:DSCResourceName = 'DSR_FSRMClassificationRule'

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

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
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

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'classification rule does not exist but should' {
                Mock -CommandName Get-FSRMClassificationRule
                Mock -CommandName New-FSRMClassificationRule
                Mock -CommandName Set-FSRMClassificationRule
                Mock -CommandName Remove-FSRMClassificationRule

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ClassificationMechanism = 'Folder Classifier'
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentRegularExpression = @( 'Regex3','Regex4' )
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentString = @( 'String3','String4' )
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentStringCaseSensitive = @( 'String3','String4' )
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Flags = @( 'ClearManuallyClassifiedProperty' )
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Namespace = @( 'Different' )
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Parameters = @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Property = 'Different'
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.PropertyValue = 'Different'
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ReevaluateProperty = 'Aggregate'
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
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

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'classification rule does not exist but should' {
                Mock -CommandName Get-FSRMClassificationRule

                It 'Should return false' {
                    $Splat = $script:ClassificationRule.Clone()
                    Test-TargetResource @Splat | Should -Be $False

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Description' {
                Mock -CommandName Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ClassificationMechanism = 'Folder Classifier'
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentRegularExpression =  @( 'Regex3','Regex4' )
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentString =  @( 'String3','String4' )
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentStringCaseSensitive =  @( 'String3','String4' )
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Flags = @( 'ClearManuallyClassifiedProperty' )
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Namespace = @( 'Different' )
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Parameters =  @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Property = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.PropertyValue = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ReevaluateProperty = 'Aggregate'
                        Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        Test-TargetResource @Splat | Should -Be $True
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should -Be $False
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
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassificationRule -Exactly 1
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
