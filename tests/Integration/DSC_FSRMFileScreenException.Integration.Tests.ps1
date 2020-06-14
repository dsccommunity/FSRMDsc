$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMFileScreenException'

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
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -throw
            }

            It 'Should have set the resource and all the parameters should match' {
                # Get the Rule details
                $fileScreenExceptionNew = Get-FSRMFileScreenException -Path $fileScreenException.Path
                $fileScreenException.Path               | Should -Be $fileScreenExceptionNew.Path
                $fileScreenException.Description        | Should -Be $fileScreenExceptionNew.Description
                $fileScreenException.IncludeGroup       | Should -Be $fileScreenExceptionNew.IncludeGroup
            }

            # Clean up
            Remove-FSRMFileScreenException `
                -Path $fileScreenException.Path `
                -Confirm:$false
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
