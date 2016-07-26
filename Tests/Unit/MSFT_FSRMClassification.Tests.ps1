$Global:DSCModuleName   = 'FSRMDsc'
$Global:DSCResourceName = 'MSFT_FSRMClassification'

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
        $Global:ClassificationMonthly = [PSObject] @{
            Id = 'Default'
            Continuous = $False
            ContinuousLog = $False
            ContinuousLogSize = 2048
            ExcludeNamespace = @('[AllVolumes]\$Extend /','[AllVolumes]\System Volume Information /s')
            ScheduleMonthly = @( 12,13 )
            ScheduleRunDuration = 10
            ScheduleTime = '13:00'
        }

        $Global:MockScheduledTaskMonthly = New-CimInstance `
            -ClassName 'MSFT_FSRMScheduledTask' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Time = $Global:ClassificationMonthly.ScheduleTime
                RunDuration = $Global:ClassificationMonthly.ScheduleRunDuration
                Monthly = $Global:ClassificationMonthly.ScheduleMonthly
            }

        $Global:MockClassificationMonthly = New-CimInstance `
            -ClassName 'MSFT_FSRMClassification' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Continuous = $Global:ClassificationMonthly.Continuous
                ContinuousLog = $Global:ClassificationMonthly.ContinuousLog
                ContinuousLogSize = $Global:ClassificationMonthly.ContinuousLogSize
                ExcludeNamespace = $Global:ClassificationMonthly.ExcludeNamespace
                Schedule = $Global:MockScheduledTaskMonthly
            }

        $Global:ClassificationWeekly = [PSObject] @{
            Id = 'Default'
            Continuous = $False
            ContinuousLog = $False
            ContinuousLogSize = 2048
            ExcludeNamespace = @('[AllVolumes]\$Extend /','[AllVolumes]\System Volume Information /s')
            ScheduleWeekly = @( 'Monday','Tuesday' )
            ScheduleRunDuration = 10
            ScheduleTime = '13:00'
        }

        $Global:MockScheduledTaskWeekly = New-CimInstance `
            -ClassName 'MSFT_FSRMScheduledTask' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Time = $Global:ClassificationWeekly.ScheduleTime
                RunDuration = $Global:ClassificationWeekly.ScheduleRunDuration
                Weekly = $Global:ClassificationWeekly.ScheduleWeekly
            }

        $Global:MockClassificationWeekly = New-CimInstance `
            -ClassName 'MSFT_FSRMClassification' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Continuous = $Global:ClassificationWeekly.Continuous
                ContinuousLog = $Global:ClassificationWeekly.ContinuousLog
                ContinuousLogSize = $Global:ClassificationWeekly.ContinuousLogSize
                ExcludeNamespace = $Global:ClassificationWeekly.ExcludeNamespace
                Schedule = $Global:MockScheduledTaskWeekly
            }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'Monthly schedule configuration' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }

                It 'should return correct classification properties' {
                    $Result = Get-TargetResource -Id $Global:ClassificationMonthly.Id
                    $Result.Continuous | Should Be $Global:ClassificationMonthly.Continuous
                    $Result.ContinuousLog | Should Be $Global:ClassificationMonthly.ContinuousLog
                    $Result.ContinuousLogSize | Should Be $Global:ClassificationMonthly.ContinuousLogSize
                    $Result.ExcludeNamespace | Should Be $Global:ClassificationMonthly.ExcludeNamespace
                    $Result.ScheduleMonthly | Should Be $Global:ClassificationMonthly.ScheduleMonthly
                    $Result.ScheduleRunDuration | Should Be $Global:ClassificationMonthly.ScheduleRunDuration
                    $Result.ScheduleTime | Should Be $Global:ClassificationMonthly.ScheduleTime
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'Weekly schedule configuration' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationWeekly }

                It 'should return correct classification properties' {
                    $Result = Get-TargetResource -Id $Global:ClassificationWeekly.Id
                    $Result.Continuous | Should Be $Global:ClassificationWeekly.Continuous
                    $Result.ContinuousLog | Should Be $Global:ClassificationWeekly.ContinuousLog
                    $Result.ContinuousLogSize | Should Be $Global:ClassificationWeekly.ContinuousLogSize
                    $Result.ExcludeNamespace | Should Be $Global:ClassificationWeekly.ExcludeNamespace
                    $Result.ScheduleWeekly | Should Be $Global:ClassificationWeekly.ScheduleWeekly
                    $Result.ScheduleRunDuration | Should Be $Global:ClassificationWeekly.ScheduleRunDuration
                    $Result.ScheduleTime | Should Be $Global:ClassificationWeekly.ScheduleTime
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }
        }



        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'classification has a different Continuous property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'should not throw error' {
                    {
                        $Splat = $Global:ClassificationMonthly.Clone()
                        $Splat.Continuous = (-not $Splat.Continuous)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLog property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'should not throw error' {
                    {
                        $Splat = $Global:ClassificationMonthly.Clone()
                        $Splat.ContinuousLog = (-not $Splat.ContinuousLog)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLogSize property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'should not throw error' {
                    {
                        $Splat = $Global:ClassificationMonthly.Clone()
                        $Splat.ContinuousLogSize = $Splat.ContinuousLogSize * 2
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ExcludeNamespace property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'should not throw error' {
                    {
                        $Splat = $Global:ClassificationMonthly.Clone()
                        $Splat.ExcludeNamespace = @('[AllVolumes]\$Extend /')
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleWeekly property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationWeekly }
                Mock Set-FSRMClassification

                It 'should not throw error' {
                    {
                        $Splat = $Global:ClassificationWeekly.Clone()
                        $Splat.ScheduleWeekly = @( 'Monday','Tuesday','Wednesday' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleMonthly property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'should not throw error' {
                    {
                        $Splat = $Global:ClassificationMonthly.Clone()
                        $Splat.ScheduleMonthly = @( 13,14,15 )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleRunDuration property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'should not throw error' {
                    {
                        $Splat = $Global:ClassificationMonthly.Clone()
                        $Splat.ScheduleRunDuration = $Splat.ScheduleRunDuration + 1
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleTime property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }
                Mock Set-FSRMClassification

                It 'should not throw error' {
                    {
                        $Splat = $Global:ClassificationMonthly.Clone()
                        $Splat.ScheduleTime = '01:00'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                    Assert-MockCalled -commandName Set-FSRMClassification -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'classification has no property differences' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }

                It 'should return true' {
                    $Splat = $Global:ClassificationMonthly.Clone()
                    Test-TargetResource @Splat | Should Be $True
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different Continuous property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }

                It 'should return false' {
                    $Splat = $Global:ClassificationMonthly.Clone()
                    $Splat.Continuous = (-not $Splat.Continuous)
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLog property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }

                It 'should return false' {
                    $Splat = $Global:ClassificationMonthly.Clone()
                    $Splat.ContinuousLog = (-not $Splat.ContinuousLog)
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ContinuousLogSize property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }

                It 'should return false' {
                    $Splat = $Global:ClassificationMonthly.Clone()
                    $Splat.ContinuousLogSize = $Splat.ContinuousLogSize * 2
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ExcludeNamespace property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }

                It 'should return false' {
                    $Splat = $Global:ClassificationMonthly.Clone()
                    $Splat.ExcludeNamespace = @('[AllVolumes]\$Extend /')
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleWeekly property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationWeekly }

                It 'should return false' {
                    $Splat = $Global:ClassificationWeekly.Clone()
                    $Splat.ScheduleWeekly = @( 'Monday','Tuesday','Wednesday' )
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleMonthly property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }

                It 'should return false' {
                    $Splat = $Global:ClassificationMonthly.Clone()
                    $Splat.ScheduleMonthly = @( 13,14,15 )
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleRunDuration property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }

                It 'should return false' {
                    $Splat = $Global:ClassificationMonthly.Clone()
                    $Splat.ScheduleRunDuration = $Splat.ScheduleRunDuration + 1
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMClassification -Exactly 1
                }
            }

            Context 'classification has a different ScheduleTime property' {

                Mock Get-FSRMClassification -MockWith { $Global:MockClassificationMonthly }

                It 'should return false' {
                    $Splat = $Global:ClassificationMonthly.Clone()
                    $Splat.ScheduleTime = '01:00'
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
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