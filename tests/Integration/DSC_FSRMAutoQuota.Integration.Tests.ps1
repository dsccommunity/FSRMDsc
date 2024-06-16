$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMAutoQuota'

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

if (-not (Test-FsrmEnvironment -Verbose)) {
    throw 'FSRM environment is not ready for integration testing.'
}

try
{
    Describe "$($script:DSCResourceName) Integration Tests" {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).Config.ps1"
        . $configFile

        Describe "$($script:dscResourceName)_Integration" {
            $quotaTemplateForTesting = $quotaTemplates | Select-Object -First 1

            $configData = @{
                AllNodes = @(
                    @{
                        NodeName = 'localhost'
                        Path     = [System.String] $TestDrive
                        Ensure   = 'Present'
                        Disabled = $false
                        Template = ($quotaTemplateForTesting).Name
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
                $current.Path     | Should -BeExactly $configData.AllNodes[0].Path
                $current.Ensure   | Should -BeExactly $configData.AllNodes[0].Ensure
                $current.Disabled | Should -Be $configData.AllNodes[0].Disabled
                $current.Template | Should -BeExactly $configData.AllNodes[0].Template
            }

            Remove-FSRMAutoQuota -Path $configData.AllNodes[0].Path -Confirm:$false
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
