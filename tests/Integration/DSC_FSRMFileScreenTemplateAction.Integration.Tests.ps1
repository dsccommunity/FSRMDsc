$script:DSCModuleName      = 'FSRMDsc'
$script:DSCResourceName    = 'DSC_FSRMFileScreenTemplateAction'

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
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

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
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
