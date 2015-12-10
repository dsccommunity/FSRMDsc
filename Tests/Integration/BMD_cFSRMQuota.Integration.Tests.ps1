$DSCModuleName      = 'cFSRM'
$DSCResourceName    = 'BMD_cFSRMFileScreen'

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
            $quotaNew = Get-FSRMQuota -Path $quota.Path
            Size = $quota.Size
            SoftLimit = $quota.SoftLimit
            ThresholdPercentages = $quota.ThresholdPercentages
            Disabled = $quota.Disabled

            $quota.Path               | Should Be $quotaNew.Path
            $quota.Description        | Should Be $quotaNew.Description
            $quota.Size               | Should Be $quotaNew.Size
            $quota.SoftLimit          | Should Be $quotaNew.SoftLimit
            (Compare-Object `
                -ReferenceObject $quota.ThresholdPercentages `
                -DifferenceObject $quotaNew.ThresholdPercentages.Percentage).Count | Should Be 0
            $quota.Disabled           | Should Be $quotaNew.Disabled            
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
