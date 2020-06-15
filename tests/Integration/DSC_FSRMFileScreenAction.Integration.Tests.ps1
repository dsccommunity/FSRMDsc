$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMFileScreenAction'

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
            New-FSRMFileScreen `
                -Path $fileScreen.Path `
                -Description $fileScreen.Description `
                -IncludeGroup $fileScreen.IncludeGroup `
                -Template $fileScreen.Template

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
                $fileScreenNew = Get-FSRMFileScreen -Path $fileScreen.Path
                $fileScreenNew.Notification[1].Type               | Should -Be $fileScreenAction.Type
                $fileScreenNew.Notification[1].Subject            | Should -Be $fileScreenAction.Subject
                $fileScreenNew.Notification[1].Body               | Should -Be $fileScreenAction.Body
                $fileScreenNew.Notification[1].MailBCC            | Should -Be $fileScreenAction.MailBCC
                $fileScreenNew.Notification[1].MailCC             | Should -Be $fileScreenAction.MailCC
                $fileScreenNew.Notification[1].MailTo             | Should -Be $fileScreenAction.MailTo
            }

            # Clean up
            Remove-FSRMFileScreen `
                -Path $fileScreen.Path `
                -Confirm:$false
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
