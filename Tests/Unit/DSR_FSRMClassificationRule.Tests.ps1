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

        # Create the Mock Objects that will be used for running tests
        $script:MockClassificationRule = New-CimInstance `
            -ClassName 'DSR_FSRMClassificationRule' `
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
                Mock Get-FSRMClassificationRule

                It 'Should return absent classification rule' {
                    $Result = Get-TargetResource `
                        -Name $script:ClassificationRule.Name
                    $Result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'Requested classification rule does exist' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return correct classification rule' {
                    $Result = Get-TargetResource `
                        -Name $script:ClassificationRule.Name
                    $Result.Ensure | Should -Be 'Present'
                    $Result.Name | Should -Be $script:ClassificationRule.Name
                    $Result.Description | Should -Be $script:ClassificationRule.Description
                    $Result.ClassificationMechanism | Should -Be $script:ClassificationRule.ClassificationMechanism
                    $Result.ContentRegularExpression | Should -Be $script:ClassificationRule.ContentRegularExpression
                    $Result.ContentString | Should -Be $script:ClassificationRule.ContentString
                    $Result.ContentStringCaseSensitive | Should -Be $script:ClassificationRule.ContentStringCaseSensitive
                    $Result.Disabled | Should -Be $script:ClassificationRule.Disabled
                    $Result.Flags | Should -Be $script:ClassificationRule.Flags
                    $Result.Namespace | Should -Be $script:ClassificationRule.Namespace
                    $Result.Parameters | Should -Be $script:ClassificationRule.Parameters
                    $Result.Property | Should -Be $script:ClassificationRule.Property
                    $Result.PropertyValue | Should -Be $script:ClassificationRule.PropertyValue
                    $Result.ReevaluateProperty | Should -Be $script:ClassificationRule.ReevaluateProperty
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'classification rule does not exist but should' {
                Mock Get-FSRMClassificationRule
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Description' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different ClassificationMechanism' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ClassificationMechanism = 'Folder Classifier'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different ContentRegularExpression' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentRegularExpression = @( 'Regex3','Regex4' )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different ContentString' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentString = @( 'String3','String4' )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different ContentStringCaseSensitive' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentStringCaseSensitive = @( 'String3','String4' )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Disabled' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Flags' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Flags = @( 'ClearManuallyClassifiedProperty' )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Namespace' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Namespace = @( 'Different' )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Parameters' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Parameters = @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different Property' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Property = 'Different'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different PropertyValue' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.PropertyValue = 'Different'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and should but has a different ReevaluateProperty' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ReevaluateProperty = 'Aggregate'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }

            Context 'classification rule exists and but should not' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule does not exist and should not' {
                Mock Get-FSRMClassificationRule
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'classification rule does not exist but should' {
                Mock Get-FSRMClassificationRule

                It 'Should return false' {
                    $Splat = $script:ClassificationRule.Clone()
                    Test-TargetResource @Splat | Should -Be $False

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Description' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different ClassificationMechanism' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ClassificationMechanism = 'Folder Classifier'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different ContentRegularExpression' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentRegularExpression =  @( 'Regex3','Regex4' )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different ContentString' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentString =  @( 'String3','String4' )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different ContentStringCaseSensitive' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ContentStringCaseSensitive =  @( 'String3','String4' )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Disabled' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Flags' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Flags = @( 'ClearManuallyClassifiedProperty' )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Namespace' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Namespace = @( 'Different' )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Parameters' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Parameters =  @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different Property' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Property = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different PropertyValue' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.PropertyValue = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should but has a different ReevaluateProperty' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.ReevaluateProperty = 'Aggregate'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and should and all parameters match' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return true' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule exists and but should not' {
                Mock Get-FSRMClassificationRule -MockWith { $script:MockClassificationRule }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }

            Context 'classification rule does not exist and should not' {
                Mock Get-FSRMClassificationRule

                It 'Should return true' {
                    {
                        $Splat = $script:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
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
