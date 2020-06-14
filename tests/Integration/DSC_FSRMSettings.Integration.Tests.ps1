$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMSettings'

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
    Describe "$($script:DSCResourceName) Integration Tests" {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).Config.ps1"
        . $configFile

        Describe "$($script:DSCResourceName)_Integration" {
            # Backup existing Settings
            $settingsOld = Get-FSRMSetting

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

            It 'Should have set the resource and all the parameters should match' {
                # Get the Rule details
                $settingsNew = Get-FSRMSetting
                $settings.SmtpServer               | Should -Be $settingsNew.SmtpServer
                $settings.AdminEmailAddress        | Should -Be $settingsNew.AdminEmailAddress
                $settings.FromEmailAddress         | Should -Be $settingsNew.FromEmailAddress
                $settings.CommandNotificationLimit | Should -Be $settingsNew.CommandNotificationLimit
                $settings.EmailNotificationLimit   | Should -Be $settingsNew.EmailNotificationLimit
                $settings.EventNotificationLimit   | Should -Be $settingsNew.EventNotificationLimit
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
