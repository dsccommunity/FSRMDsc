$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMClassificationProperty'

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
        $script:DSCResourceName = 'DSR_FSRMClassificationProperty'

        # Create the Mock Objects that will be used for running tests
        $script:MockClassificationPossibleValue1 = New-CimInstance `
            -ClassName 'DSR_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Top Secret'
                Description = ''
            }
        $script:MockClassificationPossibleValue2 = New-CimInstance `
            -ClassName 'DSR_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Secret'
                Description = ''
            }
        $script:MockClassificationPossibleValue3 = New-CimInstance `
            -ClassName 'DSR_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Confidential'
                Description = ''
            }

        $script:ClassificationProperty = [PSObject]@{
            Name = 'Privacy'
            DisplayName = 'File Privacy'
            Type = 'SingleChoice'
            Ensure = 'Present'
            Description = 'File Privacy Property'
            PossibleValue = @( $script:MockClassificationPossibleValue1.Name, $script:MockClassificationPossibleValue2.Name, $script:MockClassificationPossibleValue3.Name )
            Parameters = @( 'Parameter1=Value1', 'Parameter2=Value2')
        }
        $script:MockClassificationProperty = New-CimInstance `
            -ClassName 'DSR_FSRMClassificationPropertyDefinitionDefinition' `
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

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'No classification properties exist' {

                Mock Get-FSRMClassificationPropertyDefinition

                It 'Should return absent classification property' {
                    $Result = Get-TargetResource `
                        -Name $script:ClassificationProperty.Name `
                        -Type $script:ClassificationProperty.Type
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Requested classification property does exist' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return correct classification property' {
                    $Result = Get-TargetResource `
                        -Name $script:ClassificationProperty.Name `
                        -Type $script:ClassificationProperty.Type
                    $Result.Ensure | Should Be 'Present'
                    $Result.Name | Should Be $script:ClassificationProperty.Name
                    $Result.DisplayName | Should Be $script:ClassificationProperty.DisplayName
                    $Result.Description | Should Be $script:ClassificationProperty.Description
                    $Result.Type | Should Be $script:ClassificationProperty.Type
                    $Result.PossibleValue | Should Be $script:ClassificationProperty.PossibleValue
                    $Result.Parameters | Should Be $script:ClassificationProperty.Parameters
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'classification property does not exist but should' {

                Mock Get-FSRMClassificationPropertyDefinition
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'classification property exists and should but has a different DisplayName' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.DisplayName = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'classification property exists and should but has a different Description' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'classification property exists and should but has a different Type' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.Type = 'YesNo'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different PossibleValue' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.PossibleValue = @( $script:MockClassificationPossibleValue1.Name, $script:MockClassificationPossibleValue2.Name )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'classification property exists and should but has a different Parameters' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.Parameters = @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'classification property exists and but should not' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }
                Mock New-FSRMClassificationPropertyDefinition
                Mock Set-FSRMClassificationPropertyDefinition
                Mock Remove-FSRMClassificationPropertyDefinition

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
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

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName New-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Set-FSRMClassificationPropertyDefinition -Exactly 0
                    Assert-MockCalled -commandName Remove-FSRMClassificationPropertyDefinition -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'classification property does not exist but should' {

                Mock Get-FSRMClassificationPropertyDefinition

                It 'Should return false' {
                    $Splat = $script:ClassificationProperty.Clone()
                    Test-TargetResource @Splat | Should Be $False

                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different DisplayName' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.DisplayName = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different Description' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different Type' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.Type = 'YesNo'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different PossibleValue' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.PossibleValue = @( $script:MockClassificationPossibleValue1.Name, $script:MockClassificationPossibleValue2.Name )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should but has a different Parameters' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.Parameters =  @( 'Parameter1=Value3', 'Parameter2=Value4')
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and should and all parameters match' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return true' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property exists and but should not' {

                Mock Get-FSRMClassificationPropertyDefinition -MockWith { $script:MockClassificationProperty }

                It 'Should return false' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'classification property does not exist and should not' {

                Mock Get-FSRMClassificationPropertyDefinition

                It 'Should return true' {
                    {
                        $Splat = $script:ClassificationProperty.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
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