$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMSettings'

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
        $script:DSCResourceName = 'DSR_FSRMSettings'

        # Create the Mock Objects that will be used for running tests
        $script:Settings = [PSObject] @{
            IsSingleInstance = 'Yes'
            SmtpServer = 'smtp.contoso.com'
            AdminEmailAddress = 'admin@contoso.com'
            FromEmailAddress = 'fsrm@contoso.com'
            CommandNotificationLimit = 10
            EmailNotificationLimit = 20
            EventNotificationLimit = 30
        }

        $script:MockSettings = New-CimInstance `
            -ClassName 'DSR_FSRMSettings' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                SmtpServer = $script:Settings.SmtpServer
                AdminEmailAddress = $script:Settings.AdminEmailAddress
                FromEmailAddress = $script:Settings.FromEmailAddress
                CommandNotificationLimit = $script:Settings.CommandNotificationLimit
                EmailNotificationLimit = $script:Settings.EmailNotificationLimit
                EventNotificationLimit = $script:Settings.EventNotificationLimit
            }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'Settings Exist' {

                Mock Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return correct Settings properties' {
                    $Result = Get-TargetResource -IsSingleInstance $script:Settings.IsSingleInstance
                    $Result.SmtpServer | Should -Be $script:Settings.SmtpServer
                    $Result.AdminEmailAddress | Should -Be $script:Settings.AdminEmailAddress
                    $Result.FromEmailAddress | Should -Be $script:Settings.FromEmailAddress
                    $Result.CommandNotificationLimit | Should -Be $script:Settings.CommandNotificationLimit
                    $Result.EmailNotificationLimit | Should -Be $script:Settings.EmailNotificationLimit
                    $Result.EventNotificationLimit | Should -Be $script:Settings.EventNotificationLimit
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'Settings has a different SmtpServer property' {

                Mock Set-FSRMSetting

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:Settings.Clone()
                        $Splat.SmtpServer = 'someotherserver.contoso.com'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different AdminEmailAddress property' {

                Mock Set-FSRMSetting

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:Settings.Clone()
                        $Splat.AdminEmailAddress = 'someoneelse@contoso.com'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different FromEmailAddress property' {

                Mock Set-FSRMSetting

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:Settings.Clone()
                        $Splat.FromEmailAddress = 'someoneelse@contoso.com'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different CommandNotificationLimit property' {

                Mock Set-FSRMSetting

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:Settings.Clone()
                        $Splat.CommandNotificationLimit = $Splat.CommandNotificationLimit + 1
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EmailNotificationLimit property' {

                Mock Set-FSRMSetting

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:Settings.Clone()
                        $Splat.EmailNotificationLimit = $Splat.EmailNotificationLimit + 1
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EventNotificationLimit property' {

                Mock Set-FSRMSetting

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:Settings.Clone()
                        $Splat.EventNotificationLimit = $Splat.EventNotificationLimit + 1
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Set-FSRMSetting -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'Settings has no property differences' {

                Mock Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return true' {
                    $Splat = $script:Settings.Clone()
                    Test-TargetResource @Splat | Should -Be $True
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different SmtpServer property' {

                Mock Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $Splat = $script:Settings.Clone()
                    $Splat.SmtpServer = 'someotherserver.contoso.com'
                    Test-TargetResource @Splat | Should -Be $False
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different AdminEmailAddress property' {

                Mock Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $Splat = $script:Settings.Clone()
                    $Splat.AdminEmailAddress = 'someoneelse@contoso.com'
                    Test-TargetResource @Splat | Should -Be $False
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different FromEmailAddress property' {

                Mock Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $Splat = $script:Settings.Clone()
                    $Splat.FromEmailAddress = 'someoneelse@contoso.com'
                    Test-TargetResource @Splat | Should -Be $False
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different CommandNotificationLimit property' {

                Mock Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $Splat = $script:Settings.Clone()
                    $Splat.CommandNotificationLimit = $Splat.CommandNotificationLimit + 1
                    Test-TargetResource @Splat | Should -Be $False
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EmailNotificationLimit property' {

                Mock Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $Splat = $script:Settings.Clone()
                    $Splat.EmailNotificationLimit = $Splat.EmailNotificationLimit + 1
                    Test-TargetResource @Splat | Should -Be $False
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EventNotificationLimit property' {

                Mock Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $Splat = $script:Settings.Clone()
                    $Splat.EventNotificationLimit = $Splat.EventNotificationLimit + 1
                    Test-TargetResource @Splat | Should -Be $False
                }
                It 'Should call expected Mocks' {
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
