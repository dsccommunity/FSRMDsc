$Global:DSCModuleName      = 'FSRMDsc'
$Global:DSCResourceName    = 'MSFT_FSRMFileScreenAction'

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
        # Create the File Screen that will be worked with
        New-FSRMFileScreen `
            -Path $fileScreen.Path `
            -Description $fileScreen.Description `
            -IncludeGroup $fileScreen.IncludeGroup `
            -Template $fileScreen.Template

        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                & "$($Global:DSCResourceName)_Config" -OutputPath $TestEnvironment.WorkingFolder
                Start-DscConfiguration `
                    -Path $TestEnvironment.WorkingFolder `
                    -ComputerName localhost `
                    -Wait `
                    -Verbose `
                    -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            # Get the Rule details
            $fileScreenNew = Get-FSRMFileScreen -Path $fileScreen.Path
            $fileScreenNew.Notification[1].Type               | Should Be $fileScreenAction.Type
            $fileScreenNew.Notification[1].Subject            | Should Be $fileScreenAction.Subject
            $fileScreenNew.Notification[1].Body               | Should Be $fileScreenAction.Body
            $fileScreenNew.Notification[1].MailBCC            | Should Be $fileScreenAction.MailBCC
            $fileScreenNew.Notification[1].MailCC             | Should Be $fileScreenAction.MailCC
            $fileScreenNew.Notification[1].MailTo             | Should Be $fileScreenAction.MailTo
        }

        # Clean up
        Remove-FSRMFileScreen `
            -Path $fileScreen.Path `
            -Confirm:$false
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
