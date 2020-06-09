$script:DSCModuleName      = 'FSRMDsc'
$script:DSCResourceName    = 'DSC_FSRMClassification'

#region HEADER
# Integration Test Template Version: 1.1.1
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
Import-Module (Join-Path -Path $script:moduleRoot -ChildPath "$($script:DSCModuleName).psd1") -Force
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
        # Backup existing Classification
        $classificationOld = Get-FSRMClassification

        #region DEFAULT TESTS
        It 'Should compile and apply the MOF without throwing' {
            {
                & "$($script:DSCResourceName)_Config" -OutputPath $TestDrive
                Start-DscConfiguration `
                    -Path $TestDrive `
                    -ComputerName localhost `
                    -Wait `
                    -Verbose `
                    -Force `
                    -ErrorAction Stop
            } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            # Get the Classification details
            $classificationNew = Get-FSRMClassification
            $classification.Continuous          | Should -Be $classificationNew.Continuous
            $classification.ContinuousLog       | Should -Be $classificationNew.ContinuousLog
            $classification.ContinuousLogSize   | Should -Be $classificationNew.ContinuousLogSize
            (Compare-Object `
                -ReferenceObject $classification.ExcludeNamespace `
                -DifferenceObject $classificationNew.ExcludeNamespace).Count | Should -Be 0
            (Compare-Object `
                -ReferenceObject $classification.ScheduleMonthly `
                -DifferenceObject $classificationNew.Schedule.Monthly).Count | Should -Be 0
            $classification.ScheduleRunDuration | Should -Be $classificationNew.Schedule.RunDuration
            $classification.ScheduleTime        | Should -Be $classificationNew.Schedule.Time
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
