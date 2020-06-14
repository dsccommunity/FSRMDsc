$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMQuotaTemplateAction'

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
            # Create the File Screen that will be worked with
            New-FSRMQuotaTemplate `
                -Name $quotaTemplate.Name `
                -Description $quotaTemplate.Description `
                -Size $quotaTemplate.Size `
                -Threshold (New-FSRMQuotaThreshold -Percentage $quotaTemplate.ThresholdPercentages[0])

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
                $quotaTemplateNew = Get-FSRMQuotaTemplate -Name $quotaTemplate.Name
                $quotaTemplateNew.Threshold[0].Action[0].Type               | Should -Be $quotaAction.Type
                $quotaTemplateNew.Threshold[0].Action[0].Subject            | Should -Be $quotaAction.Subject
                $quotaTemplateNew.Threshold[0].Action[0].Body               | Should -Be $quotaAction.Body
                $quotaTemplateNew.Threshold[0].Action[0].MailBCC            | Should -Be $quotaAction.MailBCC
                $quotaTemplateNew.Threshold[0].Action[0].MailCC             | Should -Be $quotaAction.MailCC
                $quotaTemplateNew.Threshold[0].Action[0].MailTo             | Should -Be $quotaAction.MailTo
            }

            # Clean up
            Remove-FSRMQuotaTemplate `
                -Name $quotaTemplate.Name `
                -Confirm:$false
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
