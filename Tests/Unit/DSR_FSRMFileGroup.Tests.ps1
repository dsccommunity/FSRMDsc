$script:DSCModuleName = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileGroup'

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
        $script:DSCResourceName = 'DSR_FSRMFileGroup'

        # Create the Mock -CommandName Objects that will be used for running tests
        $script:FileGroup = [PSObject]@{
            Name           = 'Test Group'
            Ensure         = 'Present'
            Description    = 'Test Description'
            IncludePattern = @('*.eps', '*.pdf', '*.xps')
            ExcludePattern = @('*.epsx')
            Verbose        = $true
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'No file groups exist' {
                Mock -CommandName Get-FsrmFileGroup

                It 'Should return absent file group' {
                    $result = Get-TargetResource -Name $script:FileGroup.Name -Verbose
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'Requested file group does exist' {
                Mock -CommandName Get-FsrmFileGroup -MockWith { return @($script:FileGroup) }

                It 'Should return correct file group' {
                    $result = Get-TargetResource -Name $script:FileGroup.Name -Verbose
                    $result.Ensure | Should -Be 'Present'
                    $result.Name | Should -Be $script:FileGroup.Name
                    $result.Description | Should -Be $script:FileGroup.Description
                    $result.IncludePattern | Should -Be $script:FileGroup.IncludePattern
                    $result.ExcludePattern | Should -Be $script:FileGroup.ExcludePattern
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'File Group does not exist but should' {
                Mock -CommandName Get-FsrmFileGroup
                Mock -CommandName New-FsrmFileGroup
                Mock -CommandName Set-FsrmFileGroup
                Mock -CommandName Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:FileGroup.Clone()
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and should but has a different Description' {
                Mock -CommandName Get-FsrmFileGroup -MockWith { $script:FileGroup }
                Mock -CommandName New-FsrmFileGroup
                Mock -CommandName Set-FsrmFileGroup
                Mock -CommandName Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:FileGroup.Clone()
                        $setTargetResourceParameters.Description = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and should but has a different IncludePattern' {
                Mock -CommandName Get-FsrmFileGroup -MockWith { $script:FileGroup }
                Mock -CommandName New-FsrmFileGroup
                Mock -CommandName Set-FsrmFileGroup
                Mock -CommandName Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:FileGroup.Clone()
                        $setTargetResourceParameters.IncludePattern = @('*.dif')
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and should but has a different ExcludePattern' {
                Mock -CommandName Get-FsrmFileGroup -MockWith { $script:FileGroup }
                Mock -CommandName New-FsrmFileGroup
                Mock -CommandName Set-FsrmFileGroup
                Mock -CommandName Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:FileGroup.Clone()
                        $setTargetResourceParameters.ExcludePattern = @('*.dif')
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and but should not' {
                Mock -CommandName Get-FsrmFileGroup -MockWith { $script:FileGroup }
                Mock -CommandName New-FsrmFileGroup
                Mock -CommandName Set-FsrmFileGroup
                Mock -CommandName Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:FileGroup.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group does not exist and should not' {
                Mock -CommandName Get-FsrmFileGroup
                Mock -CommandName New-FsrmFileGroup
                Mock -CommandName Set-FsrmFileGroup
                Mock -CommandName Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:FileGroup.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileGroup -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Group does not exist but should' {
                Mock -CommandName Get-FsrmFileGroup

                It 'Should return false' {
                    $testTargetResourceParameters = $script:FileGroup.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should but has a different Description' {
                Mock -CommandName Get-FsrmFileGroup -MockWith { $script:FileGroup }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:FileGroup.Clone()
                        $testTargetResourceParameters.Description = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should but has a different IncludePattern' {
                Mock -CommandName Get-FsrmFileGroup -MockWith { $script:FileGroup }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:FileGroup.Clone()
                        $testTargetResourceParameters.IncludePattern = @('*.dif')
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should but has a different ExcludePattern' {
                Mock -CommandName Get-FsrmFileGroup -MockWith { $script:FileGroup }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:FileGroup.Clone()
                        $testTargetResourceParameters.ExcludePattern = @('*.dif')
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should and all parameters match' {
                Mock -CommandName Get-FsrmFileGroup -MockWith { $script:FileGroup }

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:FileGroup.Clone()
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and but should not' {
                Mock -CommandName Get-FsrmFileGroup -MockWith { $script:FileGroup }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:FileGroup.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group does not exist and should not' {
                Mock -CommandName Get-FsrmFileGroup

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:FileGroup.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileGroup -Exactly 1
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
