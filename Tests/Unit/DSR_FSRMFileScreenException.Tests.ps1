$script:DSCModuleName = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileScreenException'

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
        $script:DSCResourceName = 'DSR_FSRMFileScreenException'

        # Create the Mock -CommandName Objects that will be used for running tests
        $script:TestFileScreenException = [PSObject]@{
            Path         = $ENV:Temp
            Description  = 'File Screen Exception'
            Ensure       = 'Present'
            IncludeGroup = [System.Collections.ArrayList]@( 'E-mail Files' )
            Verbose      = $true
        }

        $script:MockFileScreenException = [PSObject]@{
            Path         = $script:TestFileScreenException.Path
            Description  = $script:TestFileScreenException.Description
            IncludeGroup = $script:TestFileScreenException.IncludeGroup.Clone()
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context 'No File Screen Exceptions exist' {
                Mock -CommandName Get-FsrmFileScreenException

                It 'Should return absent File Screen Exception' {
                    $Result = Get-TargetResource -Path $script:TestFileScreenException.Path -Verbose
                    $Result.Ensure | Should -Be 'Absent'
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'Requested File Screen Exception does exist' {
                Mock -CommandName Get-FsrmFileScreenException -MockWith { return @($script:MockFileScreenException) }

                It 'Should return correct File Screen Exception' {
                    $Result = Get-TargetResource -Path $script:TestFileScreenException.Path -Verbose
                    $Result.Ensure | Should -Be 'Present'
                    $Result.Path | Should -Be $script:TestFileScreenException.Path
                    $Result.Description | Should -Be $script:TestFileScreenException.Description
                    $Result.IncludeGroup | Should -Be $script:TestFileScreenException.IncludeGroup
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'File Screen Exception does not exist but should' {
                Mock -CommandName Get-FsrmFileScreenException
                Mock -CommandName New-FsrmFileScreenException
                Mock -CommandName Set-FsrmFileScreenException
                Mock -CommandName Remove-FsrmFileScreenException

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenException.Clone()
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -CommandName Set-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenException -Exactly 0
                }
            }

            Context 'File Screen Exception exists and should but has a different Description' {
                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }
                Mock -CommandName New-FsrmFileScreenException
                Mock -CommandName Set-FsrmFileScreenException
                Mock -CommandName Remove-FsrmFileScreenException

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenException.Clone()
                        $setTargetResourceParameters.Description = 'Different'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenException -Exactly 0
                }
            }

            Context 'File Screen Exception exists and should but has a different IncludeGroup' {
                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }
                Mock -CommandName New-FsrmFileScreenException
                Mock -CommandName Set-FsrmFileScreenException
                Mock -CommandName Remove-FsrmFileScreenException

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenException.Clone()
                        $setTargetResourceParameters.IncludeGroup = @( 'Different' )
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenException -Exactly 0
                }
            }

            Context 'File Screen Exception exists and but should not' {
                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }
                Mock -CommandName New-FsrmFileScreenException
                Mock -CommandName Set-FsrmFileScreenException
                Mock -CommandName Remove-FsrmFileScreenException

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenException.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception does not exist and should not' {
                Mock -CommandName Get-FsrmFileScreenException
                Mock -CommandName New-FsrmFileScreenException
                Mock -CommandName Set-FsrmFileScreenException
                Mock -CommandName Remove-FsrmFileScreenException

                It 'Should not throw error' {
                    {
                        $setTargetResourceParameters = $script:TestFileScreenException.Clone()
                        $setTargetResourceParameters.Ensure = 'Absent'
                        Set-TargetResource @setTargetResourceParameters
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -CommandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -CommandName Set-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -CommandName Remove-FsrmFileScreenException -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen Exception path does not exist' {
                Mock -CommandName Get-FsrmFileScreenException
                Mock -CommandName Test-Path -MockWith { $false }

                It 'Should throw an FileScreenExceptionPathDoesNotExistError exception' {
                    $testTargetResourceParameters = $script:TestFileScreenException.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenExceptionPathDoesNotExistError) -f $testTargetResourceParameters.Path) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @testTargetResourceParameters } | Should -Throw $errorRecord
                }
            }

            Context 'File Screen Exception does not exist but should' {
                Mock -CommandName Get-FsrmFileScreenException

                It 'Should return false' {
                    $testTargetResourceParameters = $script:TestFileScreenException.Clone()
                    Test-TargetResource @testTargetResourceParameters | Should -Be $false

                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and should but has a different Description' {
                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenException.Clone()
                        $testTargetResourceParameters.Description = 'Different'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and should but has a different IncludeGroup' {
                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenException.Clone()
                        $testTargetResourceParameters.IncludeGroup = @( 'Different' )
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and should and all parameters match' {
                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenException.Clone()
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and but should not' {
                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }

                It 'Should return false' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenException.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $false
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception does not exist and should not' {
                Mock -CommandName Get-FsrmFileScreenException

                It 'Should return true' {
                    {
                        $testTargetResourceParameters = $script:TestFileScreenException.Clone()
                        $testTargetResourceParameters.Ensure = 'Absent'
                        Test-TargetResource @testTargetResourceParameters | Should -Be $true
                    } | Should -Not -Throw
                }

                It 'Should call expected Mocks' {
                    Assert-MockCalled -CommandName Get-FsrmFileScreenException -Exactly 1
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
