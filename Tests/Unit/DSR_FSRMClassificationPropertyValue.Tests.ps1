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

        # Create the Mock Objects that will be used for running tests
        $script:MockClassificationPossibleValue1 = New-CimInstance `
            -ClassName 'DSR_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Top Secret'
                DisplayName = 'Top Secret'
                Description = 'Top Secret Description'
            }
        $script:MockClassificationPossibleValue2 = New-CimInstance `
            -ClassName 'DSR_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Secret'
                DisplayName = 'Secret'
                Description = 'Secret Description'
            }
        $script:MockClassificationPossibleValue3 = New-CimInstance `
            -ClassName 'DSR_FSRMClassificationPropertyDefinitionValue' `
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
        $script:ClassificationPossibleValue1 = [PSObject]@{
            Name = $script:MockClassificationPossibleValue1.Name
            PropertyName = $script:ClassificationProperty.Name
            Description = $script:MockClassificationPossibleValue1.Description
        }
        $script:ClassificationPossibleValue2 = [PSObject]@{
            Name = $script:MockClassificationPossibleValue2.Name
            PropertyName = $script:ClassificationProperty.Name
            Description = $script:MockClassificationPossibleValue2.Description
        }
        $script:ClassificationPossibleValue3 = [PSObject]@{
            Name = $script:MockClassificationPossibleValue3.Name
            PropertyName = $script:ClassificationProperty.Name
            Description = $script:MockClassificationPossibleValue3.Description
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'Classification Property does not exist' {

                Mock Get-FsrmClassificationPropertyDefinition { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw ClassificationPropertyNotFoundError exception' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()
                    $null = $Splat.Remove('Description')

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.ClassificationPropertyNotFoundError) -f $Splat.PropertyName) `
                        -ArgumentName $Splat.PropertyName

                    { $Result = Get-TargetResource @Splat } | Should -Throw $errorRecord
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty exists but value does not' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return absent Classification Property value' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()
                    $null = $Splat.Remove('Description')
                    $Splat.Name = 'NotExist'
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should -Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty and value exists' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return correct Classification Property value' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()
                    $null = $Splat.Remove('Description')
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should -Be 'Present'
                    $Result.Name = $script:MockClassificationPossibleValue1.Name
                    $Result.DisplayName = $script:MockClassificationPossibleValue1.DisplayName
                    $Result.Description = $script:MockClassificationPossibleValue1.Description
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'Classification Property does not exist' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock Set-FsrmClassificationPropertyDefinition

                It 'Should throw ClassificationPropertyNotFound exception' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.ClassificationPropertyNotFoundError) -f $Splat.PropertyName) `
                        -ArgumentName $Splat.PropertyName

                    { Set-TargetResource @Splat } | Should -Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'Classification Property exists but value does not' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }
                Mock Set-FsrmClassificationPropertyDefinition

                It 'Should Not Throw exception' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()
                    $Splat.Name = 'NotExist'
                    { Set-TargetResource @Splat } | Should -Not -Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty exists and value exists' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }
                Mock Set-FsrmClassificationPropertyDefinition

                It 'Should Not Throw exception' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()
                    { Set-TargetResource @Splat } | Should -Not -Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty exists and value exists but should not' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }
                Mock Set-FsrmClassificationPropertyDefinition

                It 'Should Not Throw exception' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()
                    $Splat.Ensure = 'Absent'
                    { Set-TargetResource @Splat } | Should -Not -Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'Classification Property does not exist' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw ClassificationPropertyNotFound exception' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.ClassificationPropertyNotFoundError) -f $Splat.PropertyName) `
                        -ArgumentName $Splat.PropertyName

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists but value does not' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return false' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()
                    $Splat.Name = 'NotExist'
                    Test-TargetResource @Splat | Should -Be $False
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists and matching value exists' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return true' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()
                    Test-TargetResource @Splat | Should -Be $true
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists and value with different Description exists' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return false' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()
                    $Splat.Description = 'Different'
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists and value exists but should not' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($script:MockClassificationProperty) }

                It 'Should return false' {
                    $Splat = $script:ClassificationPossibleValue1.Clone()
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
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
