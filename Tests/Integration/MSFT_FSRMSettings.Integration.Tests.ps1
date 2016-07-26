$Global:DSCModuleName      = 'FSRMDsc'
$Global:DSCResourceName    = 'MSFT_FSRMSettings'

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
    -TestType Integration
#endregion HEADER

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Global:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($Global:DSCResourceName)_Integration" {
        # Backup existing Settings
        $settingsOld = Get-FSRMSetting

        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($Global:DSCResourceName)_Config -OutputPath `$TestEnvironment.WorkingFolder"
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            # Get the Rule details
            $settingsNew = Get-FSRMSetting
            $settings.SmtpServer               | Should Be $settingsNew.SmtpServer
            $settings.AdminEmailAddress        | Should Be $settingsNew.AdminEmailAddress
            $settings.FromEmailAddress         | Should Be $settingsNew.FromEmailAddress
            $settings.CommandNotificationLimit | Should Be $settingsNew.CommandNotificationLimit
            $settings.EmailNotificationLimit   | Should Be $settingsNew.EmailNotificationLimit
            $settings.EventNotificationLimit   | Should Be $settingsNew.EventNotificationLimit
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