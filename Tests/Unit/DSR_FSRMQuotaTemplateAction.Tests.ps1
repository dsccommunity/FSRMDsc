$script:DSCModuleName = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMQuotaTemplateAction'

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
        $script:DSCResourceName = 'DSR_FSRMQuotaTemplateAction'

        # Create the Mock -CommandName Objects that will be used for running tests
        # General purpose Action Mocks
        $script:MockEmail = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Type    = 'Email'
            Subject = '[Quota Threshold]% quota threshold exceeded'
            Body    = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC = ''
            MailCC  = 'fileserveradmins@contoso.com'
            MailTo  = '[Source Io Owner Email]'
        }

        $script:MockCommand = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Type              = 'Command'
            Command           = 'c:\dothis.cmd'
            CommandParameters = ''
            KillTimeOut       = 60
            RunLimitInterval  = 3600
            SecurityLevel     = 'LocalSystem'
            ShouldLogError    = $true
            WorkingDirectory  = 'c:\'
        }

        $script:MockEvent = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Type      = 'Event'
            Body      = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            EventType = 'Warning'
        }

        $script:MockReport = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Type        = 'Report'
            ReportTypes = @('DuplicateFiles', 'LargeFiles', 'QuotaUsage')
        }

        # Quota Template mocks
        $script:MockThreshold1 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Percentage = 85
            Action     = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                $script:MockEmail, $script:MockCommand
            )
        }

        $script:MockThreshold2 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Percentage = 100
            Action     = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                $script:MockEvent, $script:MockReport
            )
        }

        # Quota Template mocks
        $script:MockQuotaTemplate = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaTemplate' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Name        = '5 GB Limit'
            Description = '5 GB Hard Limit'
            Ensure      = 'Present'
            Size        = 5GB
            SoftLimit   = $false
            Threshold   = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                $script:MockThreshold1, $script:MockThreshold2
            )
        }

        $script:TestQuotaTemplateActionEmail = [PSObject]@{
            Name       = $script:MockQuotaTemplate.Name
            Percentage = $script:MockQuotaTemplate.Threshold[0].Percentage
            Type       = 'Email'
            Verbose    = $true
        }

        $script:TestQuotaTemplateActionSetEmail = $script:TestQuotaTemplateActionEmail.Clone()
        $script:TestQuotaTemplateActionSetEmail += [PSObject]@{
            Ensure  = 'Present'
            Subject = $script:MockEmail.Subject
            Body    = $script:MockEmail.Body
            MailBCC = $script:MockEmail.MailBCC
            MailCC  = $script:MockEmail.MailCC
            MailTo  = $script:MockEmail.MailTo
        }

        $script:TestQuotaTemplateActionEvent = [PSObject]@{
            Name       = $script:MockQuotaTemplate.Name
            Percentage = $script:MockQuotaTemplate.Threshold[0].Percentage
            Type       = 'Event'
            Verbose    = $true
        }

        $script:TestQuotaTemplateActionSetEvent = $script:TestQuotaTemplateActionEvent.Clone()
        $script:TestQuotaTemplateActionSetEvent += [PSObject]@{
            Ensure    = 'Present'
            Body      = $script:MockEvent.Body
            EventType = $script:MockEvent.EventType
        }

        $script:TestQuotaTemplateActionCommand = [PSObject]@{
            Name       = $script:MockQuotaTemplate.Name
            Percentage = $script:MockQuotaTemplate.Threshold[0].Percentage
            Type       = 'Command'
            Verbose    = $true
        }

        $script:TestQuotaTemplateActionSetCommand = $script:TestQuotaTemplateActionCommand.Clone()
        $script:TestQuotaTemplateActionSetCommand += [PSObject]@{
            Ensure            = 'Present'
            Command           = $script:MockCommand.Command
            CommandParameters = $script:MockCommand.CommandParameters
            KillTimeOut       = $script:MockCommand.KillTimeOut
            RunLimitInterval  = $script:MockCommand.RunLimitInterval
            SecurityLevel     = $script:MockCommand.SecurityLevel
            ShouldLogError    = $script:MockCommand.ShouldLogError
            WorkingDirectory  = $script:MockCommand.WorkingDirectory
        }

        $script:TestQuotaTemplateActionReport = [PSObject]@{
            Name       = $script:MockQuotaTemplate.Name
            Percentage = $script:MockQuotaTemplate.Threshold[0].Percentage
            Type       = 'Report'
            Verbose    = $true
        }

        $script:TestQuotaTemplateActionSetReport = $script:TestQuotaTemplateActionReport.Clone()
        $script:TestQuotaTemplateActionSetReport += [PSObject]@{
            Ensure      = 'Present'
            ReportTypes = $script:MockReport.ReportTypes
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'Quota template does not exist' {
                Mock -CommandName Get-FsrmQuotaTemplate { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw QuotaTemplateNotFound exception' {
                    $getTargetResourceParameters = $script:TestQuotaTemplateActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateNotFoundError) -f $getTargetResourceParameters.Name, $getTargetResourceParameters.Percentage, $getTargetResourceParameters.Type) `
                        -ArgumentName 'Name'

                    { $result = Get-TargetResource @getTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but threshold does not' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should throw QuotaTemplateNotFound exception' {
                    $getTargetResourceParameters = $script:TestQuotaTemplateActionEmail.Clone()
                    $getTargetResourceParameters.Percentage = 99

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateThresholdNotFoundError) -f $getTargetResourceParameters.Name, $getTargetResourceParameters.Percentage, $getTargetResourceParameters.Type) `
                        -ArgumentName 'Name'

                    { $result = Get-TargetResource @getTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but action does not' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return absent quota template action' {
                    $getTargetResourceParameters = $script:TestQuotaTemplateActionEvent.Clone()
                    $result = Get-TargetResource @getTargetResourceParameters
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template and action exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return correct quota template action' {
                    $getTargetResourceParameters = $script:TestQuotaTemplateActionEmail.Clone()
                    $result = Get-TargetResource @getTargetResourceParameters
                    $result.Ensure | Should -Be 'Present'
                    $result.Type = 'Email'
                    $result.Subject = $script:MockEmail.Subject
                    $result.Body = $script:MockEmail.Body
                    $result.MailBCC = $script:MockEmail.MailBCC
                    $result.MailCC = $script:MockEmail.MailCC
                    $result.MailTo = $script:MockEmail.MailTo
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'Quota template does not exist' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock -CommandName Set-FsrmQuotaTemplate

                It 'Should throw QuotaTemplateNotFound exception' {
                    $setTargetResourceParameters = $script:TestQuotaTemplateActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateNotFoundError) -f $setTargetResourceParameters.Name, $setTargetResourceParameters.Percentage, $setTargetResourceParameters.Type) `
                        -ArgumentName 'Name'

                    { Set-TargetResource @setTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists but threshold does not' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }
                Mock -CommandName Set-FsrmQuotaTemplate

                It 'Should throw QuotaTemplateNotFound exception' {
                    $setTargetResourceParameters = $script:TestQuotaTemplateActionEmail.Clone()
                    $setTargetResourceParameters.Percentage = 99

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateThresholdNotFoundError) -f $setTargetResourceParameters.Name, $setTargetResourceParameters.Percentage, $setTargetResourceParameters.Type) `
                        -ArgumentName 'Name'

                    { Set-TargetResource @setTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists but action does not' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }
                Mock -CommandName Set-FsrmQuotaTemplate

                It 'Should not throw exception' {
                    $setTargetResourceParameters = $script:TestQuotaTemplateActionSetEvent.Clone()
                    $setTargetResourceParameters.Type = 'Event'
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }
                Mock -CommandName Set-FsrmQuotaTemplate

                It 'Should not throw exception' {
                    $setTargetResourceParameters = $script:TestQuotaTemplateActionSetEmail.Clone()
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action exists but should not' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }
                Mock -CommandName Set-FsrmQuotaTemplate

                It 'Should not throw exception' {
                    $setTargetResourceParameters = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $setTargetResourceParameters.Ensure = 'Absent'
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'Quota template does not exist' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw QuotaTemplateNotFound exception' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateNotFoundError) -f $testTargetResourceParameters.Name, $testTargetResourceParameters.Percentage, $testTargetResourceParameters.Type) `
                        -ArgumentName 'Name'

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but threshold does not' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should throw QuotaTemplateNotFound exception' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionEmail.Clone()
                    $testTargetResourceParameters.Percentage = 99

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateThresholdNotFoundError) -f $testTargetResourceParameters.Name, $testTargetResourceParameters.Percentage, $testTargetResourceParameters.Type) `
                        -ArgumentName 'Name'

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but action does not' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetEvent.Clone()
                    $testTargetResourceParameters.Type = 'Event'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and matching action exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return true' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetEmail.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $true
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Subject exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $testTargetResourceParameters.Subject = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Body exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $testTargetResourceParameters.Body = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Mail BCC exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $testTargetResourceParameters.MailBCC = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Mail CC exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $testTargetResourceParameters.MailCC = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Mail To exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $testTargetResourceParameters.MailTo = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Command exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $testTargetResourceParameters.Command = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different CommandParameters exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $testTargetResourceParameters.CommandParameters = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different KillTimeOut exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $testTargetResourceParameters.KillTimeOut = $testTargetResourceParameters.KillTimeOut + 1
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different RunLimitInterval exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $testTargetResourceParameters.RunLimitInterval = $testTargetResourceParameters.RunLimitInterval + 1
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different SecurityLevel exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $testTargetResourceParameters.SecurityLevel = 'NetworkService'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different ShouldLogError exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $testTargetResourceParameters.ShouldLogError = (-not $testTargetResourceParameters.ShouldLogError)
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different WorkingDirectory exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $testTargetResourceParameters.WorkingDirectory = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different ReportTypes exists' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetReport.Clone()
                    $testTargetResourceParameters.ReportTypes = @( 'LeastRecentlyAccessed' )
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action exists but should not' {
                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $testTargetResourceParameters.Ensure = 'Absent'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
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
