$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMSettings'

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

        Describe 'DSC_FSRMSettings\Get-TargetResource' {
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

        Describe 'DSC_FSRMSettings\Set-TargetResource' {
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

        Describe 'DSC_FSRMSettings\Test-TargetResource' {
            Context 'Settings has no property differences' {
                Mock -CommandName Get-FSRMSetting -MockWith { $script:MockSettings }

                It 'Should return true' {
                    $testTargetResourceParameters = $script:Settings.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $true
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
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
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
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FSRMSetting -Exactly 1
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
