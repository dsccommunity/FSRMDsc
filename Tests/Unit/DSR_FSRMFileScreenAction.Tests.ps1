$script:DSCModuleName = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileScreenAction'

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
        $script:DSCResourceName = 'DSR_FSRMFileScreenAction'

        # Create the Mock -CommandName Objects that will be used for running tests
        # General purpose Action Mocks
        $script:MockEmail = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Type    = 'Email'
            Subject = '[FileScreen Threshold]% FileScreen threshold exceeded'
            Body    = 'User [Source Io Owner] has exceed the [FileScreen Threshold]% FileScreen threshold for FileScreen on [FileScreen Path] on server [Server]. The FileScreen limit is [FileScreen Limit MB] MB and the current usage is [FileScreen Used MB] MB ([FileScreen Used Percent]% of limit).'
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
            Body      = 'User [Source Io Owner] has exceed the [FileScreen Threshold]% FileScreen threshold for FileScreen on [FileScreen Path] on server [Server]. The FileScreen limit is [FileScreen Limit MB] MB and the current usage is [FileScreen Used MB] MB ([FileScreen Used Percent]% of limit).'
            EventType = 'Warning'
        }

        $script:MockReport = New-CimInstance `
            -ClassName 'MSFT_FSRMAction' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Type        = 'Report'
            ReportTypes = @( 'DuplicateFiles', 'LargeFiles', 'FilesByFileGroup' )
        }

        # FileScreen mocks
        $script:MockFileScreen = New-CimInstance `
            -ClassName 'MSFT_FSRMFileScreen' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
            Path         = $ENV:Temp
            Description  = 'File Screen Templates for Blocking Some Files'
            Ensure       = 'Present'
            Active       = $true
            IncludeGroup = @( 'Audio and Video Files', 'Executable Files', 'Backup Files' )
            Notification = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                $script:MockEmail, $script:MockCommand, $script:MockEvent, $script:MockReport
            )
        }

        $script:TestFileScreenActionEmail = [PSObject]@{
            Path    = $script:MockFileScreen.Path
            Type    = 'Email'
            Verbose = $true
        }

        $script:TestFileScreenActionSetEmail = $script:TestFileScreenActionEmail.Clone()
        $script:TestFileScreenActionSetEmail += [PSObject]@{
            Ensure  = 'Present'
            Subject = $script:MockEmail.Subject
            Body    = $script:MockEmail.Body
            MailBCC = $script:MockEmail.MailBCC
            MailCC  = $script:MockEmail.MailCC
            MailTo  = $script:MockEmail.MailTo
        }

        $script:TestFileScreenActionEvent = [PSObject]@{
            Path    = $script:MockFileScreen.Path
            Type    = 'Event'
            Verbose = $true
        }

        $script:TestFileScreenActionSetEvent = $script:TestFileScreenActionEvent.Clone()
        $script:TestFileScreenActionSetEvent += [PSObject]@{
            Ensure    = 'Present'
            Body      = $script:MockEvent.Body
            EventType = $script:MockEvent.EventType
        }

        $script:TestFileScreenActionCommand = [PSObject]@{
            Path    = $script:MockFileScreen.Path
            Type    = 'Command'
            Verbose = $true
        }

        $script:TestFileScreenActionSetCommand = $script:TestFileScreenActionCommand.Clone()
        $script:TestFileScreenActionSetCommand += [PSObject]@{
            Ensure            = 'Present'
            Command           = $script:MockCommand.Command
            CommandParameters = $script:MockCommand.CommandParameters
            KillTimeOut       = $script:MockCommand.KillTimeOut
            RunLimitInterval  = $script:MockCommand.RunLimitInterval
            SecurityLevel     = $script:MockCommand.SecurityLevel
            ShouldLogError    = $script:MockCommand.ShouldLogError
            WorkingDirectory  = $script:MockCommand.WorkingDirectory
        }

        $script:TestFileScreenActionReport = [PSObject]@{
            Path    = $script:MockFileScreen.Path
            Type    = 'Report'
            Verbose = $true
        }

        $script:TestFileScreenActionSetReport = $script:TestFileScreenActionReport.Clone()
        $script:TestFileScreenActionSetReport += [PSObject]@{
            Ensure      = 'Present'
            ReportTypes = $script:MockReport.ReportTypes
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'File Screen does not exist' {
                Mock -CommandName Get-FsrmFileScreen { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw FileScreenNotFound exception' {
                    $getTargetResourceParameters = $script:TestFileScreenActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenNotFoundError) -f $getTargetResourceParameters.Path) `
                        -ArgumentName 'Path'

                    { $result = Get-TargetResource @getTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists but action does not' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return absent File Screen action' {
                    $getTargetResourceParameters = $script:TestFileScreenActionReport.Clone()
                    $result = Get-TargetResource @getTargetResourceParameters
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen and action exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return correct File Screen action' {
                    $getTargetResourceParameters = $script:TestFileScreenActionEmail.Clone()
                    $result = Get-TargetResource @getTargetResourceParameters
                    $result.Ensure | Should -Be 'Present'
                    $result.Type | Should -Be 'Email'
                    $result.Subject | Should -Be $script:MockEmail.Subject
                    $result.Body | Should -Be $script:MockEmail.Body
                    $result.MailBCC | Should -Be $script:MockEmail.MailBCC
                    $result.MailCC | Should -Be $script:MockEmail.MailCC
                    $result.MailTo | Should -Be $script:MockEmail.MailTo
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'File Screen does not exist' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock -CommandName Set-FsrmFileScreen

                It 'Should throw FileScreenNotFound exception' {
                    $setTargetResourceParameters = $script:TestFileScreenActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenNotFoundError) -f $setTargetResourceParameters.Path) `
                        -ArgumentName 'Path'

                    { Set-TargetResource @setTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists but action does not' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }
                Mock -CommandName Set-FsrmFileScreen

                It 'Should not throw exception' {
                    $setTargetResourceParameters = $script:TestFileScreenActionSetReport.Clone()
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }
                Mock -CommandName Set-FsrmFileScreen

                It 'Should not throw exception' {
                    $setTargetResourceParameters = $script:TestFileScreenActionSetEmail.Clone()
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action exists but should not' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }
                Mock -CommandName Set-FsrmFileScreen

                It 'Should not throw exception' {
                    $setTargetResourceParameters = $script:TestFileScreenActionSetEmail.Clone()
                    $setTargetResourceParameters.Ensure = 'Absent'
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmFileScreen -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen does not exist' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw FileScreenNotFound exception' {
                    $testTargetResourceParameters = $script:TestFileScreenActionEmail.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenNotFoundError) -f $testTargetResourceParameters.Path) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists but action does not' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetReport.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and matching action exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return true' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetEmail.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $true
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Subject exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetEmail.Clone()
                    $testTargetResourceParameters.Subject = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Body exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetEmail.Clone()
                    $testTargetResourceParameters.Body = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Mail BCC exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetEmail.Clone()
                    $testTargetResourceParameters.MailBCC = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Mail CC exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetEmail.Clone()
                    $testTargetResourceParameters.MailCC = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Mail To exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetEmail.Clone()
                    $testTargetResourceParameters.MailTo = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different Command exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetCommand.Clone()
                    $testTargetResourceParameters.Command = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different CommandParameters exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetCommand.Clone()
                    $testTargetResourceParameters.CommandParameters = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different KillTimeOut exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetCommand.Clone()
                    $testTargetResourceParameters.KillTimeOut = $testTargetResourceParameters.KillTimeOut + 1
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different RunLimitInterval exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetCommand.Clone()
                    $testTargetResourceParameters.RunLimitInterval = $testTargetResourceParameters.RunLimitInterval + 1
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different SecurityLevel exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetCommand.Clone()
                    $testTargetResourceParameters.SecurityLevel = 'NetworkService'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different ShouldLogError exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetCommand.Clone()
                    $testTargetResourceParameters.ShouldLogError = (-not $testTargetResourceParameters.ShouldLogError)
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different WorkingDirectory exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetCommand.Clone()
                    $testTargetResourceParameters.WorkingDirectory = 'Different'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action with different ReportTypes exists' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetReport.Clone()
                    $testTargetResourceParameters.ReportTypes = @( 'LeastRecentlyAccessed' )
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and action exists but should not' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenActionSetEmail.Clone()
                    $testTargetResourceParameters.Ensure = 'Absent'
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
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
