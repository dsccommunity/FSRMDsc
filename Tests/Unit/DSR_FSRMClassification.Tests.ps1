$script:DSCModuleName = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMClassification'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Unit Test Template Version: 1.1.0
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
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
        $script:DSCResourceName = 'DSR_FSRMClassification'

        # Create the Mock -CommandName Objects that will be used for running tests
        $script:ClassificationMonthly = [PSObject] @{
            Id                  = 'Default'
            Continuous          = $false
            ContinuousLog       = $false
            ContinuousLogSize   = 2048
            ExcludeNamespace    = @('[AllVolumes]\$Extend /', '[AllVolumes]\System Volume Information /s')
            ScheduleMonthly     = @( 12, 13 )
            ScheduleRunDuration = 10
            ScheduleTime        = '13:00'
            Verbose             = $true
        }

        $script:MockScheduledTaskMonthly = New-CimInstance `
            -ClassName 'MSFT_FSRMScheduledTask' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Time        = $script:ClassificationMonthly.ScheduleTime
            RunDuration = $script:ClassificationMonthly.ScheduleRunDuration
            Monthly     = $script:ClassificationMonthly.ScheduleMonthly
        }

        $script:MockClassificationMonthly = New-CimInstance `
            -ClassName 'MSFT_FSRMClassification' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Continuous        = $script:ClassificationMonthly.Continuous
            ContinuousLog     = $script:ClassificationMonthly.ContinuousLog
            ContinuousLogSize = $script:ClassificationMonthly.ContinuousLogSize
            ExcludeNamespace  = $script:ClassificationMonthly.ExcludeNamespace
            Schedule          = $script:MockScheduledTaskMonthly
        }

        $script:ClassificationWeekly = [PSObject] @{
            Id                  = 'Default'
            Continuous          = $false
            ContinuousLog       = $false
            ContinuousLogSize   = 2048
            ExcludeNamespace    = @('[AllVolumes]\$Extend /', '[AllVolumes]\System Volume Information /s')
            ScheduleWeekly      = @( 'Monday', 'Tuesday' )
            ScheduleRunDuration = 10
            ScheduleTime        = '13:00'
            Verbose             = $true
        }

        $script:MockScheduledTaskWeekly = New-CimInstance `
            -ClassName 'MSFT_FSRMScheduledTask' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Time        = $script:ClassificationWeekly.ScheduleTime
            RunDuration = $script:ClassificationWeekly.ScheduleRunDuration
            Weekly      = $script:ClassificationWeekly.ScheduleWeekly
        }

        $script:MockClassificationWeekly = New-CimInstance `
            -ClassName 'MSFT_FSRMClassification' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Continuous        = $script:ClassificationWeekly.Continuous
            ContinuousLog     = $script:ClassificationWeekly.ContinuousLog
            ContinuousLogSize = $script:ClassificationWeekly.ContinuousLogSize
            ExcludeNamespace  = $script:ClassificationWeekly.ExcludeNamespace
            Schedule          = $script:MockScheduledTaskWeekly
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'Monthly schedule configuration' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return correct classification properties' {
                    $Result = Get-TargetResource -Id $script:ClassificationMonthly.Id -Verbose
                    $Result.Continuous | Should -Be $script:ClassificationMonthly.Continuous
                    $Result.ContinuousLog | Should -Be $script:ClassificationMonthly.ContinuousLog
                    $Result.ContinuousLogSize | Should -Be $script:ClassificationMonthly.ContinuousLogSize
                    $Result.ExcludeNamespace | Should -Be $script:ClassificationMonthly.ExcludeNamespace
                    $Result.ScheduleMonthly | Should -Be $script:ClassificationMonthly.ScheduleMonthly
                    $Result.ScheduleRunDuration | Should -Be $script:ClassificationMonthly.ScheduleRunDuration
                    $Result.ScheduleTime | Should -Be $script:ClassificationMonthly.ScheduleTime
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'Weekly schedule configuration' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationWeekly }

                It 'Should return correct classification properties' {
                    $Result = Get-TargetResource -Id $script:ClassificationWeekly.Id -Verbose
                    $Result.Continuous | Should -Be $script:ClassificationWeekly.Continuous
                    $Result.ContinuousLog | Should -Be $script:ClassificationWeekly.ContinuousLog
                    $Result.ContinuousLogSize | Should -Be $script:ClassificationWeekly.ContinuousLogSize
                    $Result.ExcludeNamespace | Should -Be $script:ClassificationWeekly.ExcludeNamespace
                    $Result.ScheduleWeekly | Should -Be $script:ClassificationWeekly.ScheduleWeekly
                    $Result.ScheduleRunDuration | Should -Be $script:ClassificationWeekly.ScheduleRunDuration
                    $Result.ScheduleTime | Should -Be $script:ClassificationWeekly.ScheduleTime
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'classification has a different Continuous property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock -CommandName Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationMonthly.Clone()
                        $setTargetResourceParameters.Continuous = (-not $setTargetResourceParameters.Continuous)
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLog property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock -CommandName Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationMonthly.Clone()
                        $setTargetResourceParameters.ContinuousLog = (-not $setTargetResourceParameters.ContinuousLog)
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLogSize property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock -CommandName Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationMonthly.Clone()
                        $setTargetResourceParameters.ContinuousLogSize = $setTargetResourceParameters.ContinuousLogSize * 2
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ExcludeNamespace property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock -CommandName Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationMonthly.Clone()
                        $setTargetResourceParameters.ExcludeNamespace = @('[AllVolumes]\$Extend /')
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleWeekly property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationWeekly }
                Mock -CommandName Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationWeekly.Clone()
                        $setTargetResourceParameters.ScheduleWeekly = @( 'Monday', 'Tuesday', 'Wednesday' )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleMonthly property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock -CommandName Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationMonthly.Clone()
                        $setTargetResourceParameters.ScheduleMonthly = @( 13, 14, 15 )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleRunDuration property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock -CommandName Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationMonthly.Clone()
                        $setTargetResourceParameters.ScheduleRunDuration = $setTargetResourceParameters.ScheduleRunDuration + 1
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleTime property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock -CommandName Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:ClassificationMonthly.Clone()
                        $setTargetResourceParameters.ScheduleTime = '01:00'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -CommandName Set-FSRMClassification -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'classification has no property differences' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return true' {
                    $testTargetResourceParameters = $script:ClassificationMonthly.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $true
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different Continuous property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationMonthly.Clone()
                    $testTargetResourceParameters.Continuous = (-not $testTargetResourceParameters.Continuous)
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLog property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationMonthly.Clone()
                    $testTargetResourceParameters.ContinuousLog = (-not $testTargetResourceParameters.ContinuousLog)
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLogSize property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationMonthly.Clone()
                    $testTargetResourceParameters.ContinuousLogSize = $testTargetResourceParameters.ContinuousLogSize * 2
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ExcludeNamespace property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationMonthly.Clone()
                    $testTargetResourceParameters.ExcludeNamespace = @('[AllVolumes]\$Extend /')
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleWeekly property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationWeekly }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationWeekly.Clone()
                    $testTargetResourceParameters.ScheduleWeekly = @( 'Monday', 'Tuesday', 'Wednesday' )
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleMonthly property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationMonthly.Clone()
                    $testTargetResourceParameters.ScheduleMonthly = @( 13, 14, 15 )
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleRunDuration property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationMonthly.Clone()
                    $testTargetResourceParameters.ScheduleRunDuration = $testTargetResourceParameters.ScheduleRunDuration + 1
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleTime property' {
                Mock -CommandName Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:ClassificationMonthly.Clone()
                    $testTargetResourceParameters.ScheduleTime = '01:00'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMClassification -Exactly 1
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
