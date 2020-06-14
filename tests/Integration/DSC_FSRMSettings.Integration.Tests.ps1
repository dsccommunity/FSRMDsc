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
            $configData = @{
                AllNodes = @(
                    @{
                        NodeName                 = 'localhost'
                        SmtpServer               = 'smtp.contoso.com'
                        AdminEmailAddress        = 'admin@contoso.com'
                        FromEmailAddress         = 'fsrm@contoso.com'
                        CommandNotificationLimit = 10
                        EmailNotificationLimit   = 20
                        EventNotificationLimit   = 30
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
                $current.SmtpServer               | Should -Be $configData.AllNodes[0].SmtpServer
                $current.AdminEmailAddress        | Should -Be $configData.AllNodes[0].AdminEmailAddress
                $current.FromEmailAddress         | Should -Be $configData.AllNodes[0].FromEmailAddress
                $current.CommandNotificationLimit | Should -Be $configData.AllNodes[0].CommandNotificationLimit
                $current.EmailNotificationLimit   | Should -Be $configData.AllNodes[0].EmailNotificationLimit
                $current.EventNotificationLimit   | Should -Be $configData.AllNodes[0].EventNotificationLimit
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
