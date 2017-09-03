$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMQuotaAction'

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
        $script:DSCResourceName = 'DSR_FSRMQuotaAction'

        # Create the Mock Objects that will be used for running tests
        # General purpose Action Mocks
        $script:MockEmail = New-CimInstance `
            -ClassName 'DSR_FSRMAction' `
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
            -ClassName 'DSR_FSRMAction' `
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
            -ClassName 'DSR_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Type = 'Event'
                Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
                EventType = 'Warning'
                }
        $script:MockReport = New-CimInstance `
            -ClassName 'DSR_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Type = 'Report'
                ReportTypes = @('DuplicateFiles','LargeFiles','QuotaUsage')
            }

        # Quota mocks
        $script:MockThreshold1 = New-CimInstance `
            -ClassName 'DSR_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = 85
                Action = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $script:MockEmail, $script:MockCommand
                )
            }
        $script:MockThreshold2 = New-CimInstance `
            -ClassName 'DSR_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = 100
                Action = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $script:MockEvent, $script:MockReport
                )
            }

        # Quota mocks
        $script:MockQuota = New-CimInstance `
            -ClassName 'DSR_FSRMQuota' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Path = 'c:\users'
                Description = '5 GB Hard Limit'
                Ensure = 'Present'
                Size = 5GB
                SoftLimit = $False
                Threshold = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $script:MockThreshold1, $script:MockThreshold2
                )
                Disabled = $False
                Template = '5 GB Limit'
            }

        $script:TestQuotaActionEmail = [PSObject]@{
            Path = $script:MockQuota.Path
            Percentage = $script:MockQuota.Threshold[0].Percentage
            Type = 'Email'
        }
        $script:TestQuotaActionSetEmail = $script:TestQuotaActionEmail.Clone()
        $script:TestQuotaActionSetEmail += [PSObject]@{
            Ensure = 'Present'
            Subject = $script:MockEmail.Subject
            Body = $script:MockEmail.Body
            MailBCC = $script:MockEmail.MailBCC
            MailCC = $script:MockEmail.MailCC
            MailTo = $script:MockEmail.MailTo
        }

        $script:TestQuotaActionEvent = [PSObject]@{
            Path = $script:MockQuota.Path
            Percentage = $script:MockQuota.Threshold[0].Percentage
            Type = 'Event'
        }
        $script:TestQuotaActionSetEvent = $script:TestQuotaActionEvent.Clone()
        $script:TestQuotaActionSetEvent += [PSObject]@{
            Ensure = 'Present'
            Body = $script:MockEvent.Body
            EventType = $script:MockEvent.EventType
        }

        $script:TestQuotaActionCommand = [PSObject]@{
            Path = $script:MockQuota.Path
            Percentage = $script:MockQuota.Threshold[0].Percentage
            Type = 'Command'
        }
        $script:TestQuotaActionSetCommand = $script:TestQuotaActionCommand.Clone()
        $script:TestQuotaActionSetCommand += [PSObject]@{
            Ensure = 'Present'
            Command = $script:MockCommand.Command
            CommandParameters = $script:MockCommand.CommandParameters
            KillTimeOut = $script:MockCommand.KillTimeOut
            RunLimitInterval = $script:MockCommand.RunLimitInterval
            SecurityLevel = $script:MockCommand.SecurityLevel
            ShouldLogError = $script:MockCommand.ShouldLogError
            WorkingDirectory = $script:MockCommand.WorkingDirectory
        }

        $script:TestQuotaActionReport = [PSObject]@{
            Path = $script:MockQuota.Path
            Percentage = $script:MockQuota.Threshold[0].Percentage
            Type = 'Report'
        }
        $script:TestQuotaActionSetReport = $script:TestQuotaActionReport.Clone()
        $script:TestQuotaActionSetReport += [PSObject]@{
            Ensure = 'Present'
            ReportTypes = $script:MockReport.ReportTypes
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'Quota does not exist' {

                Mock Get-FsrmQuota { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw QuotaNotFound exception' {
                    $Splat = $script:TestQuotaActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaNotFoundError) -f $Splat.Path,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Path'

                    { $Result = Get-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists but threshold does not' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should throw QuotaNotFound exception' {
                    $Splat = $script:TestQuotaActionEmail.Clone()
                    $Splat.Percentage = 99

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaThresholdNotFoundError) -f $Splat.Path,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Path'

                    { $Result = Get-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists but action does not' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return absent quota action' {
                    $Splat = $script:TestQuotaActionEvent.Clone()
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota and action exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return correct quota action' {
                    $Splat = $script:TestQuotaActionEmail.Clone()
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should Be 'Present'
                    $Result.Type = 'Email'
                    $Result.Subject = $script:MockEmail.Subject
                    $Result.Body = $script:MockEmail.Body
                    $Result.MailBCC = $script:MockEmail.MailBCC
                    $Result.MailCC = $script:MockEmail.MailCC
                    $Result.MailTo = $script:MockEmail.MailTo
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'Quota does not exist' {

                Mock Get-FsrmQuota -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock Set-FsrmQuota

                It 'Should throw QuotaNotFound exception' {
                    $Splat = $script:TestQuotaActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaNotFoundError) -f $Splat.Path,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Path'

                    { Set-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 0
                }
            }

            Context 'Quota exists but threshold does not' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }
                Mock Set-FsrmQuota

                It 'Should throw QuotaNotFound exception' {
                    $Splat = $script:TestQuotaActionEmail.Clone()
                    $Splat.Percentage = 99

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaThresholdNotFoundError) -f $Splat.Path,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Path'

                    { Set-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 0
                }
            }

            Context 'Quota exists but action does not' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }
                Mock Set-FsrmQuota

                It 'Should not throw exception' {
                    $Splat = $script:TestQuotaActionSetEvent.Clone()
                    $Splat.Type = 'Event'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }
                Mock Set-FsrmQuota

                It 'Should not throw exception' {
                    $Splat = $script:TestQuotaActionSetEmail.Clone()
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action exists but should not' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }
                Mock Set-FsrmQuota

                It 'Should not throw exception' {
                    $Splat = $script:TestQuotaActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'Quota does not exist' {

                Mock Get-FsrmQuota -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw QuotaNotFound exception' {
                    $Splat = $script:TestQuotaActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaNotFoundError) -f $Splat.Path,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists but threshold does not' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should throw QuotaNotFound exception' {
                    $Splat = $script:TestQuotaActionEmail.Clone()
                    $Splat.Percentage = 99

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.QuotaThresholdNotFoundError) -f $Splat.Path,$Splat.Percentage,$Splat.Type) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists but action does not' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetEvent.Clone()
                    $Splat.Type = 'Event'
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and matching action exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return true' {
                    $Splat = $script:TestQuotaActionSetEmail.Clone()
                    Test-TargetResource @Splat | Should Be $true
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different Subject exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetEmail.Clone()
                    $Splat.Subject = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different Body exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetEmail.Clone()
                    $Splat.Body = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different Mail BCC exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetEmail.Clone()
                    $Splat.MailBCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different Mail CC exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetEmail.Clone()
                    $Splat.MailCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different Mail To exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetEmail.Clone()
                    $Splat.MailTo = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different Command exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetCommand.Clone()
                    $Splat.Command = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different CommandParameters exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetCommand.Clone()
                    $Splat.CommandParameters = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different KillTimeOut exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetCommand.Clone()
                    $Splat.KillTimeOut = $Splat.KillTimeOut+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different RunLimitInterval exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetCommand.Clone()
                    $Splat.RunLimitInterval = $Splat.RunLimitInterval+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different SecurityLevel exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetCommand.Clone()
                    $Splat.SecurityLevel = 'NetworkService'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different ShouldLogError exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetCommand.Clone()
                    $Splat.ShouldLogError = (-not $Splat.ShouldLogError)
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different WorkingDirectory exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetCommand.Clone()
                    $Splat.WorkingDirectory = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action with different ReportTypes exists' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetReport.Clone()
                    $Splat.ReportTypes = @( 'LeastRecentlyAccessed' )
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }

            Context 'Quota exists and action exists but should not' {

                Mock Get-FsrmQuota -MockWith { return @($script:MockQuota) }

                It 'Should return false' {
                    $Splat = $script:TestQuotaActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
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
