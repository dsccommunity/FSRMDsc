$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMQuotaTemplateAction'

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
        $script:DSCResourceName = 'DSR_FSRMQuotaTemplateAction'

        # Create the Mock -CommandName Objects that will be used for running tests
        # General purpose Action Mocks
        $script:MockEmail = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Type = 'Email'
                Subject = '[Quota Threshold]% quota threshold exceeded'
                Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
                MailBCC = ''
                MailCC = 'fileserveradmins@contoso.com'
                MailTo = '[Source Io Owner Email]'
                }
        $script:MockCommand = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Type = 'Command'
                Command = 'c:\dothis.cmd'
                CommandParameters = ''
                KillTimeOut = 60
                RunLimitInterval = 3600
                SecurityLevel = 'LocalSystem'
                ShouldLogError = $true
                WorkingDirectory = 'c:\'
                }
        $script:MockEvent = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Type = 'Event'
                Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
                EventType = 'Warning'
                }
        $script:MockReport = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Type = 'Report'
                ReportTypes = @('DuplicateFiles','LargeFiles','QuotaUsage')
            }

        # Quota Template mocks
        $script:MockThreshold1 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = 85
                Action = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $script:MockEmail, $script:MockCommand
                )
            }
        $script:MockThreshold2 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = 100
                Action = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $script:MockEvent, $script:MockReport
                )
            }

        # Quota Template mocks
        $script:MockQuotaTemplate = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaTemplate' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = '5 GB Limit'
                Description = '5 GB Hard Limit'
                Ensure = 'Present'
                Size = 5GB
                SoftLimit = $False
                Threshold = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $script:MockThreshold1, $script:MockThreshold2
                )
            }

        $script:TestQuotaTemplateActionEmail = [PSObject]@{
            Name = $script:MockQuotaTemplate.Name
            Percentage = $script:MockQuotaTemplate.Threshold[0].Percentage
            Type = 'Email'
        }
        $script:TestQuotaTemplateActionSetEmail = $script:TestQuotaTemplateActionEmail.Clone()
        $script:TestQuotaTemplateActionSetEmail += [PSObject]@{
            Ensure = 'Present'
            Subject = $script:MockEmail.Subject
            Body = $script:MockEmail.Body
            MailBCC = $script:MockEmail.MailBCC
            MailCC = $script:MockEmail.MailCC
            MailTo = $script:MockEmail.MailTo
        }

        $script:TestQuotaTemplateActionEvent = [PSObject]@{
            Name = $script:MockQuotaTemplate.Name
            Percentage = $script:MockQuotaTemplate.Threshold[0].Percentage
            Type = 'Event'
        }
        $script:TestQuotaTemplateActionSetEvent = $script:TestQuotaTemplateActionEvent.Clone()
        $script:TestQuotaTemplateActionSetEvent += [PSObject]@{
            Ensure = 'Present'
            Body = $script:MockEvent.Body
            EventType = $script:MockEvent.EventType
        }

        $script:TestQuotaTemplateActionCommand = [PSObject]@{
            Name = $script:MockQuotaTemplate.Name
            Percentage = $script:MockQuotaTemplate.Threshold[0].Percentage
            Type = 'Command'
        }
        $script:TestQuotaTemplateActionSetCommand = $script:TestQuotaTemplateActionCommand.Clone()
        $script:TestQuotaTemplateActionSetCommand += [PSObject]@{
            Ensure = 'Present'
            Command = $script:MockCommand.Command
            CommandParameters = $script:MockCommand.CommandParameters
            KillTimeOut = $script:MockCommand.KillTimeOut
            RunLimitInterval = $script:MockCommand.RunLimitInterval
            SecurityLevel = $script:MockCommand.SecurityLevel
            ShouldLogError = $script:MockCommand.ShouldLogError
            WorkingDirectory = $script:MockCommand.WorkingDirectory
        }

        $script:TestQuotaTemplateActionReport = [PSObject]@{
            Name = $script:MockQuotaTemplate.Name
            Percentage = $script:MockQuotaTemplate.Threshold[0].Percentage
            Type = 'Report'
        }
        $script:TestQuotaTemplateActionSetReport = $script:TestQuotaTemplateActionReport.Clone()
        $script:TestQuotaTemplateActionSetReport += [PSObject]@{
            Ensure = 'Present'
            ReportTypes = $script:MockReport.ReportTypes
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'Quota template does not exist' {

                Mock -CommandName Get-FsrmQuotaTemplate { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw QuotaTemplateNotFound exception' {
                    $Splat = $script:TestQuotaTemplateActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateNotFoundError) -f $Splat.Name,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Name'

                    { $Result = Get-TargetResource @Splat } | Should -Throw $errorRecord
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but threshold does not' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should throw QuotaTemplateNotFound exception' {
                    $Splat = $script:TestQuotaTemplateActionEmail.Clone()
                    $Splat.Percentage = 99

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateThresholdNotFoundError) -f $Splat.Name,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Name'

                    { $Result = Get-TargetResource @Splat } | Should -Throw $errorRecord
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but action does not' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return absent quota template action' {
                    $Splat = $script:TestQuotaTemplateActionEvent.Clone()
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should -Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template and action exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return correct quota template action' {
                    $Splat = $script:TestQuotaTemplateActionEmail.Clone()
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should -Be 'Present'
                    $Result.Type = 'Email'
                    $Result.Subject = $script:MockEmail.Subject
                    $Result.Body = $script:MockEmail.Body
                    $Result.MailBCC = $script:MockEmail.MailBCC
                    $Result.MailCC = $script:MockEmail.MailCC
                    $Result.MailTo = $script:MockEmail.MailTo
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
                    $Splat = $script:TestQuotaTemplateActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateNotFoundError) -f $Splat.Name,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Name'

                    { Set-TargetResource @Splat } | Should -Throw $errorRecord
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
                    $Splat = $script:TestQuotaTemplateActionEmail.Clone()
                    $Splat.Percentage = 99

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateThresholdNotFoundError) -f $Splat.Name,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Name'

                    { Set-TargetResource @Splat } | Should -Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists but action does not' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }
                Mock -CommandName Set-FsrmQuotaTemplate

                It 'Should Not Throw exception' {
                    $Splat = $script:TestQuotaTemplateActionSetEvent.Clone()
                    $Splat.Type = 'Event'
                    { Set-TargetResource @Splat } | Should -Not -Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }
                Mock -CommandName Set-FsrmQuotaTemplate

                It 'Should Not Throw exception' {
                    $Splat = $script:TestQuotaTemplateActionSetEmail.Clone()
                    { Set-TargetResource @Splat } | Should -Not -Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action exists but should not' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }
                Mock -CommandName Set-FsrmQuotaTemplate

                It 'Should Not Throw exception' {
                    $Splat = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    { Set-TargetResource @Splat } | Should -Not -Throw
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
                    $Splat = $script:TestQuotaTemplateActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateNotFoundError) -f $Splat.Name,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Name'

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but threshold does not' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should throw QuotaTemplateNotFound exception' {
                    $Splat = $script:TestQuotaTemplateActionEmail.Clone()
                    $Splat.Percentage = 99

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaTemplateThresholdNotFoundError) -f $Splat.Name,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Name'

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but action does not' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetEvent.Clone()
                    $Splat.Type = 'Event'
                    Test-TargetResource @Splat | Should -Be $False
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and matching action exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return true' {
                    $Splat = $script:TestQuotaTemplateActionSetEmail.Clone()
                    Test-TargetResource @Splat | Should -Be $true
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Subject exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.Subject = 'Different'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Body exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.Body = 'Different'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Mail BCC exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.MailBCC = 'Different'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Mail CC exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.MailCC = 'Different'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Mail To exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.MailTo = 'Different'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Command exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.Command = 'Different'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different CommandParameters exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.CommandParameters = 'Different'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different KillTimeOut exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.KillTimeOut = $Splat.KillTimeOut+1
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different RunLimitInterval exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.RunLimitInterval = $Splat.RunLimitInterval+1
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different SecurityLevel exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.SecurityLevel = 'NetworkService'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different ShouldLogError exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.ShouldLogError = (-not $Splat.ShouldLogError)
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different WorkingDirectory exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.WorkingDirectory = 'Different'
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different ReportTypes exists' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetReport.Clone()
                    $Splat.ReportTypes = @( 'LeastRecentlyAccessed' )
                    Test-TargetResource @Splat | Should -Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action exists but should not' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should -Be $false
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
