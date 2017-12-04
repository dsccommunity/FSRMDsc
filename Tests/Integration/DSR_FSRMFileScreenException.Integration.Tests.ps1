$script:DSCModuleName      = 'FSRMDsc'
$script:DSCResourceName    = 'DSR_FSRMFileScreenException'

#region HEADER
# Integration Test Template Version: 1.1.1
[System.String] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\FSRMDsc'

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
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($script:DSCResourceName)_Integration" {
        # Create the File Screen that will be worked with
        New-FSRMFileScreen `
            -Path $fileScreen.Path `
            -Description $fileScreen.Description `
            -IncludeGroup $fileScreen.IncludeGroup `
            -Template $fileScreen.Template

        #region DEFAULT TESTS
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
        #endregion

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
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
