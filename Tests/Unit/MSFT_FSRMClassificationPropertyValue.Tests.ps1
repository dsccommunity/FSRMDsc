$Global:DSCModuleName   = 'FSRMDsc'
$Global:DSCResourceName = 'MSFT_FSRMClassificationPropertyValue'

Import-Module -Name (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) `
                               -ChildPath 'TestHelpers\CommonTestHelper.psm1') `
              -Force

#region HEADER
# Unit Test Template Version: 1.1.0
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $Global:DSCResourceName {

        # Create the Mock Objects that will be used for running tests
        $Global:MockClassificationPossibleValue1 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Top Secret'
                DisplayName = 'Top Secret'
                Description = 'Top Secret Description'
            }
        $Global:MockClassificationPossibleValue2 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Secret'
                DisplayName = 'Secret'
                Description = 'Secret Description'
            }
        $Global:MockClassificationPossibleValue3 = New-CimInstance `
            -ClassName 'MSFT_FSRMClassificationPropertyDefinitionValue' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Confidential'
                DisplayName = 'Confidential'
                Description = 'Confidential Description'
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
        $Global:ClassificationPossibleValue1 = [PSObject]@{
            Name = $Global:MockClassificationPossibleValue1.Name
            PropertyName = $Global:ClassificationProperty.Name
            Description = $Global:MockClassificationPossibleValue1.Description
        }
        $Global:ClassificationPossibleValue2 = [PSObject]@{
            Name = $Global:MockClassificationPossibleValue2.Name
            PropertyName = $Global:ClassificationProperty.Name
            Description = $Global:MockClassificationPossibleValue2.Description
        }
        $Global:ClassificationPossibleValue3 = [PSObject]@{
            Name = $Global:MockClassificationPossibleValue3.Name
            PropertyName = $Global:ClassificationProperty.Name
            Description = $Global:MockClassificationPossibleValue3.Description
        }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'Classification Property does not exist' {

                Mock Get-FsrmClassificationPropertyDefinition { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'should throw ClassificationPropertyNotFoundError exception' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    $null = $Splat.Remove('Description')
                    $errorId = 'ClassificationPropertyNotFoundError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.ClassificationPropertyNotFoundError) `
                        -f $Splat.PropertyName
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { $Result = Get-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty exists but value does not' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($Global:MockClassificationProperty) }

                It 'should return absent Classification Property value' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    $null = $Splat.Remove('Description')
                    $Splat.Name = 'NotExist'
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty and value exists' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($Global:MockClassificationProperty) }

                It 'should return correct Classification Property value' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    $null = $Splat.Remove('Description')
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should Be 'Present'
                    $Result.Name = $Global:MockClassificationPossibleValue1.Name
                    $Result.DisplayName = $Global:MockClassificationPossibleValue1.DisplayName
                    $Result.Description = $Global:MockClassificationPossibleValue1.Description
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'Classification Property does not exist' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock Set-FsrmClassificationPropertyDefinition

                It 'should throw ClassificationPropertyNotFound exception' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    $errorId = 'ClassificationPropertyNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.ClassificationPropertyNotFoundError) `
                        -f $Splat.PropertyName
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Set-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmClassificationPropertyDefinition -Exactly 0
                }
            }

            Context 'Classification Property exists but value does not' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($Global:MockClassificationProperty) }
                Mock Set-FsrmClassificationPropertyDefinition

                It 'should not throw exception' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    $Splat.Name = 'NotExist'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty exists and value exists' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($Global:MockClassificationProperty) }
                Mock Set-FsrmClassificationPropertyDefinition

                It 'should not throw exception' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'ClassificationProperty exists and value exists but should not' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($Global:MockClassificationProperty) }
                Mock Set-FsrmClassificationPropertyDefinition

                It 'should not throw exception' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    $Splat.Ensure = 'Absent'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'Classification Property does not exist' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'should throw ClassificationPropertyNotFound exception' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    $errorId = 'ClassificationPropertyNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.ClassificationPropertyNotFoundError) `
                        -f $Splat.PropertyName
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists but value does not' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($Global:MockClassificationProperty) }

                It 'should return false' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    $Splat.Name = 'NotExist'
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists and matching value exists' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($Global:MockClassificationProperty) }

                It 'should return true' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    Test-TargetResource @Splat | Should Be $true
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists and value with different Description exists' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($Global:MockClassificationProperty) }

                It 'should return false' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    $Splat.Description = 'Different'
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmClassificationPropertyDefinition -Exactly 1
                }
            }

            Context 'Classification Property exists and value exists but should not' {

                Mock Get-FsrmClassificationPropertyDefinition -MockWith { return @($Global:MockClassificationProperty) }

                It 'should return false' {
                    $Splat = $Global:ClassificationPossibleValue1.Clone()
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
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
