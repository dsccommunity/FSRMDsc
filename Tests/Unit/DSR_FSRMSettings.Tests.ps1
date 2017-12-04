$script:DSCModuleName = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMSettings'

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
        $script:DSCResourceName = 'DSR_FSRMSettings'

        # Create the Mock -CommandName Objects that will be used for running tests
        $script:Settings = [PSObject] @{
            IsSingleInstance         = 'Yes'
            SmtpServer               = 'smtp.contoso.com'
            AdminEmailAddress        = 'admin@contoso.com'
            FromEmailAddress         = 'fsrm@contoso.com'
            CommandNotificationLimit = 10
            EmailNotificationLimit   = 20
            EventNotificationLimit   = 30
            Verbose                  = $true
        }

        $script:MockSettings = New-CimInstance `
            -ClassName 'MSFT_FSRMSettings' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            SmtpServer               = $script:Settings.SmtpServer
            AdminEmailAddress        = $script:Settings.AdminEmailAddress
            FromEmailAddress         = $script:Settings.FromEmailAddress
            CommandNotificationLimit = $script:Settings.CommandNotificationLimit
            EmailNotificationLimit   = $script:Settings.EmailNotificationLimit
            EventNotificationLimit   = $script:Settings.EventNotificationLimit
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'Settings Exist' {
                Mock -CommandName Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return correct Settings properties' {
                    $result = Get-TargetResource -IsSingleInstance $script:Settings.IsSingleInstance -Verbose
                    $result.SmtpServer | Should -Be $script:Settings.SmtpServer
                    $result.AdminEmailAddress | Should -Be $script:Settings.AdminEmailAddress
                    $result.FromEmailAddress | Should -Be $script:Settings.FromEmailAddress
                    $result.CommandNotificationLimit | Should -Be $script:Settings.CommandNotificationLimit
                    $result.EmailNotificationLimit | Should -Be $script:Settings.EmailNotificationLimit
                    $result.EventNotificationLimit | Should -Be $script:Settings.EventNotificationLimit
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FSRMSetting -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'Settings has a different SmtpServer property' {
                Mock -CommandName Set-FSRMSetting

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:Settings.Clone()
                        $setTargetResourceParameters.SmtpServer = 'someotherserver.contoso.com'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different AdminEmailAddress property' {
                Mock -CommandName Set-FSRMSetting
                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:Settings.Clone()
                        $setTargetResourceParameters.AdminEmailAddress = 'someoneelse@contoso.com'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different FromEmailAddress property' {
                Mock -CommandName Set-FSRMSetting
                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:Settings.Clone()
                        $setTargetResourceParameters.FromEmailAddress = 'someoneelse@contoso.com'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different CommandNotificationLimit property' {
                Mock -CommandName Set-FSRMSetting

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:Settings.Clone()
                        $setTargetResourceParameters.CommandNotificationLimit = $setTargetResourceParameters.CommandNotificationLimit + 1
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EmailNotificationLimit property' {
                Mock -CommandName Set-FSRMSetting

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:Settings.Clone()
                        $setTargetResourceParameters.EmailNotificationLimit = $setTargetResourceParameters.EmailNotificationLimit + 1
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Set-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EventNotificationLimit property' {
                Mock -CommandName Set-FSRMSetting

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:Settings.Clone()
                        $setTargetResourceParameters.EventNotificationLimit = $setTargetResourceParameters.EventNotificationLimit + 1
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Set-FSRMSetting -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'Settings has no property differences' {
                Mock -CommandName Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return true' {
                    $testTargetResourceParameters = $script:Settings.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $True
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different SmtpServer property' {
                Mock -CommandName Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:Settings.Clone()
                    $testTargetResourceParameters.SmtpServer = 'someotherserver.contoso.com'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different AdminEmailAddress property' {
                Mock -CommandName Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:Settings.Clone()
                    $testTargetResourceParameters.AdminEmailAddress = 'someoneelse@contoso.com'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different FromEmailAddress property' {
                Mock -CommandName Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:Settings.Clone()
                    $testTargetResourceParameters.FromEmailAddress = 'someoneelse@contoso.com'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different CommandNotificationLimit property' {
                Mock -CommandName Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:Settings.Clone()
                    $testTargetResourceParameters.CommandNotificationLimit = $testTargetResourceParameters.CommandNotificationLimit + 1
                    Test-TargetResource @testTargetResourceParameters | Should -Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EmailNotificationLimit property' {
                Mock -CommandName Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:Settings.Clone()
                    $testTargetResourceParameters.EmailNotificationLimit = $testTargetResourceParameters.EmailNotificationLimit + 1
                    Test-TargetResource @testTargetResourceParameters | Should -Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMSetting -Exactly 1
                }
            }

            Context 'Settings has a different EventNotificationLimit property' {
                Mock -CommandName Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:Settings.Clone()
                    $testTargetResourceParameters.EventNotificationLimit = $testTargetResourceParameters.EventNotificationLimit + 1
                    Test-TargetResource @testTargetResourceParameters | Should -Be $False
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMSetting -Exactly 1
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
