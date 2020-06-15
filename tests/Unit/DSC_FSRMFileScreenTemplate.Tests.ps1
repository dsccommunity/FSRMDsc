$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMFileScreenTemplate'

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

        Describe 'DSC_FSRMFileScreenTemplate\Get-TargetResource' {
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

        Describe 'DSC_FSRMFileScreenTemplate\Set-TargetResource' {
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

        Describe 'DSC_FSRMFileScreenTemplate\Test-TargetResource' {
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
}
finally
{
    Invoke-TestCleanup
}
