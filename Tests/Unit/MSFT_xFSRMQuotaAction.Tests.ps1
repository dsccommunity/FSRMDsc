$Global:DSCModuleName   = 'xFSRM'
$Global:DSCResourceName = 'MSFT_xFSRMQuotaAction'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

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
        
        # Quota mocks
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
    
        # Quota mocks
        $Global:MockQuota = New-CimInstance `
            -ClassName 'MSFT_FSRMQuota' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Path = 'c:\users'
                Description = '5 GB Hard Limit'
                Ensure = 'Present'
                Size = 5GB
                SoftLimit = $False
                Threshold = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                    $Global:MockThreshold1, $Global:MockThreshold2
                )
                Disabled = $False
                Template = '5 GB Limit'
            }
    
        $Global:TestQuotaActionEmail = [PSObject]@{
            Path = $Global:MockQuota.Path
            Percentage = $Global:MockQuota.Threshold[0].Percentage
            Type = 'Email'
        }
        $Global:TestQuotaActionSetEmail = $Global:TestQuotaActionEmail.Clone()
        $Global:TestQuotaActionSetEmail += [PSObject]@{
            Ensure = 'Present'
            Subject = $Global:MockEmail.Subject
            Body = $Global:MockEmail.Body
            MailBCC = $Global:MockEmail.MailBCC
            MailCC = $Global:MockEmail.MailCC
            MailTo = $Global:MockEmail.MailTo
        }
    
        $Global:TestQuotaActionEvent = [PSObject]@{
            Path = $Global:MockQuota.Path
            Percentage = $Global:MockQuota.Threshold[0].Percentage
            Type = 'Event'
        }
        $Global:TestQuotaActionSetEvent = $Global:TestQuotaActionEvent.Clone()
        $Global:TestQuotaActionSetEvent += [PSObject]@{
            Ensure = 'Present'
            Body = $Global:MockEvent.Body
            EventType = $Global:MockEvent.EventType
        }
    
        $Global:TestQuotaActionCommand = [PSObject]@{
            Path = $Global:MockQuota.Path
            Percentage = $Global:MockQuota.Threshold[0].Percentage
            Type = 'Command'
        }
        $Global:TestQuotaActionSetCommand = $Global:TestQuotaActionCommand.Clone()
        $Global:TestQuotaActionSetCommand += [PSObject]@{
            Ensure = 'Present'
            Command = $Global:MockCommand.Command
            CommandParameters = $Global:MockCommand.CommandParameters
            KillTimeOut = $Global:MockCommand.KillTimeOut
            RunLimitInterval = $Global:MockCommand.RunLimitInterval
            SecurityLevel = $Global:MockCommand.SecurityLevel
            ShouldLogError = $Global:MockCommand.ShouldLogError
            WorkingDirectory = $Global:MockCommand.WorkingDirectory
        }
    
        $Global:TestQuotaActionReport = [PSObject]@{
            Path = $Global:MockQuota.Path
            Percentage = $Global:MockQuota.Threshold[0].Percentage
            Type = 'Report'
        }
        $Global:TestQuotaActionSetReport = $Global:TestQuotaActionReport.Clone()
        $Global:TestQuotaActionSetReport += [PSObject]@{
            Ensure = 'Present'
            ReportTypes = $Global:MockReport.ReportTypes
        }
    
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
    
            Context 'Quota does not exist' {
                
                Mock Get-FsrmQuota { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
    
                It 'should throw QuotaNotFound exception' {
                    $Splat = $Global:TestQuotaActionEmail.Clone()
                    $errorId = 'QuotaNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaNotFoundError) `
                        -f $Splat.Path,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { $Result = Get-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists but threshold does not' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
                        
                It 'should throw QuotaNotFound exception' {
                    $Splat = $Global:TestQuotaActionEmail.Clone()
                    $Splat.Percentage = 99
                    $errorId = 'QuotahresholdNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaThresholdNotFoundError) `
                        -f $Splat.Path,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { $Result = Get-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists but action does not' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return absent quota action' {
                    $Splat = $Global:TestQuotaActionEvent.Clone()
                    $Result = Get-TargetResource @Splat
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota and action exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return correct quota action' {
                    $Splat = $Global:TestQuotaActionEmail.Clone()
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
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
        }
    
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
    
            Context 'Quota does not exist' {
                
                Mock Get-FsrmQuota -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                Mock Set-FsrmQuota
    
                It 'should throw QuotaNotFound exception' {
                    $Splat = $Global:TestQuotaActionEmail.Clone()
                    $errorId = 'QuotaNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaNotFoundError) `
                        -f $Splat.Path,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Set-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 0
                }
            }
    
            Context 'Quota exists but threshold does not' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
                Mock Set-FsrmQuota
    
                It 'should throw QuotaNotFound exception' {
                    $Splat = $Global:TestQuotaActionEmail.Clone()
                    $Splat.Percentage = 99
                    $errorId = 'QuotaThresholdNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaThresholdNotFoundError) `
                        -f $Splat.Path,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Set-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 0
                }
            }
    
            Context 'Quota exists but action does not' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
                Mock Set-FsrmQuota
    
                It 'should not throw exception' {
                    $Splat = $Global:TestQuotaActionSetEvent.Clone()
                    $Splat.Type = 'Event'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
                Mock Set-FsrmQuota
    
                It 'should not throw exception' {
                    $Splat = $Global:TestQuotaActionSetEmail.Clone()
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action exists but should not' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
                Mock Set-FsrmQuota
    
                It 'should not throw exception' {
                    $Splat = $Global:TestQuotaActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    { Set-TargetResource @Splat } | Should Not Throw
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuota -Exactly 1
                }
            }
        }
    
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'Quota does not exist' {
                
                Mock Get-FsrmQuota -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
    
                It 'should throw QuotaNotFound exception' {
                    $Splat = $Global:TestQuotaActionEmail.Clone()
                    $errorId = 'QuotaNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaNotFoundError) `
                        -f $Splat.Path,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists but threshold does not' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should throw QuotaNotFound exception' {
                    $Splat = $Global:TestQuotaActionEmail.Clone()
                    $Splat.Percentage = 99
                    $errorId = 'QuotaThresholdNotFound'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.QuotaThresholdNotFoundError) `
                        -f $Splat.Path,$Splat.Percentage,$Splat.Type
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists but action does not' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetEvent.Clone()
                    $Splat.Type = 'Event'
                    Test-TargetResource @Splat | Should Be $False
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and matching action exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return true' {
                    $Splat = $Global:TestQuotaActionSetEmail.Clone()
                    Test-TargetResource @Splat | Should Be $true
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different Subject exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetEmail.Clone()
                    $Splat.Subject = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different Body exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetEmail.Clone()
                    $Splat.Body = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different Mail BCC exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetEmail.Clone()
                    $Splat.MailBCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different Mail CC exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetEmail.Clone()
                    $Splat.MailCC = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different Mail To exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetEmail.Clone()
                    $Splat.MailTo = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different Command exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetCommand.Clone()
                    $Splat.Command = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different CommandParameters exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetCommand.Clone()
                    $Splat.CommandParameters = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different KillTimeOut exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetCommand.Clone()
                    $Splat.KillTimeOut = $Splat.KillTimeOut+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different RunLimitInterval exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetCommand.Clone()
                    $Splat.RunLimitInterval = $Splat.RunLimitInterval+1
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different SecurityLevel exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetCommand.Clone()
                    $Splat.SecurityLevel = 'NetworkService'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different ShouldLogError exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetCommand.Clone()
                    $Splat.ShouldLogError = (-not $Splat.ShouldLogError)
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different WorkingDirectory exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetCommand.Clone()
                    $Splat.WorkingDirectory = 'Different'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action with different ReportTypes exists' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetReport.Clone()
                    $Splat.ReportTypes = @( 'LeastRecentlyAccessed' )
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuota -Exactly 1
                }
            }
    
            Context 'Quota exists and action exists but should not' {
                
                Mock Get-FsrmQuota -MockWith { return @($Global:MockQuota) }
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaActionSetEmail.Clone()
                    $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $false
                }
                It 'should call the expected mocks' {
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
