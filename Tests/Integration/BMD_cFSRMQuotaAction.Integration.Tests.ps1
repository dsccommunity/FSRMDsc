$DSCModuleName      = 'cFSRM'
$DSCResourceName    = 'BMD_cFSRMQuotaAction'

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
        New-FSRMQuota `
            Path = $quota.Path
            Description = $quota.Path
            Size = $quota.Path
            SoftLimit = $quota.Path
            Disabled = $false
            Threshold = (New-FSRMQuotaThreshold -Percentage $quota.ThresholdPercentages[0])
            
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
            $quotaNew = Get-FSRMQuota -Path $quota.Path
            $quotaNew.Threshold[0].Action[0].Type               | Should Be $quotaAction.Type
            $quotaNew.Threshold[0].Action[0].Subject            | Should Be $quotaAction.Subject
            $quotaNew.Threshold[0].Action[0].Body               | Should Be $quotaAction.Body
            $quotaNew.Threshold[0].Action[0].MailBCC            | Should Be $quotaAction.MailBCC
            $quotaNew.Threshold[0].Action[0].MailCC             | Should Be $quotaAction.MailCC
            $quotaNew.Threshold[0].Action[0].MailTo             | Should Be $quotaAction.MailTo
        }
        
        # Clean up
        Remove-FSRMQuota `
            -Path $quota.Path `
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
