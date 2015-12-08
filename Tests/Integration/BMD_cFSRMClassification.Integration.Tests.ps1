$DSCModuleName      = 'cFSRM'
$DSCResourceName    = 'BMD_cFSRMClassification'

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
        # Backup existing Classification
        $classificationOld = Get-FSRMClassification
        
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
            # Get the Classification details
            $classificationNew = Get-FSRMClassification
            $classification.Continuous          | Should Be $classificationNew.Continuous
            $classification.ContinuousLog       | Should Be $classificationNew.ContinuousLog
            $classification.ContinuousLogSize   | Should Be $classificationNew.ContinuousLogSize
            (Compare-Object `
                -ReferenceObject $classification.ExcludeNamespace `
                -DifferenceObject $classificationNew.ExcludeNamespace).Count | Should Be 0
            (Compare-Object `
                -ReferenceObject $classification.ScheduleMonthly `
                -DifferenceObject $classificationNew.Schedule.Monthly).Count | Should Be 0
            $classification.ScheduleRunDuration | Should Be $classificationNew.Schedule.RunDuration
            $classification.ScheduleTime        | Should Be $classificationNew.Schedule.Time
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
