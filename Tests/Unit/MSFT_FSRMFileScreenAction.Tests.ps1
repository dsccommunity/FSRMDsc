$Global:DSCModuleName   = 'FSRMDsc'
$Global:DSCResourceName = 'MSFT_FSRMFileScreenAction'

Import-Module -Name (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) `
                               -ChildPath 'TestHelpers\CommonTestHelper.psm1') `
              -Force

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
                Subject = '[FileScreen Threshold]% FileScreen threshold exceeded'
                Body = 'User [Source Io Owner] has exceed the [FileScreen Threshold]% FileScreen threshold for FileScreen on [FileScreen Path] on server [Server]. The FileScreen limit is [FileScreen Limit MB] MB and the current usage is [FileScreen Used MB] MB ([FileScreen Used Percent]% of limit).'
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
                Body = 'User [Source Io Owner] has exceed the [FileScreen Threshold]% FileScreen threshold for FileScreen on [FileScreen Path] on server [Server]. The FileScreen limit is [FileScreen Limit MB] MB and the current usage is [FileScreen Used MB] MB ([FileScreen Used Percent]% of limit).'
                EventType = 'Warning'
                }
        $Global:MockReport = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Type = 'Report'
                ReportTypes = @( 'DuplicateFiles','LargeFiles','FileScreenUsage' )
            }

        # FileScreen mocks
        $Global:MockFileScreen = New-CimInstance `
            -ClassName 'MSFT_FSRMFileScreen' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Path = $ENV:Temp
                Description = 'File Screen Templates for Blocking Some Files'
                Ensure = 'Present'
                Active = $True
                IncludeGroup = @( 'Audio and Video Files','Executable Files','Backup Files' )
                Notification = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $Global:MockEmail,$Global:MockCommand,$Global:MockEvent
                )
            }

        $Global:TestFileScreenActionEmail = [PSObject]@{
            Path = $Global:MockFileScreen.Path
            Type = 'Email'
        }
        $Global:TestFileScreenActionSetEmail = $Global:TestFileScreenActionEmail.Clone()
        $Global:TestFileScreenActionSetEmail += [PSObject]@{
            Ensure = 'Present'
            Subject = $Global:MockEmail.Subject
            Body = $Global:MockEmail.Body
            MailBCC = $Global:MockEmail.MailBCC
            MailCC = $Global:MockEmail.MailCC
            MailTo = $Global:MockEmail.MailTo
        }

        $Global:TestFileScreenActionEvent = [PSObject]@{
            Path = $Global:MockFileScreen.Path
            Type = 'Event'
        }
        $Global:TestFileScreenActionSetEvent = $Global:TestFileScreenActionEvent.Clone()
        $Global:TestFileScreenActionSetEvent += [PSObject]@{
            Ensure = 'Present'
            Body = $Global:MockEvent.Body
            EventType = $Global:MockEvent.EventType
        }

        $Global:TestFileScreenActionCommand = [PSObject]@{
            Path = $Global:MockFileScreen.Path
            Type = 'Command'
        }
        $Global:TestFileScreenActionSetCommand = $Global:TestFileScreenActionCommand.Clone()
        $Global:TestFileScreenActionSetCommand += [PSObject]@{
            Ensure = 'Present'
            Command = $Global:MockCommand.Command
            CommandParameters = $Global:MockCommand.CommandParameters
            KillTimeOut = $Global:MockCommand.KillTimeOut
            RunLimitInterval = $Global:MockCommand.RunLimitInterval
            SecurityLevel = $Global:MockCommand.SecurityLevel
            ShouldLogError = $Global:MockCommand.ShouldLogError
            WorkingDirectory = $Global:MockCommand.WorkingDirectory
        }

        $Global:TestFileScreenActionReport = [PSObject]@{
            Path = $Global:MockFileScreen.Path
            Type = 'Report'
        }
        $Global:TestFileScreenActionSetReport = $Global:TestFileScreenActionReport.Clone()
        $Global:TestFileScreenActionSetReport += [PSObject]@{
            Ensure = 'Present'
            ReportTypes = $Global:MockReport.ReportTypes
        }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'File Screen does not exist' {

                Mock Get-FsrmFileScreen { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'should throw FileScreenNotFound exception' {
                    $Splat = $Global:TestFileScreenActionEmail.Clone()
                    $errorId = 'FileScreenNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenNotFoundError) `
                        -f $Splat.Path,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { $Result = Get-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists but action does not' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return absent File Screen action' {
                    $Splat = $Global:TestFileScreenActionReport.Clone()
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen and action exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return correct File Screen action' {
                    $Splat = $Global:TestFileScreenActionEmail.Clone()
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
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'File Screen does not exist' {

                Mock Get-FsrmFileScreen -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock Set-FsrmFileScreen

                It 'should throw FileScreenNotFound exception' {
                    $Splat = $Global:TestFileScreenActionEmail.Clone()
                    $errorId = 'FileScreenNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenNotFoundError) `
                        -f $Splat.Path,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Set-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists but action does not' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }
                Mock Set-FsrmFileScreen

                It 'should not throw exception' {
                    $Splat = $Global:TestFileScreenActionSetReport.Clone()
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }
                Mock Set-FsrmFileScreen

                It 'should not throw exception' {
                    $Splat = $Global:TestFileScreenActionSetEmail.Clone()
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action exists but should not' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }
                Mock Set-FsrmFileScreen

                It 'should not throw exception' {
                    $Splat = $Global:TestFileScreenActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen does not exist' {

                Mock Get-FsrmFileScreen -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'should throw FileScreenNotFound exception' {
                    $Splat = $Global:TestFileScreenActionEmail.Clone()
                    $errorId = 'FileScreenNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenNotFoundError) `
                        -f $Splat.Path,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists but action does not' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetReport.Clone()
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and matching action exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return true' {
                    $Splat = $Global:TestFileScreenActionSetEmail.Clone()
                    Test-TargetResource @Splat | Should Be $true
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Subject exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetEmail.Clone()
                    $Splat.Subject = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Body exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetEmail.Clone()
                    $Splat.Body = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Mail BCC exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetEmail.Clone()
                    $Splat.MailBCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Mail CC exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetEmail.Clone()
                    $Splat.MailCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Mail To exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetEmail.Clone()
                    $Splat.MailTo = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Command exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetCommand.Clone()
                    $Splat.Command = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different CommandParameters exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetCommand.Clone()
                    $Splat.CommandParameters = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different KillTimeOut exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetCommand.Clone()
                    $Splat.KillTimeOut = $Splat.KillTimeOut+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different RunLimitInterval exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetCommand.Clone()
                    $Splat.RunLimitInterval = $Splat.RunLimitInterval+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different SecurityLevel exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetCommand.Clone()
                    $Splat.SecurityLevel = 'NetworkService'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different ShouldLogError exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetCommand.Clone()
                    $Splat.ShouldLogError = (-not $Splat.ShouldLogError)
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different WorkingDirectory exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetCommand.Clone()
                    $Splat.WorkingDirectory = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different ReportTypes exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetReport.Clone()
                    $Splat.ReportTypes = @( 'LeastRecentlyAccessed' )
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action exists but should not' {

                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }

                It 'should return false' {
                    $Splat = $Global:TestFileScreenActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
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
