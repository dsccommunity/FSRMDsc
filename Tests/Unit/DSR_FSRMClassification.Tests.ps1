$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMClassification'

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
        $script:DSCResourceName = 'DSR_FSRMClassification'

        # Create the Mock Objects that will be used for running tests
        $script:ClassificationMonthly = [PSObject] @{
            Id = 'Default'
            Continuous = $False
            ContinuousLog = $False
            ContinuousLogSize = 2048
            ExcludeNamespace = @('[AllVolumes]\$Extend /','[AllVolumes]\System Volume Information /s')
            ScheduleMonthly = @( 12,13 )
            ScheduleRunDuration = 10
            ScheduleTime = '13:00'
        }

        $script:MockScheduledTaskMonthly = New-CimInstance `
            -ClassName 'DSR_FSRMScheduledTask' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Time = $script:ClassificationMonthly.ScheduleTime
                RunDuration = $script:ClassificationMonthly.ScheduleRunDuration
                Monthly = $script:ClassificationMonthly.ScheduleMonthly
            }

        $script:MockClassificationMonthly = New-CimInstance `
            -ClassName 'DSR_FSRMClassification' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Continuous = $script:ClassificationMonthly.Continuous
                ContinuousLog = $script:ClassificationMonthly.ContinuousLog
                ContinuousLogSize = $script:ClassificationMonthly.ContinuousLogSize
                ExcludeNamespace = $script:ClassificationMonthly.ExcludeNamespace
                Schedule = $script:MockScheduledTaskMonthly
            }

        $script:ClassificationWeekly = [PSObject] @{
            Id = 'Default'
            Continuous = $False
            ContinuousLog = $False
            ContinuousLogSize = 2048
            ExcludeNamespace = @('[AllVolumes]\$Extend /','[AllVolumes]\System Volume Information /s')
            ScheduleWeekly = @( 'Monday','Tuesday' )
            ScheduleRunDuration = 10
            ScheduleTime = '13:00'
        }

        $script:MockScheduledTaskWeekly = New-CimInstance `
            -ClassName 'DSR_FSRMScheduledTask' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Time = $script:ClassificationWeekly.ScheduleTime
                RunDuration = $script:ClassificationWeekly.ScheduleRunDuration
                Weekly = $script:ClassificationWeekly.ScheduleWeekly
            }

        $script:MockClassificationWeekly = New-CimInstance `
            -ClassName 'DSR_FSRMClassification' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Continuous = $script:ClassificationWeekly.Continuous
                ContinuousLog = $script:ClassificationWeekly.ContinuousLog
                ContinuousLogSize = $script:ClassificationWeekly.ContinuousLogSize
                ExcludeNamespace = $script:ClassificationWeekly.ExcludeNamespace
                Schedule = $script:MockScheduledTaskWeekly
            }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'Monthly schedule configuration' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return correct classification properties' {
                    $Result = Get-TargetResource -Id $script:ClassificationMonthly.Id
                    $Result.Continuous | Should Be $script:ClassificationMonthly.Continuous
                    $Result.ContinuousLog | Should Be $script:ClassificationMonthly.ContinuousLog
                    $Result.ContinuousLogSize | Should Be $script:ClassificationMonthly.ContinuousLogSize
                    $Result.ExcludeNamespace | Should Be $script:ClassificationMonthly.ExcludeNamespace
                    $Result.ScheduleMonthly | Should Be $script:ClassificationMonthly.ScheduleMonthly
                    $Result.ScheduleRunDuration | Should Be $script:ClassificationMonthly.ScheduleRunDuration
                    $Result.ScheduleTime | Should Be $script:ClassificationMonthly.ScheduleTime
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'Weekly schedule configuration' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationWeekly }

                It 'Should return correct classification properties' {
                    $Result = Get-TargetResource -Id $script:ClassificationWeekly.Id
                    $Result.Continuous | Should Be $script:ClassificationWeekly.Continuous
                    $Result.ContinuousLog | Should Be $script:ClassificationWeekly.ContinuousLog
                    $Result.ContinuousLogSize | Should Be $script:ClassificationWeekly.ContinuousLogSize
                    $Result.ExcludeNamespace | Should Be $script:ClassificationWeekly.ExcludeNamespace
                    $Result.ScheduleWeekly | Should Be $script:ClassificationWeekly.ScheduleWeekly
                    $Result.ScheduleRunDuration | Should Be $script:ClassificationWeekly.ScheduleRunDuration
                    $Result.ScheduleTime | Should Be $script:ClassificationWeekly.ScheduleTime
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'classification has a different Continuous property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationMonthly.Clone()
                        $Splat.Continuous = (-not $Splat.Continuous)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLog property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationMonthly.Clone()
                        $Splat.ContinuousLog = (-not $Splat.ContinuousLog)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLogSize property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationMonthly.Clone()
                        $Splat.ContinuousLogSize = $Splat.ContinuousLogSize * 2
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ExcludeNamespace property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationMonthly.Clone()
                        $Splat.ExcludeNamespace = @('[AllVolumes]\$Extend /')
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleWeekly property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationWeekly }
                Mock Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationWeekly.Clone()
                        $Splat.ScheduleWeekly = @( 'Monday','Tuesday','Wednesday' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleMonthly property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationMonthly.Clone()
                        $Splat.ScheduleMonthly = @( 13,14,15 )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleRunDuration property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationMonthly.Clone()
                        $Splat.ScheduleRunDuration = $Splat.ScheduleRunDuration + 1
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleTime property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'Should not throw error' {
                    {
                        $Splat = $script:ClassificationMonthly.Clone()
                        $Splat.ScheduleTime = '01:00'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'classification has no property differences' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return true' {
                    $Splat = $script:ClassificationMonthly.Clone()
                    Test-TargetResource @Splat | Should Be $True
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different Continuous property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $Splat = $script:ClassificationMonthly.Clone()
                    $Splat.Continuous = (-not $Splat.Continuous)
                    Test-TargetResource @Splat | Should Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLog property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $Splat = $script:ClassificationMonthly.Clone()
                    $Splat.ContinuousLog = (-not $Splat.ContinuousLog)
                    Test-TargetResource @Splat | Should Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLogSize property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $Splat = $script:ClassificationMonthly.Clone()
                    $Splat.ContinuousLogSize = $Splat.ContinuousLogSize * 2
                    Test-TargetResource @Splat | Should Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ExcludeNamespace property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $Splat = $script:ClassificationMonthly.Clone()
                    $Splat.ExcludeNamespace = @('[AllVolumes]\$Extend /')
                    Test-TargetResource @Splat | Should Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleWeekly property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationWeekly }

                It 'Should return false' {
                    $Splat = $script:ClassificationWeekly.Clone()
                    $Splat.ScheduleWeekly = @( 'Monday','Tuesday','Wednesday' )
                    Test-TargetResource @Splat | Should Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleMonthly property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $Splat = $script:ClassificationMonthly.Clone()
                    $Splat.ScheduleMonthly = @( 13,14,15 )
                    Test-TargetResource @Splat | Should Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleRunDuration property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $Splat = $script:ClassificationMonthly.Clone()
                    $Splat.ScheduleRunDuration = $Splat.ScheduleRunDuration + 1
                    Test-TargetResource @Splat | Should Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleTime property' {
                Mock Get-FSRMClassification -MockWith { $script:MockClassificationMonthly }

                It 'Should return false' {
                    $Splat = $script:ClassificationMonthly.Clone()
                    $Splat.ScheduleTime = '01:00'
                    Test-TargetResource @Splat | Should Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
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
