$DSCResourceName = 'BMD_cFSRMClassificationRule'
$DSCModuleName   = 'cFSRM'

#region HEADER
if ( (-not (Test-Path -Path '.\DSCResource.Tests\')) -or `
     (-not (Test-Path -Path '.\DSCResource.Tests\TestHelper.psm1')) )
{
    & git @('clone','https://github.com/PlagueHO/DscResource.Tests.git')
}
Import-Module .\DSCResource.Tests\TestHelper.psm1 -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $DSCModuleName `
    -DSCResourceName $DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $DSCResourceName {
    
        # Create the Mock Objects that will be used for running tests
        $Global:MockClassificationRule = New-CimInstance `
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
    
        $Global:ClassificationRule = [PSObject]@{
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
        }
    
        Describe 'BMD_cFSRMClassificationRule\Get-TargetResource' {
    
            Context 'No classification rules exist' {
                
                Mock Get-FSRMClassificationRule
    
                It 'should return absent classification rule' {
                    $Result = Get-TargetResource `
                        -Name $Global:ClassificationRule.Name
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'Requested classification rule does exist' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return correct classification rule' {
                    $Result = Get-TargetResource `
                        -Name $Global:ClassificationRule.Name
                    $Result.Ensure | Should Be 'Present'
                    $Result.Name | Should Be $Global:ClassificationRule.Name
                    $Result.Description | Should Be $Global:ClassificationRule.Description
                    $Result.ClassificationMechanism | Should Be $Global:ClassificationRule.ClassificationMechanism
                    $Result.ContentRegularExpression | Should Be $Global:ClassificationRule.ContentRegularExpression
                    $Result.ContentString | Should Be $Global:ClassificationRule.ContentString
                    $Result.ContentStringCaseSensitive | Should Be $Global:ClassificationRule.ContentStringCaseSensitive
                    $Result.Disabled | Should Be $Global:ClassificationRule.Disabled
                    $Result.Flags | Should Be $Global:ClassificationRule.Flags
                    $Result.Namespace | Should Be $Global:ClassificationRule.Namespace
                    $Result.Parameters | Should Be $Global:ClassificationRule.Parameters
                    $Result.Property | Should Be $Global:ClassificationRule.Property
                    $Result.PropertyValue | Should Be $Global:ClassificationRule.PropertyValue
                    $Result.ReevaluateProperty | Should Be $Global:ClassificationRule.ReevaluateProperty
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
        }
    
        Describe 'BMD_cFSRMClassificationRule\Set-TargetResource' {
    
            Context 'classification rule does not exist but should' {
                
                Mock Get-FSRMClassificationRule
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different Description' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different ClassificationMechanism' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.ClassificationMechanism = 'Folder Classifier'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different ContentRegularExpression' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.ContentRegularExpression = @( 'Regex3','Regex4' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different ContentString' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.ContentString = @( 'String3','String4' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different ContentStringCaseSensitive' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.ContentStringCaseSensitive = @( 'String3','String4' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different Disabled' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different Flags' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Flags = @( 'ClearManuallyClassifiedProperty' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different Namespace' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Namespace = @( 'Different' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different Parameters' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Parameters = @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different Property' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Property = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different PropertyValue' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.PropertyValue = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and should but has a different ReevaluateProperty' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.ReevaluateProperty = 'Aggregate'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
    
            Context 'classification rule exists and but should not' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
                Mock New-FSRMClassificationRule
                Mock Set-FSRMClassificationRule
                Mock Remove-FSRMClassificationRule
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
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
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationRule -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationRule -Exactly 0
                }
            }
        }
    
        Describe 'BMD_cFSRMClassificationRule\Test-TargetResource' {
            Context 'classification rule does not exist but should' {
                
                Mock Get-FSRMClassificationRule
    
                It 'should return false' {
                    $Splat = $Global:ClassificationRule.Clone()
                    Test-TargetResource @Splat | Should Be $False
                    
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different Description' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different ClassificationMechanism' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.ClassificationMechanism = 'Folder Classifier'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different ContentRegularExpression' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.ContentRegularExpression =  @( 'Regex3','Regex4' )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different ContentString' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.ContentString =  @( 'String3','String4' )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different ContentStringCaseSensitive' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.ContentStringCaseSensitive =  @( 'String3','String4' )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different Disabled' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different Flags' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Flags = @( 'ClearManuallyClassifiedProperty' )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different Namespace' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Namespace = @( 'Different' )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different Parameters' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Parameters =  @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different Property' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Property = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different PropertyValue' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.PropertyValue = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should but has a different ReevaluateProperty' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.ReevaluateProperty = 'Aggregate'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and should and all parameters match' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return true' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule exists and but should not' {
                
                Mock Get-FSRMClassificationRule -MockWith { $Global:MockClassificationRule }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationRule -Exactly 1
                }
            }
    
            Context 'classification rule does not exist and should not' {
                
                Mock Get-FSRMClassificationRule
    
                It 'should return true' {
                    { 
                        $Splat = $Global:ClassificationRule.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
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