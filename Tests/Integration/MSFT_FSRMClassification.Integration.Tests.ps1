$Global:DSCModuleName      = 'FSRMDsc'
$Global:DSCResourceName    = 'MSFT_FSRMClassification'

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
        # Backup existing Classification
        $classificationOld = Get-FSRMClassification

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
