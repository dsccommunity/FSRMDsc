$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMClassification'

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

try
{
    Describe 'FSRMAutoQuota Integration Tests' {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).Config.ps1"
        . $configFile

        Describe "$($script:dscResourceName)_Integration" {
            $configData = @{
                AllNodes = @(
                    @{
                        NodeName            = 'localhost'
                        Id                  = 'Default'
                        Continuous          = $false
                        ContinuousLog       = $false
                        ContinuousLogSize   = 2048
                        ExcludeNamespace    = @('[AllVolumes]\$Extend /','[AllVolumes]\System Volume Information /s')
                        ScheduleMonthly     = @( 12,13 )
                        ScheduleRunDuration = 10
                        ScheduleTime        = '13:00'
                    }
                )
            }

            It 'Should compile and apply the MOF without throwing' {
                {
                    & "$($script:dscResourceName)_Config" `
                        -OutputPath $TestDrive `
                        -ConfigurationData $configData

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $current = Get-DscConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq "$($script:dscResourceName)_Config"
                }
                $current.Continuous          | Should -Be $configData.AllNodes[0].Continuous
                $current.ContinuousLog       | Should -Be $configData.AllNodes[0].ContinuousLog
                $current.ContinuousLogSize   | Should -Be $configData.AllNodes[0].ContinuousLogSize
                (Compare-Object `
                    -ReferenceObject $current.ExcludeNamespace `
                    -DifferenceObject $configData.AllNodes[0].ExcludeNamespace).Count | Should -Be 0
                (Compare-Object `
                    -ReferenceObject $current.ScheduleMonthly `
                    -DifferenceObject $configData.AllNodes[0].Schedule.Monthly).Count | Should -Be 0
                $current.ScheduleRunDuration | Should -Be $configData.AllNodes[0].Schedule.RunDuration
                $current.ScheduleTime        | Should -Be $configData.AllNodes[0].Schedule.Time
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
