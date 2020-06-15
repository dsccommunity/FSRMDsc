$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMAutoQuota'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

# Begin Testing
try
{
    InModuleScope $script:dscResourceName {
        # Create the Mock -CommandName Objects that will be used for running tests
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

        Describe 'DSC_FSRMAutoQuota\Get-TargetResource' {
            Context 'No auto quotas exist' {
                Mock -CommandName Get-FsrmAutoQuota

                It 'Should return absent auto quota' {
                    $result = Get-TargetResource -Path $script:TestAutoQuota.Path -Verbose
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'Requested auto quota does exist' {
                Mock -CommandName Get-FsrmAutoQuota -MockWith { return @($script:MockAutoQuota) }

                It 'Should return correct auto quota' {
                    $result = Get-TargetResource -Path $script:TestAutoQuota.Path -Verbose
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $script:TestAutoQuota.Path
                    $result.Disabled | Should -Be $script:TestAutoQuota.Disabled
                    $result.Template | Should -Be $script:TestAutoQuota.Template
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                }
            }
        }

        Describe 'DSC_FSRMAutoQuota\Set-TargetResource' {
            Context 'auto quota does not exist but should' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmAutoQuota
                Mock -CommandName New-FsrmAutoQuota
                Mock -CommandName Set-FsrmAutoQuota
                Mock -CommandName Remove-FsrmAutoQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestAutoQuota.Clone()
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmAutoQuota -Exactly 0
                }
            }

            Context 'auto quota exists and should but has a different Disabled' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock -CommandName New-FsrmAutoQuota
                Mock -CommandName Set-FsrmAutoQuota
                Mock -CommandName Remove-FsrmAutoQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestAutoQuota.Clone()
                        $setTargetResourceParameters.Disabled = (-not $setTargetResourceParameters.Disabled)
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmAutoQuota -Exactly 0
                }
            }

            Context 'auto quota exists and should but has a different Template' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock -CommandName New-FsrmAutoQuota
                Mock -CommandName Set-FsrmAutoQuota
                Mock -CommandName Remove-FsrmAutoQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestAutoQuota.Clone()
                        $setTargetResourceParameters.Template = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmAutoQuota -Exactly 0
                }
            }

            Context 'auto quota exists but should not' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock -CommandName New-FsrmAutoQuota
                Mock -CommandName Set-FsrmAutoQuota
                Mock -CommandName Remove-FsrmAutoQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestAutoQuota.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota does not exist and should not' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmAutoQuota
                Mock -CommandName New-FsrmAutoQuota
                Mock -CommandName Set-FsrmAutoQuota
                Mock -CommandName Remove-FsrmAutoQuota

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestAutoQuota.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmAutoQuota -Exactly 0
                }
            }
        }

        Describe 'DSC_FSRMAutoQuota\Test-TargetResource' {
            Context 'auto quota path does not exist' {
                Mock -CommandName Get-FsrmQuotaTemplate
                Mock -CommandName Test-Path -MockWith { $false }

                It 'Should throw an AutoQuotaPathDoesNotExistError exception' {
                    $testTargetResourceParameters = $script:TestAutoQuota.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($script:localizedData.AutoQuotaPathDoesNotExistError) -f $testTargetResourceParameters.Path) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }
            }

            Context 'auto quota template does not exist' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw an AutoQuotaTemplateNotFoundError exception' {
                    $testTargetResourceParameters = $script:TestAutoQuota.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($script:localizedData.AutoQuotaTemplateNotFoundError) -f $testTargetResourceParameters.Path,$testTargetResourceParameters.Template) `
                        -ArgumentName 'Template'

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }
            }

            Context 'auto quota template not specified' {
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should throw an AutoQuotaTemplateEmptyError exception' {
                    $testTargetResourceParameters = $script:TestAutoQuota.Clone()
                    $testTargetResourceParameters.Template = ''

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($script:localizedData.AutoQuotaTemplateEmptyError) -f $testTargetResourceParameters.Path) `
                        -ArgumentName 'Template'

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }
            }

            Context 'auto quota does not exist but should' {
                Mock -CommandName Get-FsrmAutoQuota
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestAutoQuota.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Disabled' {
                Mock -CommandName Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestAutoQuota.Clone()
                        $testTargetResourceParameters.Disabled = (-not $testTargetResourceParameters.Disabled)
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Template' {
                Mock -CommandName Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestAutoQuota.Clone()
                        $testTargetResourceParameters.Template = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota exists and should and all parameters match' {
                Mock -CommandName Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestAutoQuota.Clone()
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota exists and but should not' {
                Mock -CommandName Get-FsrmAutoQuota -MockWith { $script:MockAutoQuota }
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestAutoQuota.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota does not exist and should not' {
                Mock -CommandName Get-FsrmAutoQuota
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestAutoQuota.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmAutoQuota -Exactly 1
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
