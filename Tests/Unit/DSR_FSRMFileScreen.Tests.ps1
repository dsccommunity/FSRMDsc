$script:DSCModuleName = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileScreen'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Unit Test Template Version: 1.1.0
[System.String] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\FSRMDsc'
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
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

        # Create the Mock -CommandName Objects that will be used for running tests
        $script:TestFileScreen = [PSObject]@{
            Path            = $ENV:Temp
            Description     = 'File Screen for Blocking Some Files'
            Ensure          = 'Present'
            Active          = $false
            IncludeGroup    = [System.Collections.ArrayList]@( 'Audio and Video Files', 'Executable Files', 'Backup Files' )
            Template        = 'Block Some Files'
            MatchesTemplate = $false
            Verbose         = $true
        }

        $script:MockFileScreen = [PSObject]@{
            Path            = $script:TestFileScreen.Path
            Description     = $script:TestFileScreen.Description
            Active          = $script:TestFileScreen.Active
            IncludeGroup    = $script:TestFileScreen.IncludeGroup.Clone()
            Template        = $script:TestFileScreen.Template
            MatchesTemplate = $script:TestFileScreen.MatchesTemplate
        }

        $script:MockFileScreenMatch = $script:MockFileScreen.Clone()
        $script:MockFileScreenMatch.MatchesTemplate = $true

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'No File Screens exist' {
                Mock -CommandName Get-FsrmFileScreen

                It 'Should return absent File Screen' {
                    $result = Get-TargetResource -Path $script:TestFileScreen.Path -Verbose
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'Requested File Screen does exist' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { return @($script:MockFileScreen) }

                It 'Should return correct File Screen' {
                    $result = Get-TargetResource -Path $script:TestFileScreen.Path -Verbose
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $script:TestFileScreen.Path
                    $result.Description | Should -Be $script:TestFileScreen.Description
                    $result.IncludeGroup | Should -Be $script:TestFileScreen.IncludeGroup
                    $result.Active | Should -Be $script:TestFileScreen.Active
                    $result.Template | Should -Be $script:TestFileScreen.Template
                    $result.MatchesTemplate | Should -Be $script:TestFileScreen.MatchesTemplate
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'File Screen does not exist but should' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmFileScreen
                Mock -CommandName New-FsrmFileScreen
                Mock -CommandName Set-FsrmFileScreen
                Mock -CommandName Remove-FsrmFileScreen

                It 'Should not throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists and should but has a different Description' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName New-FsrmFileScreen
                Mock -CommandName Set-FsrmFileScreen
                Mock -CommandName Remove-FsrmFileScreen

                It 'Should not throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists and should but has a different Active' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName New-FsrmFileScreen
                Mock -CommandName Set-FsrmFileScreen
                Mock -CommandName Remove-FsrmFileScreen

                It 'Should not throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Active = (-not $Splat.Active)
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists and should but has a different IncludeGroup' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName New-FsrmFileScreen
                Mock -CommandName Set-FsrmFileScreen
                Mock -CommandName Remove-FsrmFileScreen

                It 'Should not throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.IncludeGroup = @( 'Different' )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileScreen -Exactly 0
                }
            }

            Context 'File Screen exists and but should not' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName New-FsrmFileScreen
                Mock -CommandName Set-FsrmFileScreen
                Mock -CommandName Remove-FsrmFileScreen

                It 'Should not throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen does not exist and should not' {
                Mock -CommandName Assert-ResourcePropertiesValid
                Mock -CommandName Get-FsrmFileScreen
                Mock -CommandName New-FsrmFileScreen
                Mock -CommandName Set-FsrmFileScreen
                Mock -CommandName Remove-FsrmFileScreen

                It 'Should not throw error' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileScreen -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen path does not exist' {
                Mock -CommandName Get-FsrmFileScreenTemplate
                Mock -CommandName Test-Path -MockWith { $false }

                It 'Should throw an FileScreenPathDoesNotExistError exception' {
                    $Splat = $script:TestFileScreen.Clone()

                    $errorId = 'FileScreenPathDoesNotExistError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenPathDoesNotExistError) -f $Splat.Path
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
            }

            Context 'FileScreen template does not exist' {
                Mock -CommandName Get-FSRMFileScreenTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'Should throw an FileScreenTemplateNotFoundError exception' {
                    $Splat = $script:TestFileScreen.Clone()

                    $errorId = 'FileScreenTemplateNotFoundError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenTemplateNotFoundError) -f $Splat.Path, $Splat.Template
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
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

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
            }

            Context 'File Screen does not exist but should' {
                Mock -CommandName Get-FsrmFileScreen
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    $Splat = $script:TestFileScreen.Clone()
                    Test-TargetResource @Splat | Should -Be $False

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should but has a different Description' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should but has a different Active' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Active = (-not $Splat.Active)
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should but has a different IncludeGroup' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.IncludeGroup = @( 'Different' )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should but has a different Template' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Template = 'Block Image Files'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should and MatchesTemplate is set but does not match' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.MatchesTemplate = $true
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should and MatchesTemplate is set and does match' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreenMatch }
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.MatchesTemplate = $true
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and should and all parameters match' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen exists and but should not' {
                Mock -CommandName Get-FsrmFileScreen -MockWith { $script:MockFileScreen }
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
                }
            }

            Context 'File Screen does not exist and should not' {
                Mock -CommandName Get-FsrmFileScreen
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreen -Exactly 1
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
