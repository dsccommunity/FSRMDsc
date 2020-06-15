$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMFileGroup'

function Invoke-TestSetup
{
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
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

# Begin Testing
try
{
    InModuleScope $script:dscResourceName {
        # Create the Mock -CommandName Objects that will be used for running tests
        $script:FileGroup = [PSObject]@{
            Name           = 'Test Group'
            Ensure         = 'Present'
            Description    = 'Test Description'
            IncludePattern = @('*.eps', '*.pdf', '*.xps')
            ExcludePattern = @('*.epsx')
            Verbose        = $true
        }

        Describe 'DSC_FSRMFileGroup\Get-TargetResource' {
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

        Describe 'DSC_FSRMFileGroup\Set-TargetResource' {
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

        Describe 'DSC_FSRMFileGroup\Test-TargetResource' {
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
}
finally
{
    Invoke-TestCleanup
}
