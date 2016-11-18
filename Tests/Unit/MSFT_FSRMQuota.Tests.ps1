$Global:DSCModuleName   = 'FSRMDsc'
$Global:DSCResourceName = 'MSFT_FSRMQuota'

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
        $Global:TestQuota = [PSObject]@{
            Path = $ENV:Temp
            Description = '5 GB Hard Limit'
            Ensure = 'Present'
            Size = 5GB
            SoftLimit = $false
            ThresholdPercentages = [System.Collections.ArrayList]@( 85, 100 )
            Disabled = $false
            Template = '5 GB Limit'
            MatchesTemplate = $false
        }

        $Global:Threshold1 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = $TestQuota.ThresholdPercentages[0]
            }
        $Global:Threshold2 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = $TestQuota.ThresholdPercentages[1]
            }
        $Global:MockQuota = [PSObject]@{
            Path = $Global:TestQuota.Path
            Description = $Global:TestQuota.Description
            Size = $Global:TestQuota.Size
            SoftLimit = $Global:TestQuota.SoftLimit
            Threshold = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                $Global:Threshold1, $Global:Threshold2
            )
            Disabled = $Global:TestQuota.Disabled
            Template = $Global:TestQuota.Template
            MatchesTemplate = $Global:TestQuota.MatchesTemplate
        }
        $Global:MockQuotaMatch= $Global:MockQuota.Clone()
        $Global:MockQuotaMatch.MatchesTemplate = $true

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'No quotas exist' {

                Mock Get-FsrmQuota

                It 'should return absent quota' {
                    $Result = Get-TargetResource `
                        -Path $Global:TestQuota.Path
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Requested quota does exist' {

                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }

                It 'should return correct quota' {
                    $Result = Get-TargetResource `
                        -Path $Global:TestQuota.Path
                    $Result.Ensure | Should Be 'Present'
                    $Result.Path | Should Be $Global:TestQuota.Path
                    $Result.Description | Should Be $Global:TestQuota.Description
                    $Result.ThresholdPercentages | Should Be $Global:TestQuota.ThresholdPercentages
                    $Result.Disabled | Should Be $Global:TestQuota.Disabled
                    $Result.Template | Should Be $Global:TestQuota.Template
                    $Result.MatchesTemplate | Should Be $Global:TestQuota.MatchesTemplate
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'quota does not exist but should' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmQuota
                Mock New-FsrmQuota
                Mock Set-FsrmQuota
                Mock Remove-FsrmQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has a different Description' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock New-FsrmQuota
                Mock Set-FsrmQuota
                Mock Remove-FsrmQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has a different Size' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock New-FsrmQuota
                Mock Set-FsrmQuota
                Mock Remove-FsrmQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.Size = $Splat.Size + 1GB
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has a different SoftLimit' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock New-FsrmQuota
                Mock Set-FsrmQuota
                Mock Remove-FsrmQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.SoftLimit = (-not $Splat.SoftLimit)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has an additional threshold percentage' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock New-FsrmQuota
                Mock Set-FsrmQuota
                Mock Remove-FsrmQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but is missing a threshold percentage' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock New-FsrmQuota
                Mock Set-FsrmQuota
                Mock Remove-FsrmQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and but should not' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock New-FsrmQuota
                Mock Set-FsrmQuota
                Mock Remove-FsrmQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 1
                }
            }

            Context 'quota does not exist and should not' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmQuota
                Mock New-FsrmQuota
                Mock Set-FsrmQuota
                Mock Remove-FsrmQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            Context 'quota path does not exist' {
                Mock Get-FsrmQuotaTemplate
                Mock Test-Path -MockWith { $false }

                It 'should throw an QuotaPathDoesNotExistError exception' {
                    $Splat = $Global:TestQuota.Clone()

                    $errorId = 'QuotaPathDoesNotExistError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaPathDoesNotExistError) -f $Splat.Path
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'quota template does not exist' {
                Mock Get-FSRMQuotaTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'should throw an QuotaTemplateNotFoundError exception' {
                    $Splat = $Global:TestQuota.Clone()

                    $errorId = 'QuotaTemplateNotFoundError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaTemplateNotFoundError) -f $Splat.Path,$Splat.Template
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'quota template not specified but MatchesTemplate is true' {
                It 'should throw an QuotaTemplateEmptyError exception' {
                    $Splat = $Global:TestQuota.Clone()
                    $Splat.MatchesTemplate = $True
                    $Splat.Template = ''

                    $errorId = 'QuotaTemplateEmptyError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaTemplateEmptyError) -f $Splat.Path
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'quota does not exist but should' {

                Mock Get-FsrmQuota
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    $Splat = $Global:TestQuota.Clone()
                    Test-TargetResource @Splat | Should Be $False

                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Description' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Size' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.Size = $Splat.Size + 1GB
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different SoftLimit' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.SoftLimit = (-not $Splat.SoftLimit)
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has an additional threshold percentage' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but is missing a threshold percentage' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Disabled' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Template' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.Template = '100 MB Limit'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should and MatchesTemplate is set but does not match' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.MatchesTemplate = $true
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should and MatchesTemplate is set and does match' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuotaMatch }
                Mock Get-FsrmQuotaTemplate

                It 'should return true' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.MatchesTemplate = $true
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should and all parameters match' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return true' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and but should not' {

                Mock Get-FsrmQuota -MockWith { $Global:MockQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota does not exist and should not' {

                Mock Get-FsrmQuota
                Mock Get-FsrmQuotaTemplate

                It 'should return true' {
                    {
                        $Splat = $Global:TestQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
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
