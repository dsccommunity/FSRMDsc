$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileScreenTemplateAction'

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
        $script:DSCResourceName = 'DSR_FSRMFileScreenTemplateAction'

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
                ReportTypes = @('DuplicateFiles','LargeFiles','FileScreenUsage')
            }

        # File Screen Template mocks
        $script:MockFileScreenTemplate = New-CimInstance `
            -ClassName 'DSR_FSRMFileScreenTemplate' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Name = 'Block Some Files'
                Description = 'File Screen Templates for Blocking Some Files'
                Ensure = 'Present'
                Active = $True
                IncludeGroup = @( 'Audio and Video Files','Executable Files','Backup Files' )
                Notification = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $script:MockEmail,$script:MockCommand,$script:MockEvent
                )
            }

        $script:TestFileScreenTemplateActionEmail = [PSObject]@{
            Name = $script:MockFileScreenTemplate.Name
            Type = 'Email'
        }
        $script:TestFileScreenTemplateActionSetEmail = $script:TestFileScreenTemplateActionEmail.Clone()
        $script:TestFileScreenTemplateActionSetEmail += [PSObject]@{
            Ensure = 'Present'
            Subject = $script:MockEmail.Subject
            Body = $script:MockEmail.Body
            MailBCC = $script:MockEmail.MailBCC
            MailCC = $script:MockEmail.MailCC
            MailTo = $script:MockEmail.MailTo
        }

        $script:TestFileScreenTemplateActionEvent = [PSObject]@{
            Name = $script:MockFileScreenTemplate.Name
            Type = 'Event'
        }
        $script:TestFileScreenTemplateActionSetEvent = $script:TestFileScreenTemplateActionEvent.Clone()
        $script:TestFileScreenTemplateActionSetEvent += [PSObject]@{
            Ensure = 'Present'
            Body = $script:MockEvent.Body
            EventType = $script:MockEvent.EventType
        }

        $script:TestFileScreenTemplateActionCommand = [PSObject]@{
            Name = $script:MockFileScreenTemplate.Name
            Type = 'Command'
        }
        $script:TestFileScreenTemplateActionSetCommand = $script:TestFileScreenTemplateActionCommand.Clone()
        $script:TestFileScreenTemplateActionSetCommand += [PSObject]@{
            Ensure = 'Present'
            Command = $script:MockCommand.Command
            CommandParameters = $script:MockCommand.CommandParameters
            KillTimeOut = $script:MockCommand.KillTimeOut
            RunLimitInterval = $script:MockCommand.RunLimitInterval
            SecurityLevel = $script:MockCommand.SecurityLevel
            ShouldLogError = $script:MockCommand.ShouldLogError
            WorkingDirectory = $script:MockCommand.WorkingDirectory
        }

        $script:TestFileScreenTemplateActionReport = [PSObject]@{
            Name = $script:MockFileScreenTemplate.Name
            Type = 'Report'
        }
        $script:TestFileScreenTemplateActionSetReport = $script:TestFileScreenTemplateActionReport.Clone()
        $script:TestFileScreenTemplateActionSetReport += [PSObject]@{
            Ensure = 'Present'
            ReportTypes = $script:MockReport.ReportTypes
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'File Screen template does not exist' {

                Mock Get-FsrmFileScreenTemplate { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw FileScreenTemplateNotFound exception' {
                    $Splat = $script:TestFileScreenTemplateActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenTemplateNotFoundError) -f $Splat.Name,$Splat.Type) `
                        -ArgumentName 'Name'

                    { $Result = Get-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists but action does not' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return absent File Screen template action' {
                    $Splat = $script:TestFileScreenTemplateActionReport.Clone()
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template and action exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return correct File Screen template action' {
                    $Splat = $script:TestFileScreenTemplateActionEmail.Clone()
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
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'File Screen template does not exist' {

                Mock Get-FsrmFileScreenTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock Set-FsrmFileScreenTemplate

                It 'Should throw FileScreenTemplateNotFound exception' {
                    $Splat = $script:TestFileScreenTemplateActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenTemplateNotFoundError) -f $Splat.Name,$Splat.Type) `
                        -ArgumentName 'Name'

                    { Set-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists but action does not' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }
                Mock Set-FsrmFileScreenTemplate

                It 'Should Not Throw exception' {
                    $Splat = $script:TestFileScreenTemplateActionSetEvent.Clone()
                    $Splat.Type = 'Event'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }
                Mock Set-FsrmFileScreenTemplate

                It 'Should Not Throw exception' {
                    $Splat = $script:TestFileScreenTemplateActionSetEmail.Clone()
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action exists but should not' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }
                Mock Set-FsrmFileScreenTemplate

                It 'Should Not Throw exception' {
                    $Splat = $script:TestFileScreenTemplateActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen template does not exist' {

                Mock Get-FsrmFileScreenTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw FileScreenTemplateNotFound exception' {
                    $Splat = $script:TestFileScreenTemplateActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenTemplateNotFoundError) -f $Splat.Name,$Splat.Type) `
                        -ArgumentName 'Name'

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists but action does not' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetReport.Clone()
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and matching action exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return true' {
                    $Splat = $script:TestFileScreenTemplateActionSetEmail.Clone()
                    Test-TargetResource @Splat | Should Be $true
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different Subject exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetEmail.Clone()
                    $Splat.Subject = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different Body exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetEmail.Clone()
                    $Splat.Body = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different Mail BCC exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetEmail.Clone()
                    $Splat.MailBCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different Mail CC exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetEmail.Clone()
                    $Splat.MailCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different Mail To exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetEmail.Clone()
                    $Splat.MailTo = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different Command exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetCommand.Clone()
                    $Splat.Command = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different CommandParameters exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetCommand.Clone()
                    $Splat.CommandParameters = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different KillTimeOut exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetCommand.Clone()
                    $Splat.KillTimeOut = $Splat.KillTimeOut+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different RunLimitInterval exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetCommand.Clone()
                    $Splat.RunLimitInterval = $Splat.RunLimitInterval+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different SecurityLevel exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetCommand.Clone()
                    $Splat.SecurityLevel = 'NetworkService'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different ShouldLogError exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetCommand.Clone()
                    $Splat.ShouldLogError = (-not $Splat.ShouldLogError)
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different WorkingDirectory exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetCommand.Clone()
                    $Splat.WorkingDirectory = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action with different ReportTypes exists' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetReport.Clone()
                    $Splat.ReportTypes = @( 'LeastRecentlyAccessed' )
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and action exists but should not' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplateActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
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
