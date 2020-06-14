$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMFileScreenTemplateAction'

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
            New-FSRMFileScreenTemplate `
                -Name $fileScreenTemplate.Name `
                -Description $fileScreenTemplate.Description `
                -IncludeGroup $fileScreenTemplate.IncludeGroup

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
                $fileScreenTemplateNew = Get-FSRMFileScreenTemplate -Name $fileScreenTemplate.Name
                $fileScreenTemplateNew.Notification[0].Type               | Should -Be $fileScreenTemplateAction.Type
                $fileScreenTemplateNew.Notification[0].Subject            | Should -Be $fileScreenTemplateAction.Subject
                $fileScreenTemplateNew.Notification[0].Body               | Should -Be $fileScreenTemplateAction.Body
                $fileScreenTemplateNew.Notification[0].MailBCC            | Should -Be $fileScreenTemplateAction.MailBCC
                $fileScreenTemplateNew.Notification[0].MailCC             | Should -Be $fileScreenTemplateAction.MailCC
                $fileScreenTemplateNew.Notification[0].MailTo             | Should -Be $fileScreenTemplateAction.MailTo
            }

            # Clean up
            Remove-FSRMFileScreenTemplate `
                -Name $fileScreenTemplate.Name `
                -Confirm:$false
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
