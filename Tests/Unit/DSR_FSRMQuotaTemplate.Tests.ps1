$script:DSCModuleName = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMQuotaTemplate'

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
        $script:DSCResourceName = 'DSR_FSRMQuotaTemplate'

        # Create the Mock -CommandName Objects that will be used for running tests
        $script:TestQuotaTemplate = [PSObject]@{
            Name                 = '5 GB Limit'
            Description          = '5 GB Hard Limit'
            Ensure               = 'Present'
            Size                 = 5GB
            SoftLimit            = $False
            ThresholdPercentages = [System.Collections.ArrayList]@( 85, 100 )
            Verbose              = $true
        }

        $script:Threshold1 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Percentage = $TestQuotaTemplate.ThresholdPercentages[0]
        }

        $script:Threshold2 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Percentage = $TestQuotaTemplate.ThresholdPercentages[1]
        }

        $script:MockQuotaTemplate = [PSObject]@{
            Name        = $TestQuotaTemplate.Name
            Description = $TestQuotaTemplate.Description
            Size        = $TestQuotaTemplate.Size
            SoftLimit   = $TestQuotaTemplate.SoftLimit
            Threshold   = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                $script:Threshold1, $script:Threshold2
            )
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'No quota templates exist' {
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return absent quota template' {
                    $result = Get-TargetResource -Name $script:TestQuotaTemplate.Name -Verbose
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Requested quota template does exist' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return correct quota template' {
                    $result = Get-TargetResource -Name $script:TestQuotaTemplate.Name -Verbose
                    $result.Ensure | Should -Be 'Present'
                    $result.Name | Should -Be $script:TestQuotaTemplate.Name
                    $result.Description | Should -Be $script:TestQuotaTemplate.Description
                    $result.ThresholdPercentages | Should -Be $script:TestQuotaTemplate.ThresholdPercentages
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'Quota template does not exist but should' {
                Mock -CommandName Get-FsrmQuotaTemplate
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and should but has a different Description' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $setTargetResourceParameters.Description = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and should but has a different Size' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $setTargetResourceParameters.Size = $setTargetResourceParameters.Size + 1GB
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and should but has a different SoftLimit' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $setTargetResourceParameters.SoftLimit = (-not $setTargetResourceParameters.SoftLimit)
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and should but has an additional threshold percentage' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $setTargetResourceParameters.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and should but is missing a threshold percentage' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $setTargetResourceParameters.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and but should not' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template does not exist and should not' {
                Mock -CommandName Get-FsrmQuotaTemplate
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'Quota template does not exist but should' {
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $False

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should but has a different Description' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $testTargetResourceParameters.Description = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should but has a different Size' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $testTargetResourceParameters.Size = $Splat.Size + 1GB
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should but has a different SoftLimit' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $testTargetResourceParameters.SoftLimit = (-not $Splat.SoftLimit)
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should but has an additional threshold percentage' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $testTargetResourceParameters.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should but is missing a threshold percentage' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $testTargetResourceParameters.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should and all parameters match' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        Test-TargetResource @testTargetResourceParameters | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and but should not' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template does not exist and should not' {
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
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
