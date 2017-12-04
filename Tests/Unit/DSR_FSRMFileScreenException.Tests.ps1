$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileScreenException'

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
        $script:DSCResourceName = 'DSR_FSRMFileScreenException'

        # Create the Mock -CommandName Objects that will be used for running tests
        $script:TestFileScreenException = [PSObject]@{
            Path = $ENV:Temp
            Description = 'File Screen Exception'
            Ensure = 'Present'
            IncludeGroup = [System.Collections.ArrayList]@( 'E-mail Files' )
        }

        $script:MockFileScreenException = [PSObject]@{
            Path = $script:TestFileScreenException.Path
            Description = $script:TestFileScreenException.Description
            IncludeGroup = $script:TestFileScreenException.IncludeGroup.Clone()
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'No File Screen Exceptions exist' {

                Mock -CommandName Get-FsrmFileScreenException

                It 'Should return absent File Screen Exception' {
                    $Result = Get-TargetResource `
                        -Path $script:TestFileScreenException.Path
                    $Result.Ensure | Should -Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'Requested File Screen Exception does exist' {

                Mock -CommandName Get-FsrmFileScreenException -MockWith { return @($script:MockFileScreenException) }

                It 'Should return correct File Screen Exception' {
                    $Result = Get-TargetResource `
                        -Path $script:TestFileScreenException.Path
                    $Result.Ensure | Should -Be 'Present'
                    $Result.Path | Should -Be $script:TestFileScreenException.Path
                    $Result.Description | Should -Be $script:TestFileScreenException.Description
                    $Result.IncludeGroup | Should -Be $script:TestFileScreenException.IncludeGroup
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'File Screen Exception does not exist but should' {

                Mock -CommandName Get-FsrmFileScreenException
                Mock -CommandName New-FsrmFileScreenException
                Mock -CommandName Set-FsrmFileScreenException
                Mock -CommandName Remove-FsrmFileScreenException

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenException.Clone()
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenException -Exactly 0
                }
            }

            Context 'File Screen Exception exists and should but has a different Description' {

                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }
                Mock -CommandName New-FsrmFileScreenException
                Mock -CommandName Set-FsrmFileScreenException
                Mock -CommandName Remove-FsrmFileScreenException

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenException.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreenException -Exactly 0
                }
            }

            Context 'File Screen Exception exists and should but has a different IncludeGroup' {

                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }
                Mock -CommandName New-FsrmFileScreenException
                Mock -CommandName Set-FsrmFileScreenException
                Mock -CommandName Remove-FsrmFileScreenException

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenException.Clone()
                        $Splat.IncludeGroup = @( 'Different' )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreenException -Exactly 0
                }
            }

            Context 'File Screen Exception exists and but should not' {

                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }
                Mock -CommandName New-FsrmFileScreenException
                Mock -CommandName Set-FsrmFileScreenException
                Mock -CommandName Remove-FsrmFileScreenException

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenException.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception does not exist and should not' {

                Mock -CommandName Get-FsrmFileScreenException
                Mock -CommandName New-FsrmFileScreenException
                Mock -CommandName Set-FsrmFileScreenException
                Mock -CommandName Remove-FsrmFileScreenException

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenException.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenException -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen Exception path does not exist' {
                Mock -CommandName Get-FsrmFileScreenException
                Mock -CommandName Test-Path -MockWith { $false }

                It 'Should throw an FileScreenExceptionPathDoesNotExistError exception' {
                    $Splat = $script:TestFileScreenException.Clone()

                    $errorRecord = Get-InvalidArgumentRecord `
                        -Message ($($LocalizedData.FileScreenExceptionPathDoesNotExistError) -f $Splat.Path) `
                        -ArgumentName 'Path'

                    { Test-TargetResource @Splat } | Should -Throw $errorRecord
                }
            }

            Context 'File Screen Exception does not exist but should' {

                Mock -CommandName Get-FsrmFileScreenException

                It 'Should return false' {
                    $Splat = $script:TestFileScreenException.Clone()
                    Test-TargetResource @Splat | Should -Be $False

                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and should but has a different Description' {

                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreenException.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and should but has a different IncludeGroup' {

                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreenException.Clone()
                        $Splat.IncludeGroup = @( 'Different' )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and should and all parameters match' {

                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }

                It 'Should return true' {
                    {
                        $Splat = $script:TestFileScreenException.Clone()
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and but should not' {

                Mock -CommandName Get-FsrmFileScreenException -MockWith { $script:MockFileScreenException }

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreenException.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception does not exist and should not' {

                Mock -CommandName Get-FsrmFileScreenException

                It 'Should return true' {
                    {
                        $Splat = $script:TestFileScreenException.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
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
