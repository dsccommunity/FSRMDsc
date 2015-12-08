$DSCResourceName = 'BMD_cFSRMClassificationProperty'
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
        $Global:MockClassificationPossibleValue1 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Top Secret'
                Description = ''
            }
        $Global:MockClassificationPossibleValue2 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Secret'
                Description = ''
            }
        $Global:MockClassificationPossibleValue3 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Confidential'
                Description = ''
            }
    
        $Global:ClassificationProperty = [PSObject]@{
            Name = 'Privacy'
            DisplayName = 'File Privacy'
            Type = 'SingleChoice'
            Ensure = 'Present'
            Description = 'File Privacy Property'
            PossibleValue = @( $Global:MockClassificationPossibleValue1.Name, $Global:MockClassificationPossibleValue2.Name, $Global:MockClassificationPossibleValue3.Name )
            Parameters = @( 'Parameter1=Value1', 'Parameter2=Value2')
        }
        $Global:MockClassificationProperty = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionDefinition' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = $Global:ClassificationProperty.Name
                DisplayName = $Global:ClassificationProperty.DisplayName
                Type = $Global:ClassificationProperty.Type
                Description = $Global:ClassificationProperty.Description
                Parameters = $Global:ClassificationProperty.Parameters
                PossibleValue = [Microsoft.Management.Infrastructure.CimInstance[]]@( $Global:MockClassificationPossibleValue1, $Global:MockClassificationPossibleValue2, $Global:MockClassificationPossibleValue3 )
            }
    
        Describe 'BMD_cFSRMClassificationProperty\Get-TargetResource' {
    
            Context 'No classification properties exist' {
                
                Mock Get-FSRMClassificationPropertyDefinition
    
                It 'should return absent classification property' {
                    $Result = Get-TargetResource `
                        -Name $Global:ClassificationProperty.Name `
                        -Type $Global:ClassificationProperty.Type
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'Requested classification property does exist' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
    
                It 'should return correct classification property' {
                    $Result = Get-TargetResource `
                        -Name $Global:ClassificationProperty.Name `
                        -Type $Global:ClassificationProperty.Type                    
                    $Result.Ensure | Should Be 'Present'
                    $Result.Name | Should Be $Global:ClassificationProperty.Name
                    $Result.DisplayName | Should Be $Global:ClassificationProperty.DisplayName
                    $Result.Description | Should Be $Global:ClassificationProperty.Description
                    $Result.Type | Should Be $Global:ClassificationProperty.Type
                    $Result.PossibleValue | Should Be $Global:ClassificationProperty.PossibleValue
                    $Result.Parameters | Should Be $Global:ClassificationProperty.Parameters
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
        }
    
        Describe 'BMD_cFSRMClassificationProperty\Set-TargetResource' {
    
            Context 'classification property does not exist but should' {
                
                Mock Get-FSRMClassificationPropertyDefinition
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }
    
            Context 'classification property exists and should but has a different DisplayName' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.DisplayName = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }
    
            Context 'classification property exists and should but has a different Description' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }
    
            Context 'classification property exists and should but has a different Type' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.Type = 'YesNo'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'classification property exists and should but has a different PossibleValue' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.PossibleValue = @( $Global:MockClassificationPossibleValue1.Name, $Global:MockClassificationPossibleValue2.Name )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }
    
            Context 'classification property exists and should but has a different Parameters' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.Parameters = @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }
    
            Context 'classification property exists and but should not' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'classification property does not exist and should not' {
                
                Mock Get-FSRMClassificationPropertyDefinition
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }
        }
    
        Describe 'BMD_cFSRMClassificationProperty\Test-TargetResource' {
            Context 'classification property does not exist but should' {
                
                Mock Get-FSRMClassificationPropertyDefinition
    
                It 'should return false' {
                    $Splat = $Global:ClassificationProperty.Clone()
                    Test-TargetResource @Splat | Should Be $False
                    
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'classification property exists and should but has a different DisplayName' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.DisplayName = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'classification property exists and should but has a different Description' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'classification property exists and should but has a different Type' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.Type = 'YesNo'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'classification property exists and should but has a different PossibleValue' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.PossibleValue = @( $Global:MockClassificationPossibleValue1.Name, $Global:MockClassificationPossibleValue2.Name )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'classification property exists and should but has a different Parameters' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.Parameters =  @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'classification property exists and should and all parameters match' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
    
                It 'should return true' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'classification property exists and but should not' {
                
                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $Global:MockClassificationProperty }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
    
            Context 'classification property does not exist and should not' {
                
                Mock Get-FSRMClassificationPropertyDefinition
    
                It 'should return true' {
                    { 
                        $Splat = $Global:ClassificationProperty.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
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