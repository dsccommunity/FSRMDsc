$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMQuotaTemplate'

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
        $script:TestQuotaTemplate = [PSObject]@{
            Name                 = '5 GB Limit'
            Description          = '5 GB Hard Limit'
            Ensure               = 'Present'
            Size                 = 5GB
            SoftLimit            = $false
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

        Describe 'DSC_FSRMQuotaTemplate\Get-TargetResource' {
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

        Describe 'DSC_FSRMQuotaTemplate\Set-TargetResource' {
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

        Describe 'DSC_FSRMQuotaTemplate\Test-TargetResource' {
            Context 'Quota template does not exist but should' {
                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplate.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false

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
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                        $testTargetResourceParameters.Size = $testTargetResourceParameters.Size + 1GB
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                        $testTargetResourceParameters.SoftLimit = (-not $testTargetResourceParameters.SoftLimit)
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
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
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
