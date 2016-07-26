$Global:DSCModuleName   = 'FSRMDsc'
$Global:DSCResourceName = 'MSFT_FSRMSettings'

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
        $Global:Settings = [PSObject] @{
            Id = 'Default'
            SmtpServer = 'smtp.contoso.com'
            AdminEmailAddress = 'admin@contoso.com'
            FromEmailAddress = 'fsrm@contoso.com'
            CommandNotificationLimit = 10
            EmailNotificationLimit = 20
            EventNotificationLimit = 30
        }

        $Global:MockSettings = New-CimInstance `
            -ClassName 'MSFT_FSRMSettings' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                SmtpServer = $Global:Settings.SmtpServer
                AdminEmailAddress = $Global:Settings.AdminEmailAddress
                FromEmailAddress = $Global:Settings.FromEmailAddress
                CommandNotificationLimit = $Global:Settings.CommandNotificationLimit
                EmailNotificationLimit = $Global:Settings.EmailNotificationLimit
                EventNotificationLimit = $Global:Settings.EventNotificationLimit
            }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'Settings Exist' {

                Mock Get-FSRMSetting -MockWith { $Global:MockSettings }

                It 'should return correct Settings properties' {
                    $Result = Get-TargetResource -Id $Global:Settings.Id
                    $Result.SmtpServer | Should Be $Global:Settings.SmtpServer
                    $Result.AdminEmailAddress | Should Be $Global:Settings.AdminEmailAddress
                    $Result.FromEmailAddress | Should Be $Global:Settings.FromEmailAddress
                    $Result.CommandNotificationLimit | Should Be $Global:Settings.CommandNotificationLimit
                    $Result.EmailNotificationLimit | Should Be $Global:Settings.EmailNotificationLimit
                    $Result.EventNotificationLimit | Should Be $Global:Settings.EventNotificationLimit
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'Settings has a different SmtpServer property' {

                Mock Set-FSRMSetting

                It 'should not throw error' {
                    {
                        $Splat = $Global:Settings.Clone()
                        $Splat.SmtpServer = 'someotherserver.contoso.com'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different AdminEmailAddress property' {

                Mock Set-FSRMSetting

                It 'should not throw error' {
                    {
                        $Splat = $Global:Settings.Clone()
                        $Splat.AdminEmailAddress = 'someoneelse@contoso.com'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different FromEmailAddress property' {

                Mock Set-FSRMSetting

                It 'should not throw error' {
                    {
                        $Splat = $Global:Settings.Clone()
                        $Splat.FromEmailAddress = 'someoneelse@contoso.com'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different CommandNotificationLimit property' {

                Mock Set-FSRMSetting

                It 'should not throw error' {
                    {
                        $Splat = $Global:Settings.Clone()
                        $Splat.CommandNotificationLimit = $Splat.CommandNotificationLimit + 1
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EmailNotificationLimit property' {

                Mock Set-FSRMSetting

                It 'should not throw error' {
                    {
                        $Splat = $Global:Settings.Clone()
                        $Splat.EmailNotificationLimit = $Splat.EmailNotificationLimit + 1
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EventNotificationLimit property' {

                Mock Set-FSRMSetting

                It 'should not throw error' {
                    {
                        $Splat = $Global:Settings.Clone()
                        $Splat.EventNotificationLimit = $Splat.EventNotificationLimit + 1
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'Settings has no property differences' {

                Mock Get-FSRMSetting -MockWith { $Global:MockSettings }

                It 'should return true' {
                    $Splat = $Global:Settings.Clone()
                    Test-TargetResource @Splat | Should Be $True
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different SmtpServer property' {

                Mock Get-FSRMSetting -MockWith { $Global:MockSettings }

                It 'should return false' {
                    $Splat = $Global:Settings.Clone()
                    $Splat.SmtpServer = 'someotherserver.contoso.com'
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different AdminEmailAddress property' {

                Mock Get-FSRMSetting -MockWith { $Global:MockSettings }

                It 'should return false' {
                    $Splat = $Global:Settings.Clone()
                    $Splat.AdminEmailAddress = 'someoneelse@contoso.com'
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different FromEmailAddress property' {

                Mock Get-FSRMSetting -MockWith { $Global:MockSettings }

                It 'should return false' {
                    $Splat = $Global:Settings.Clone()
                    $Splat.FromEmailAddress = 'someoneelse@contoso.com'
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different CommandNotificationLimit property' {

                Mock Get-FSRMSetting -MockWith { $Global:MockSettings }

                It 'should return false' {
                    $Splat = $Global:Settings.Clone()
                    $Splat.CommandNotificationLimit = $Splat.CommandNotificationLimit + 1
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EmailNotificationLimit property' {

                Mock Get-FSRMSetting -MockWith { $Global:MockSettings }

                It 'should return false' {
                    $Splat = $Global:Settings.Clone()
                    $Splat.EmailNotificationLimit = $Splat.EmailNotificationLimit + 1
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EventNotificationLimit property' {

                Mock Get-FSRMSetting -MockWith { $Global:MockSettings }

                It 'should return false' {
                    $Splat = $Global:Settings.Clone()
                    $Splat.EventNotificationLimit = $Splat.EventNotificationLimit + 1
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
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
