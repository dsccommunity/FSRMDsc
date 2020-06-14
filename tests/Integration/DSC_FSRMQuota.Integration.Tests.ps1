$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMQuota'

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
                {
                    Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                # Get the Rule details
                $quotaNew = Get-FSRMQuota -Path $quota.Path
                $quota.Path               | Should -Be $quotaNew.Path
                $quota.Description        | Should -Be $quotaNew.Description
                $quota.Size               | Should -Be $quotaNew.Size
                $quota.SoftLimit          | Should -Be $quotaNew.SoftLimit
                (Compare-Object `
                    -ReferenceObject $quota.ThresholdPercentages `
                    -DifferenceObject $quotaNew.Threshold.Percentage).Count | Should -Be 0
                $quota.Disabled           | Should -Be $quotaNew.Disabled
            }

            # Clean up
            Remove-FSRMQuota `
                -Path $quota.Path `
                -Confirm:$false
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
