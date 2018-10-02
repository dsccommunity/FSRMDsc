$script:DSCModuleName = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileScreenTemplate'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Unit Test Template Version: 1.1.0
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
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
        $script:DSCResourceName = 'DSR_FSRMFileScreenTemplate'

        # Create the Mock -CommandName Objects that will be used for running tests
        $script:TestFileScreenTemplate = [PSObject]@{
            Name         = 'Block Some Files'
            Description  = 'File Screen Templates for Blocking Some Files'
            Ensure       = 'Present'
            Active       = $false
            IncludeGroup = [System.Collections.ArrayList]@( 'Audio and Video Files', 'Executable Files', 'Backup Files' )
            Verbose      = $true
        }

        $script:MockFileScreenTemplate = [PSObject]@{
            Name         = $TestFileScreenTemplate.Name
            Description  = $TestFileScreenTemplate.Description
            Active       = $TestFileScreenTemplate.Active
            IncludeGroup = $TestFileScreenTemplate.IncludeGroup
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'No File Screen templates exist' {
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return absent File Screen template' {
                    $result = Get-TargetResource -Name $script:TestFileScreenTemplate.Name -Verbose
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'Requested File Screen template does exist' {
                Mock -CommandName Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return correct FileScreen template' {
                    $result = Get-TargetResource -Name $script:TestFileScreenTemplate.Name -Verbose
                    $result.Ensure | Should -Be 'Present'
                    $result.Name | Should -Be $script:TestFileScreenTemplate.Name
                    $result.Description | Should -Be $script:TestFileScreenTemplate.Description
                    $result.Active | Should -Be $script:TestFileScreenTemplate.Active
                    $result.IncludeGroup | Should -Be $script:TestFileScreenTemplate.IncludeGroup
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'File Screen template does not exist but should' {
                Mock -CommandName Get-FsrmFileScreenTemplate
                Mock -CommandName New-FsrmFileScreenTemplate
                Mock -CommandName Set-FsrmFileScreenTemplate
                Mock -CommandName Remove-FsrmFileScreenTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and should but has a different Description' {
                Mock -CommandName Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }
                Mock -CommandName New-FsrmFileScreenTemplate
                Mock -CommandName Set-FsrmFileScreenTemplate
                Mock -CommandName Remove-FsrmFileScreenTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        $setTargetResourceParameters.Description = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and should but has a different Active' {
                Mock -CommandName Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }
                Mock -CommandName New-FsrmFileScreenTemplate
                Mock -CommandName Set-FsrmFileScreenTemplate
                Mock -CommandName Remove-FsrmFileScreenTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        $setTargetResourceParameters.Active = (-not $setTargetResourceParameters.Active)
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and should but has a different IncludeGroup' {
                Mock -CommandName Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }
                Mock -CommandName New-FsrmFileScreenTemplate
                Mock -CommandName Set-FsrmFileScreenTemplate
                Mock -CommandName Remove-FsrmFileScreenTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        $setTargetResourceParameters.IncludeGroup = [System.Collections.ArrayList]@( 'Temporary Files' )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and but should not' {
                Mock -CommandName Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }
                Mock -CommandName New-FsrmFileScreenTemplate
                Mock -CommandName Set-FsrmFileScreenTemplate
                Mock -CommandName Remove-FsrmFileScreenTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template does not exist and should not' {
                Mock -CommandName Get-FsrmFileScreenTemplate
                Mock -CommandName New-FsrmFileScreenTemplate
                Mock -CommandName Set-FsrmFileScreenTemplate
                Mock -CommandName Remove-FsrmFileScreenTemplate

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen template does not exist but should' {
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should but has a different Description' {
                Mock -CommandName Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        $testTargetResourceParameters.Description = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should but has a different Active' {
                Mock -CommandName Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        $testTargetResourceParameters.Active = (-not $testTargetResourceParameters.Active)
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should but has a different IncludeGroup' {
                Mock -CommandName Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        $testTargetResourceParameters.IncludeGroup = [System.Collections.ArrayList]@( 'Temporary Files' )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should and all parameters match' {
                Mock -CommandName Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and but should not' {
                Mock -CommandName Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template does not exist and should not' {
                Mock -CommandName Get-FsrmFileScreenTemplate

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenTemplate.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenTemplate -Exactly 1
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
