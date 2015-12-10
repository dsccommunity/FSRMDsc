$DSCModuleName      = 'cFSRM'
$DSCResourceName    = 'BMD_cFSRMQuotaTemplate'

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
            $quotaTemplateNew = Get-FSRMQuotaTemplate -Path $quotaTemplate.Path
            $quotaTemplate.Name               | Should Be $quotaTemplateNew.Path
            $quotaTemplate.Description        | Should Be $quotaTemplateNew.Description
            $quotaTemplate.Size               | Should Be $quotaTemplateNew.Size
            $quotaTemplate.SoftLimit          | Should Be $quotaTemplateNew.SoftLimit
            (Compare-Object `
                -ReferenceObject $quotaTemplate.ThresholdPercentages `
                -DifferenceObject $quotaTemplateNew.Threshold.Percentage).Count | Should Be 0
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
