$DSCModuleName      = 'cFSRM'
$DSCResourceName    = 'BMD_cFSRMFileScreenTemplateAction'

#region HEADER
if ( (-not (Test-Path -Path '.\DSCResource.Tests\')) -or `
     (-not (Test-Path -Path '.\DSCResource.Tests\TestHelper.psm1')) )
{
    & git @('clone','https://github.com/PlagueHO/DscResource.Tests.git')
}
Import-Module .\DSCResource.Tests\TestHelper.psm1 -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $DSCModuleName `
    -DSCResourceName $DSCResourceName `
    -TestType Integration 
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$DSCResourceName.config.ps1"
    . $ConfigFile

    Describe "$($DSCResourceName)_Integration" {
        # Create the File Screen that will be worked with 
        New-FSRMFileScreenTemplate `
            -Name $fileScreenTemplate.Name `
            -Description $fileScreen.Description `
            -IncludeGroup $fileScreen.IncludeGroup `
            -Template $fileScreen.Template
            
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($DSCResourceName)_Config -OutputPath `$TestEnvironment.WorkingFolder"
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            # Get the Rule details
            $fileScreenTemplateNew = Get-FSRMFileScreenTemplate -Name $fileScreenTemplate.Name
            $fileScreenTemplateNew.Notification[1].Type               | Should Be $fileScreenAction.Type
            $fileScreenTemplateNew.Notification[1].Subject            | Should Be $fileScreenAction.Subject
            $fileScreenTemplateNew.Notification[1].Body               | Should Be $fileScreenAction.Body
            $fileScreenTemplateNew.Notification[1].MailBCC            | Should Be $fileScreenAction.MailBCC
            $fileScreenTemplateNew.Notification[1].MailCC             | Should Be $fileScreenAction.MailCC
            $fileScreenTemplateNew.Notification[1].MailTo             | Should Be $fileScreenAction.MailTo
        }
        
        # Clean up
        Remove-FSRMFileScreenTemplate `
            -Path $fileScreenTemplate.Name `
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
