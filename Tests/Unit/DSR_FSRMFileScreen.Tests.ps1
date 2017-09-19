$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileScreen'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Unit Test Template Version: 1.1.0
[System.String] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\FSRMDsc'
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion HEADER


# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $script:DSCResourceName {
        $script:DSCResourceName = 'DSR_FSRMFileScreen'

        # Create the Mock Objects that will be used for running tests
        $script:TestFileScreen = [PSObject]@{
            Path = $ENV:Temp
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            Active = $false
            IncludeGroup = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
            Template = 'Block Some Files'
            MatchesTemplate = $false
        }

        $script:MockFileScreen = [PSObject]@{
            Path = $script:TestFileScreen.Path
            Description = $script:TestFileScreen.Description
            Active = $script:TestFileScreen.Active
            IncludeGroup = $script:TestFileScreen.IncludeGroup.Clone()
            Template = $script:TestFileScreen.Template
            MatchesTemplate = $script:TestFileScreen.MatchesTemplate
        }
        $script:MockFileScreenMatch= $script:MockFileScreen.Clone()
        $script:MockFileScreenMatch.MatchesTemplate = $true

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'No File Screens exist' {

                Mock Get-FsrmFileScreen

                It 'Should return absent File Screen' {
                    $Result = Get-TargetResource `
                        -Path $script:TestFileScreen.Path
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'Requested File Screen does exist' {

                Mock Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return correct File Screen' {
                    $Result = Get-TargetResource `
                        -Path $script:TestFileScreen.Path
                    $Result.Ensure | Should Be 'Present'
                    $Result.Path | Should Be $script:TestFileScreen.Path
                    $Result.Description | Should Be $script:TestFileScreen.Description
                    $Result.IncludeGroup | Should Be $script:TestFileScreen.IncludeGroup
                    $Result.Active | Should Be $script:TestFileScreen.Active
                    $Result.Template | Should Be $script:TestFileScreen.Template
                    $Result.MatchesTemplate | Should Be $script:TestFileScreen.MatchesTemplate
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'File Screen does not exist but should' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmFileScreen
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists and should but has a different Description' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists and should but has a different Active' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Active = (-not $Splat.Active)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists and should but has a different IncludeGroup' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.IncludeGroup = @( 'Different' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists and but should not' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen does not exist and should not' {

                Mock Assert-ResourcePropertiesValid
                Mock Get-FsrmFileScreen
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen path does not exist' {
                Mock Get-FsrmFileScreenTemplate
                Mock Test-Path -MockWith { $false }

                It 'Should throw an FileScreenPathDoesNotExistError exception' {
                    $Splat = $script:TestFileScreen.Clone()

                    $errorId = 'FileScreenPathDoesNotExistError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenPathDoesNotExistError) -f $Splat.Path
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'FileScreen template does not exist' {
                Mock Get-FSRMFileScreenTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw an FileScreenTemplateNotFoundError exception' {
                    $Splat = $script:TestFileScreen.Clone()

                    $errorId = 'FileScreenTemplateNotFoundError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenTemplateNotFoundError) -f $Splat.Path,$Splat.Template
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'File Screen template not specified but MatchesTemplate is true' {
                It 'Should throw an FileScreenTemplateEmptyError exception' {
                    $Splat = $script:TestFileScreen.Clone()
                    $Splat.MatchesTemplate = $True
                    $Splat.Template = ''

                    $errorId = 'FileScreenTemplateEmptyError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenTemplateEmptyError) -f $Splat.Path
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'File Screen does not exist but should' {

                Mock Get-FsrmFileScreen
                Mock Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    $Splat = $script:TestFileScreen.Clone()
                    Test-TargetResource @Splat | Should Be $False

                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should but has a different Description' {

                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should but has a different Active' {

                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Active = (-not $Splat.Active)
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should but has a different IncludeGroup' {

                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.IncludeGroup = @( 'Different' )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should but has a different Template' {

                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Template = 'Block Image Files'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should and MatchesTemplate is set but does not match' {

                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.MatchesTemplate = $true
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should and MatchesTemplate is set and does match' {

                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreenMatch }
                Mock Get-FsrmFileScreenTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.MatchesTemplate = $true
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should and all parameters match' {

                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and but should not' {

                Mock Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen does not exist and should not' {

                Mock Get-FsrmFileScreen
                Mock Get-FsrmFileScreenTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
        }
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
