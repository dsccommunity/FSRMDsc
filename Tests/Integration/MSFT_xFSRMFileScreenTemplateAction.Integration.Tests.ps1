$Global:DSCModuleName      = 'xFSRM'
$Global:DSCResourceName    = 'MSFT_xFSRMFileScreenTemplateAction'

#region HEADER
if ( (-not (Test-Path -Path '.\DSCResource.Tests\')) -or `
     (-not (Test-Path -Path '.\DSCResource.Tests\TestHelper.psm1')) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git')
}
else
{
    & git @('-C',(Join-Path -Path (Get-Location) -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module .\DSCResource.Tests\TestHelper.psm1 -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Integration 
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Global:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($Global:DSCResourceName)_Integration" {
        # Create the File Screen that will be worked with 
        New-FSRMFileScreenTemplate `
            -Name $fileScreenTemplate.Name `
            -Description $fileScreenTemplate.Description `
            -IncludeGroup $fileScreenTemplate.IncludeGroup
            
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
            $fileScreenTemplateNew = Get-FSRMFileScreenTemplate -Name $fileScreenTemplate.Name
            $fileScreenTemplateNew.Notification[0].Type               | Should Be $fileScreenTemplateAction.Type
            $fileScreenTemplateNew.Notification[0].Subject            | Should Be $fileScreenTemplateAction.Subject
            $fileScreenTemplateNew.Notification[0].Body               | Should Be $fileScreenTemplateAction.Body
            $fileScreenTemplateNew.Notification[0].MailBCC            | Should Be $fileScreenTemplateAction.MailBCC
            $fileScreenTemplateNew.Notification[0].MailCC             | Should Be $fileScreenTemplateAction.MailCC
            $fileScreenTemplateNew.Notification[0].MailTo             | Should Be $fileScreenTemplateAction.MailTo
        }
        
        # Clean up
        Remove-FSRMFileScreenTemplate `
            -Name $fileScreenTemplate.Name `
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
