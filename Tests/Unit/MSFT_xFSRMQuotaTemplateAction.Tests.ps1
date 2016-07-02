$Global:DSCModuleName   = 'xFSRM'
$Global:DSCResourceName = 'MSFT_xFSRMQuotaTemplateAction'

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
        # General purpose Action Mocks
        $Global:MockEmail = New-CimInstance `
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
        $Global:MockCommand = New-CimInstance `
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
        $Global:MockEvent = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Type = 'Event'
                Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
                EventType = 'Warning'
                }
        $Global:MockReport = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Type = 'Report'
                ReportTypes = @('DuplicateFiles','LargeFiles','QuotaUsage')
            }

        # Quota Template mocks
        $Global:MockThreshold1 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = 85
                Action = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $Global:MockEmail, $Global:MockCommand
                )
            }
        $Global:MockThreshold2 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = 100
                Action = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $Global:MockEvent, $Global:MockReport
                )
            }

        # Quota Template mocks
        $Global:MockQuotaTemplate = New-CimInstance `
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
                    $Global:MockThreshold1, $Global:MockThreshold2
                )
            }

        $Global:TestQuotaTemplateActionEmail = [PSObject]@{
            Name = $Global:MockQuotaTemplate.Name
            Percentage = $Global:MockQuotaTemplate.Threshold[0].Percentage
            Type = 'Email'
        }
        $Global:TestQuotaTemplateActionSetEmail = $Global:TestQuotaTemplateActionEmail.Clone()
        $Global:TestQuotaTemplateActionSetEmail += [PSObject]@{
            Ensure = 'Present'
            Subject = $Global:MockEmail.Subject
            Body = $Global:MockEmail.Body
            MailBCC = $Global:MockEmail.MailBCC
            MailCC = $Global:MockEmail.MailCC
            MailTo = $Global:MockEmail.MailTo
        }

        $Global:TestQuotaTemplateActionEvent = [PSObject]@{
            Name = $Global:MockQuotaTemplate.Name
            Percentage = $Global:MockQuotaTemplate.Threshold[0].Percentage
            Type = 'Event'
        }
        $Global:TestQuotaTemplateActionSetEvent = $Global:TestQuotaTemplateActionEvent.Clone()
        $Global:TestQuotaTemplateActionSetEvent += [PSObject]@{
            Ensure = 'Present'
            Body = $Global:MockEvent.Body
            EventType = $Global:MockEvent.EventType
        }

        $Global:TestQuotaTemplateActionCommand = [PSObject]@{
            Name = $Global:MockQuotaTemplate.Name
            Percentage = $Global:MockQuotaTemplate.Threshold[0].Percentage
            Type = 'Command'
        }
        $Global:TestQuotaTemplateActionSetCommand = $Global:TestQuotaTemplateActionCommand.Clone()
        $Global:TestQuotaTemplateActionSetCommand += [PSObject]@{
            Ensure = 'Present'
            Command = $Global:MockCommand.Command
            CommandParameters = $Global:MockCommand.CommandParameters
            KillTimeOut = $Global:MockCommand.KillTimeOut
            RunLimitInterval = $Global:MockCommand.RunLimitInterval
            SecurityLevel = $Global:MockCommand.SecurityLevel
            ShouldLogError = $Global:MockCommand.ShouldLogError
            WorkingDirectory = $Global:MockCommand.WorkingDirectory
        }

        $Global:TestQuotaTemplateActionReport = [PSObject]@{
            Name = $Global:MockQuotaTemplate.Name
            Percentage = $Global:MockQuotaTemplate.Threshold[0].Percentage
            Type = 'Report'
        }
        $Global:TestQuotaTemplateActionSetReport = $Global:TestQuotaTemplateActionReport.Clone()
        $Global:TestQuotaTemplateActionSetReport += [PSObject]@{
            Ensure = 'Present'
            ReportTypes = $Global:MockReport.ReportTypes
        }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'Quota template does not exist' {

                Mock Get-FsrmQuotaTemplate { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'should throw QuotaTemplateNotFound exception' {
                    $Splat = $Global:TestQuotaTemplateActionEmail.Clone()
                    $errorId = 'QuotaTemplateNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaTemplateNotFoundError) `
                        -f $Splat.Name,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { $Result = Get-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but threshold does not' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should throw QuotaTemplateNotFound exception' {
                    $Splat = $Global:TestQuotaTemplateActionEmail.Clone()
                    $Splat.Percentage = 99
                    $errorId = 'QuotaTemplateThresholdNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaTemplateThresholdNotFoundError) `
                        -f $Splat.Name,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { $Result = Get-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but action does not' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return absent quota template action' {
                    $Splat = $Global:TestQuotaTemplateActionEvent.Clone()
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template and action exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return correct quota template action' {
                    $Splat = $Global:TestQuotaTemplateActionEmail.Clone()
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should Be 'Present'
                    $Result.Type = 'Email'
                    $Result.Subject = $Global:MockEmail.Subject
                    $Result.Body = $Global:MockEmail.Body
                    $Result.MailBCC = $Global:MockEmail.MailBCC
                    $Result.MailCC = $Global:MockEmail.MailCC
                    $Result.MailTo = $Global:MockEmail.MailTo
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'Quota template does not exist' {

                Mock Get-FsrmQuotaTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock Set-FsrmQuotaTemplate

                It 'should throw QuotaTemplateNotFound exception' {
                    $Splat = $Global:TestQuotaTemplateActionEmail.Clone()
                    $errorId = 'QuotaTemplateNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaTemplateNotFoundError) `
                        -f $Splat.Name,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Set-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists but threshold does not' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }
                Mock Set-FsrmQuotaTemplate

                It 'should throw QuotaTemplateNotFound exception' {
                    $Splat = $Global:TestQuotaTemplateActionEmail.Clone()
                    $Splat.Percentage = 99
                    $errorId = 'QuotaTemplateThresholdNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaTemplateThresholdNotFoundError) `
                        -f $Splat.Name,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Set-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists but action does not' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }
                Mock Set-FsrmQuotaTemplate

                It 'should not throw exception' {
                    $Splat = $Global:TestQuotaTemplateActionSetEvent.Clone()
                    $Splat.Type = 'Event'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }
                Mock Set-FsrmQuotaTemplate

                It 'should not throw exception' {
                    $Splat = $Global:TestQuotaTemplateActionSetEmail.Clone()
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action exists but should not' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }
                Mock Set-FsrmQuotaTemplate

                It 'should not throw exception' {
                    $Splat = $Global:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'Quota template does not exist' {

                Mock Get-FsrmQuotaTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'should throw QuotaTemplateNotFound exception' {
                    $Splat = $Global:TestQuotaTemplateActionEmail.Clone()
                    $errorId = 'QuotaTemplateNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaTemplateNotFoundError) `
                        -f $Splat.Name,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but threshold does not' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should throw QuotaTemplateNotFound exception' {
                    $Splat = $Global:TestQuotaTemplateActionEmail.Clone()
                    $Splat.Percentage = 99
                    $errorId = 'QuotaTemplateThresholdNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaTemplateThresholdNotFoundError) `
                        -f $Splat.Name,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists but action does not' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetEvent.Clone()
                    $Splat.Type = 'Event'
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and matching action exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return true' {
                    $Splat = $Global:TestQuotaTemplateActionSetEmail.Clone()
                    Test-TargetResource @Splat | Should Be $true
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Subject exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.Subject = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Body exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.Body = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Mail BCC exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.MailBCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Mail CC exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.MailCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Mail To exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.MailTo = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different Command exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.Command = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different CommandParameters exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.CommandParameters = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different KillTimeOut exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.KillTimeOut = $Splat.KillTimeOut+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different RunLimitInterval exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.RunLimitInterval = $Splat.RunLimitInterval+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different SecurityLevel exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.SecurityLevel = 'NetworkService'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different ShouldLogError exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.ShouldLogError = (-not $Splat.ShouldLogError)
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different WorkingDirectory exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetCommand.Clone()
                    $Splat.WorkingDirectory = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action with different ReportTypes exists' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetReport.Clone()
                    $Splat.ReportTypes = @( 'LeastRecentlyAccessed' )
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and action exists but should not' {

                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }

                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplateActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
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