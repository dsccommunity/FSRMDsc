$script:DSCModuleName      = 'FSRMDsc'
$script:DSCResourceName    = 'MSFT_FSRMQuotaTemplateAction'

#region HEADER
# Integration Test Template Version: 1.1.1
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($script:DSCResourceName)_Integration" {
        # Create the File Screen that will be worked with
        New-FSRMQuotaTemplate `
            -Name $quotaTemplate.Name `
            -Description $quotaTemplate.Description `
            -Size $quotaTemplate.Size `
            -Threshold (New-FSRMQuotaThreshold -Percentage $quotaTemplate.ThresholdPercentages[0])

        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                & "$($script:DSCResourceName)_Config" -OutputPath $TestEnvironment.WorkingFolder
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
            $quotaTemplateNew = Get-FSRMQuotaTemplate -Name $quotaTemplate.Name
            $quotaTemplateNew.Threshold[0].Action[0].Type               | Should Be $quotaAction.Type
            $quotaTemplateNew.Threshold[0].Action[0].Subject            | Should Be $quotaAction.Subject
            $quotaTemplateNew.Threshold[0].Action[0].Body               | Should Be $quotaAction.Body
            $quotaTemplateNew.Threshold[0].Action[0].MailBCC            | Should Be $quotaAction.MailBCC
            $quotaTemplateNew.Threshold[0].Action[0].MailCC             | Should Be $quotaAction.MailCC
            $quotaTemplateNew.Threshold[0].Action[0].MailTo             | Should Be $quotaAction.MailTo
        }

        # Clean up
        Remove-FSRMQuotaTemplate `
            -Name $quotaTemplate.Name `
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
