$script:DSCModuleName = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMQuota'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Unit Test Template Version: 1.1.0
[System.String] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\FSRMDsc'
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
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
            Path                 = $ENV:Temp
            Description          = '5 GB Hard Limit'
            Ensure               = 'Present'
            Size                 = 5GB
            SoftLimit            = $false
            ThresholdPercentages = [System.Collections.ArrayList]@( 85, 100 )
            Disabled             = $false
            Template             = '5 GB Limit'
            MatchesTemplate      = $false
            Verbose              = $true
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
            Path            = $script:TestQuota.Path
            Description     = $script:TestQuota.Description
            Size            = $script:TestQuota.Size
            SoftLimit       = $script:TestQuota.SoftLimit
            Threshold       = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                $script:Threshold1, $script:Threshold2
            )
            Disabled        = $script:TestQuota.Disabled
            Template        = $script:TestQuota.Template
            MatchesTemplate = $script:TestQuota.MatchesTemplate
        }

        $script:MockQuotaMatch = $script:MockQuota.Clone()
        $script:MockQuotaMatch.MatchesTemplate = $true

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'No quotas exist' {
                Mock -CommandName Get-FsrmQuota

                It 'Should return absent quota' {
                    $result = Get-TargetResource -Path $script:TestQuota.Path -Verbose
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Requested quota does exist' {
                Mock -CommandName Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return correct quota' {
                    $result = Get-TargetResource -Path $script:TestQuota.Path -Verbose
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $script:TestQuota.Path
                    $result.Description | Should -Be $script:TestQuota.Description
                    $result.ThresholdPercentages | Should -Be $script:TestQuota.ThresholdPercentages
                    $result.Disabled | Should -Be $script:TestQuota.Disabled
                    $result.Template | Should -Be $script:TestQuota.Template
                    $result.MatchesTemplate | Should -Be $script:TestQuota.MatchesTemplate
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
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

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuota.Clone()
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmQuota -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has a different Description' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuota.Clone()
                        $setTargetResourceParameters.Description = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has a different Size' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuota.Clone()
                        $setTargetResourceParameters.Size = $setTargetResourceParameters.Size + 1GB
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has a different SoftLimit' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuota.Clone()
                        $setTargetResourceParameters.SoftLimit = (-not $setTargetResourceParameters.SoftLimit)
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but has an additional threshold percentage' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuota.Clone()
                        $setTargetResourceParameters.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and should but is missing a threshold percentage' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuota.Clone()
                        $setTargetResourceParameters.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmQuota -Exactly 0
                }
            }

            Context 'quota exists and but should not' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuota.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuota -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmQuota -Exactly 1
                }
            }

            Context 'quota does not exist and should not' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmQuota
                Mock -CommandName New-FsrmQuota
                Mock -CommandName Set-FsrmQuota
                Mock -CommandName Remove-FsrmQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuota.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuota -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmQuota -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'quota path does not exist' {
                Mock -CommandName Get-FsrmQuotaTemplate
                Mock -CommandName Test-Path -MockWith { $false }

                It 'Should throw an QuotaPathDoesNotExistError exception' {
                    $testTargetResourceParameters = $script:TestQuota.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaPathDoesNotExistError) -f $testTargetResourceParameters.Path) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }
            }

            Context 'quota template does not exist' {
                Mock -CommandName Get-FSRMQuotaTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw an QuotaTemplateNotFoundError exception' {
                    $testTargetResourceParameters = $script:TestQuota.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateNotFoundError) -f $testTargetResourceParameters.Path, $testTargetResourceParameters.Template) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }
            }

            Context 'quota template not specified but MatchesTemplate is true' {
                It 'Should throw an QuotaTemplateEmptyError exception' {
                    $testTargetResourceParameters = $script:TestQuota.Clone()
                    $testTargetResourceParameters.MatchesTemplate = $True
                    $testTargetResourceParameters.Template = ''

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateEmptyError) -f $testTargetResourceParameters.Path) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }
            }

            Context 'quota does not exist but should' {
                Mock -CommandName Get-FsrmQuota
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuota.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $False

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Description' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.Description = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Size' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.Size = $testTargetResourceParameters.Size + 1GB
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different SoftLimit' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.SoftLimit = (-not $testTargetResourceParameters.SoftLimit)
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has an additional threshold percentage' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but is missing a threshold percentage' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Disabled' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.Disabled = (-not $testTargetResourceParameters.Disabled)
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Template' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.Template = '100 MB Limit'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should and MatchesTemplate is set but does not match' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.MatchesTemplate = $true
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should and MatchesTemplate is set and does match' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuotaMatch }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.MatchesTemplate = $true
                        Test-TargetResource @testTargetResourceParameters | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and should and all parameters match' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        Test-TargetResource @testTargetResourceParameters | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota exists and but should not' {
                Mock -CommandName Get-FsrmQuota -MockWith { $script:MockQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'quota does not exist and should not' {
                Mock -CommandName Get-FsrmQuota
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestQuota.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuota -Exactly 1
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
