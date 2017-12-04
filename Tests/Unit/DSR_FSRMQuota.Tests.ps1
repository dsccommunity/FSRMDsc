$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMQuota'

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
        $script:DSCResourceName = 'DSR_FSRMQuota'

        # Create the Mock -CommandName Objects that will be used for running tests
        $script:TestQuota = [PSObject]@{
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

        $script:Threshold1 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = $TestQuota.ThresholdPercentages[0]
            }
        $script:Threshold2 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = $TestQuota.ThresholdPercentages[1]
            }
        $script:MockQuota = [PSObject]@{
            Path = $script:TestQuota.Path
            Description = $script:TestQuota.Description
            Size = $script:TestQuota.Size
            SoftLimit = $script:TestQuota.SoftLimit
            Threshold = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                $script:Threshold1, $script:Threshold2
            )
            Disabled = $script:TestQuota.Disabled
            Template = $script:TestQuota.Template
            MatchesTemplate = $script:TestQuota.MatchesTemplate
        }
        $script:MockQuotaMatch= $script:MockQuota.Clone()
        $script:MockQuotaMatch.MatchesTemplate = $true

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'No quotas exist' {

                Mock -CommandName Get-FsrmQuota

                It 'Should return absent quota' {
                    $Result = Get-TargetResource `
                        -Path $script:TestQuota.Path
                    $Result.Ensure | Should -Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Requested quota does exist' {

                Mock -CommandName Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return correct quota' {
                    $Result = Get-TargetResource `
                        -Path $script:TestQuota.Path
                    $Result.Ensure | Should -Be 'Present'
                    $Result.Path | Should -Be $script:TestQuota.Path
                    $Result.Description | Should -Be $script:TestQuota.Description
                    $Result.ThresholdPercentages | Should -Be $script:TestQuota.ThresholdPercentages
                    $Result.Disabled | Should -Be $script:TestQuota.Disabled
                    $Result.Template | Should -Be $script:TestQuota.Template
                    $Result.MatchesTemplate | Should -Be $script:TestQuota.MatchesTemplate
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'quota does not exist but should' {

                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has a different Description' {

                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has a different Size' {

                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.Size = $Splat.Size + 1GB
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has a different SoftLimit' {

                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.SoftLimit = (-not $Splat.SoftLimit)
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has an additional threshold percentage' {

                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but is missing a threshold percentage' {

                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and but should not' {

                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 1
                }
            }

            Context 'quota does not exist and should not' {

                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuota -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {

            Context 'quota path does not exist' {
                Mock -CommandName Get-FsrmQuotaTemplate
                Mock -CommandName Test-Path -MockWith { $false }

                It 'Should throw an QuotaPathDoesNotExistError exception' {
                    $Splat = $script:TestQuota.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaPathDoesNotExistError) -f $Splat.Path) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
            }

            Context 'quota template does not exist' {
                Mock -CommandName Get-FSRMQuotaTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw an QuotaTemplateNotFoundError exception' {
                    $Splat = $script:TestQuota.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateNotFoundError) -f $Splat.Path,$Splat.Template) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
            }

            Context 'quota template not specified but MatchesTemplate is true' {
                It 'Should throw an QuotaTemplateEmptyError exception' {
                    $Splat = $script:TestQuota.Clone()
                    $Splat.MatchesTemplate = $True
                    $Splat.Template = ''

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateEmptyError) -f $Splat.Path) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
            }

            Context 'quota does not exist but should' {

                Mock -CommandName Get-FsrmQuota
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    $Splat = $script:TestQuota.Clone()
                    Test-TargetResource @Splat | Should -Be $False

                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Description' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Size' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.Size = $Splat.Size + 1GB
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different SoftLimit' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.SoftLimit = (-not $Splat.SoftLimit)
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has an additional threshold percentage' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but is missing a threshold percentage' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Disabled' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Template' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.Template = '100 MB Limit'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should and MatchesTemplate is set but does not match' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.MatchesTemplate = $true
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should and MatchesTemplate is set and does match' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuotaMatch }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.MatchesTemplate = $true
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should and all parameters match' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and but should not' {

                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota does not exist and should not' {

                Mock -CommandName Get-FsrmQuota
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
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
