$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileScreenAction'

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

        # Create the Mock Objects that will be used for running tests
        # General purpose Action Mocks
        $script:MockEmail = New-CimInstance `
            -ClassName 'DSR_FSRMAction' `
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
                Body = 'User [Source Io Owner] has exceed the [FileScreen Threshold]% FileScreen threshold for FileScreen on [FileScreen Path] on server [Server]. The FileScreen limit is [FileScreen Limit MB] MB and the current usage is [FileScreen Used MB] MB ([FileScreen Used Percent]% of limit).'
                EventType = 'Warning'
                }
        $script:MockReport = New-CimInstance `
            -ClassName 'DSR_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Type = 'Report'
                ReportTypes = @( 'DuplicateFiles','LargeFiles','FileScreenUsage' )
            }

        # FileScreen mocks
        $script:MockFileScreen = New-CimInstance `
            -ClassName 'DSR_FSRMFileScreen' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Path = $ENV:Temp
                Description = 'File Screen Templates for Blocking Some Files'
                Ensure = 'Present'
                Active = $True
                IncludeGroup = @( 'Audio and Video Files','Executable Files','Backup Files' )
                Notification = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $script:MockEmail,$script:MockCommand,$script:MockEvent
                )
            }

        $script:TestFileScreenActionEmail = [PSObject]@{
            Path = $script:MockFileScreen.Path
            Type = 'Email'
        }
        $script:TestFileScreenActionSetEmail = $script:TestFileScreenActionEmail.Clone()
        $script:TestFileScreenActionSetEmail += [PSObject]@{
            Ensure = 'Present'
            Subject = $script:MockEmail.Subject
            Body = $script:MockEmail.Body
            MailBCC = $script:MockEmail.MailBCC
            MailCC = $script:MockEmail.MailCC
            MailTo = $script:MockEmail.MailTo
        }

        $script:TestFileScreenActionEvent = [PSObject]@{
            Path = $script:MockFileScreen.Path
            Type = 'Event'
        }
        $script:TestFileScreenActionSetEvent = $script:TestFileScreenActionEvent.Clone()
        $script:TestFileScreenActionSetEvent += [PSObject]@{
            Ensure = 'Present'
            Body = $script:MockEvent.Body
            EventType = $script:MockEvent.EventType
        }

        $script:TestFileScreenActionCommand = [PSObject]@{
            Path = $script:MockFileScreen.Path
            Type = 'Command'
        }
        $script:TestFileScreenActionSetCommand = $script:TestFileScreenActionCommand.Clone()
        $script:TestFileScreenActionSetCommand += [PSObject]@{
            Ensure = 'Present'
            Command = $script:MockCommand.Command
            CommandParameters = $script:MockCommand.CommandParameters
            KillTimeOut = $script:MockCommand.KillTimeOut
            RunLimitInterval = $script:MockCommand.RunLimitInterval
            SecurityLevel = $script:MockCommand.SecurityLevel
            ShouldLogError = $script:MockCommand.ShouldLogError
            WorkingDirectory = $script:MockCommand.WorkingDirectory
        }

        $script:TestFileScreenActionReport = [PSObject]@{
            Path = $script:MockFileScreen.Path
            Type = 'Report'
        }
        $script:TestFileScreenActionSetReport = $script:TestFileScreenActionReport.Clone()
        $script:TestFileScreenActionSetReport += [PSObject]@{
            Ensure = 'Present'
            ReportTypes = $script:MockReport.ReportTypes
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'File Screen does not exist' {

                Mock Get-FsrmFileScreen { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw FileScreenNotFound exception' {
                    $Splat = $script:TestFileScreenActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenNotFoundError) -f $Splat.Path) `
                        -ArgumentName 'Path'

                    { $Result = Get-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists but action does not' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return absent File Screen action' {
                    $Splat = $script:TestFileScreenActionReport.Clone()
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen and action exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return correct File Screen action' {
                    $Splat = $script:TestFileScreenActionEmail.Clone()
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
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'File Screen does not exist' {

                Mock Get-FsrmFileScreen -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock Set-FsrmFileScreen

                It 'Should throw FileScreenNotFound exception' {
                    $Splat = $script:TestFileScreenActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenNotFoundError) -f $Splat.Path) `
                        -ArgumentName 'Path'

                    { Set-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists but action does not' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }
                Mock Set-FsrmFileScreen

                It 'Should not throw exception' {
                    $Splat = $script:TestFileScreenActionSetReport.Clone()
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }
                Mock Set-FsrmFileScreen

                It 'Should not throw exception' {
                    $Splat = $script:TestFileScreenActionSetEmail.Clone()
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action exists but should not' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }
                Mock Set-FsrmFileScreen

                It 'Should not throw exception' {
                    $Splat = $script:TestFileScreenActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen does not exist' {

                Mock Get-FsrmFileScreen -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw FileScreenNotFound exception' {
                    $Splat = $script:TestFileScreenActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenNotFoundError) -f $Splat.Path) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists but action does not' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetReport.Clone()
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and matching action exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return true' {
                    $Splat = $script:TestFileScreenActionSetEmail.Clone()
                    Test-TargetResource @Splat | Should Be $true
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Subject exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetEmail.Clone()
                    $Splat.Subject = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Body exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetEmail.Clone()
                    $Splat.Body = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Mail BCC exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetEmail.Clone()
                    $Splat.MailBCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Mail CC exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetEmail.Clone()
                    $Splat.MailCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Mail To exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetEmail.Clone()
                    $Splat.MailTo = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Command exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetCommand.Clone()
                    $Splat.Command = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different CommandParameters exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetCommand.Clone()
                    $Splat.CommandParameters = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different KillTimeOut exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetCommand.Clone()
                    $Splat.KillTimeOut = $Splat.KillTimeOut+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different RunLimitInterval exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetCommand.Clone()
                    $Splat.RunLimitInterval = $Splat.RunLimitInterval+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different SecurityLevel exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetCommand.Clone()
                    $Splat.SecurityLevel = 'NetworkService'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different ShouldLogError exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetCommand.Clone()
                    $Splat.ShouldLogError = (-not $Splat.ShouldLogError)
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different WorkingDirectory exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetCommand.Clone()
                    $Splat.WorkingDirectory = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different ReportTypes exists' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetReport.Clone()
                    $Splat.ReportTypes = @( 'LeastRecentlyAccessed' )
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action exists but should not' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
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
