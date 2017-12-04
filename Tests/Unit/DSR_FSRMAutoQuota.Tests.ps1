$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMAutoQuota'

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
        $script:DSCResourceName = 'DSR_FSRMAutoQuota'

        # Create the Mock Objects that will be used for running tests
        $script:TestAutoQuota = [PSObject]@{
            Path = $ENV:Temp
            Ensure = 'Present'
            Disabled = $false
            Template = '5 GB Limit'
            Verbose = $true
        }

        $script:MockAutoQuota = [PSObject]@{
            Path = $script:TestAutoQuota.Path
            Disabled = $script:TestAutoQuota.Disabled
            Template = $script:TestAutoQuota.Template
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'No auto quotas exist' {
                Mock Get-FsrmAutoQuota

                It 'Should return absent auto quota' {
                    $Result = Get-TargetResource `
                        -Path $script:TestAutoQuota.Path
                    $Result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'Requested auto quota does exist' {
                Mock Get-FsrmAutoQuota -MockWith { return @($script:MockAutoQuota) }

                It 'Should return correct auto quota' {
                    $Result = Get-TargetResource `
                        -Path $script:TestAutoQuota.Path
                    $Result.Ensure | Should -Be 'Present'
                    $Result.Path | Should -Be $script:TestAutoQuota.Path
                    $Result.Disabled | Should -Be $script:TestAutoQuota.Disabled
                    $Result.Template | Should -Be $script:TestAutoQuota.Template
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'auto quota does not exist but should' {
                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmAutoQuota
                Mock New-FsrmAutoQuota
                Mock Set-FsrmAutoQuota
                Mock Remove-FsrmAutoQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestAutoQuota.Clone()
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmAutoQuota -Exactly 0
                }
            }

            Context 'auto quota exists and should but has a different Disabled' {
                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock New-FsrmAutoQuota
                Mock Set-FsrmAutoQuota
                Mock Remove-FsrmAutoQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestAutoQuota.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmAutoQuota -Exactly 0
                }
            }

            Context 'auto quota exists and should but has a different Template' {
                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock New-FsrmAutoQuota
                Mock Set-FsrmAutoQuota
                Mock Remove-FsrmAutoQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestAutoQuota.Clone()
                        $Splat.Template = 'Different'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmAutoQuota -Exactly 0
                }
            }

            Context 'auto quota exists but should not' {
                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock New-FsrmAutoQuota
                Mock Set-FsrmAutoQuota
                Mock Remove-FsrmAutoQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestAutoQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota does not exist and should not' {
                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmAutoQuota
                Mock New-FsrmAutoQuota
                Mock Set-FsrmAutoQuota
                Mock Remove-FsrmAutoQuota

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestAutoQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmAutoQuota -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'auto quota path does not exist' {
                Mock Get-FsrmQuotaTemplate
                Mock Test-Path -MockWith { $false }

                It 'Should throw an AutoQuotaPathDoesNotExistError exception' {
                    $Splat = $script:TestAutoQuota.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.AutoQuotaPathDoesNotExistError) -f $Splat.Path) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
            }

            Context 'auto quota template does not exist' {
                Mock Get-FsrmQuotaTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw an AutoQuotaTemplateNotFoundError exception' {
                    $Splat = $script:TestAutoQuota.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.AutoQuotaTemplateNotFoundError) -f $Splat.Path,$Splat.Template) `
                        -ArgumentName 'Template'

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
            }

            Context 'auto quota template not specified' {
                Mock Get-FsrmQuotaTemplate

                It 'Should throw an AutoQuotaTemplateEmptyError exception' {
                    $Splat = $script:TestAutoQuota.Clone()
                    $Splat.Template = ''

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.AutoQuotaTemplateEmptyError) -f $Splat.Path) `
                        -ArgumentName 'Template'

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
            }

            Context 'auto quota does not exist but should' {
                Mock Get-FsrmAutoQuota
                Mock Get-FsrmQuotaTemplate

                It 'Should return false' {
                    $Splat = $script:TestAutoQuota.Clone()
                    Test-TargetResource @Splat | Should -Be $False

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Disabled' {
                Mock Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestAutoQuota.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Template' {
                Mock Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestAutoQuota.Clone()
                        $Splat.Template = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota exists and should and all parameters match' {
                Mock Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestAutoQuota.Clone()
                        Test-TargetResource @Splat | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota exists and but should not' {
                Mock Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestAutoQuota.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota does not exist and should not' {
                Mock Get-FsrmAutoQuota
                Mock Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestAutoQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
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
