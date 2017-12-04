$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileScreenTemplate'

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
        $script:DSCResourceName = 'DSR_FSRMFileScreenTemplate'

        # Create the Mock Objects that will be used for running tests
        $script:TestFileScreenTemplate = [PSObject]@{
            Name = 'Block Some Files'
            Description = 'File Screen Templates for Blocking Some Files'
            Ensure = 'Present'
            Active = $False
            IncludeGroup = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
        }
        $script:MockFileScreenTemplate = [PSObject]@{
            Name = $TestFileScreenTemplate.Name
            Description = $TestFileScreenTemplate.Description
            Active = $TestFileScreenTemplate.Active
            IncludeGroup = $TestFileScreenTemplate.IncludeGroup
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'No File Screen templates exist' {

                Mock Get-FsrmFileScreenTemplate

                It 'Should return absent File Screen template' {
                    $Result = Get-TargetResource `
                        -Name $script:TestFileScreenTemplate.Name
                    $Result.Ensure | Should -Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'Requested File Screen template does exist' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($script:MockFileScreenTemplate) }

                It 'Should return correct FileScreen template' {
                    $Result = Get-TargetResource `
                        -Name $script:TestFileScreenTemplate.Name
                    $Result.Ensure | Should -Be 'Present'
                    $Result.Name | Should -Be $script:TestFileScreenTemplate.Name
                    $Result.Description | Should -Be $script:TestFileScreenTemplate.Description
                    $Result.Active | Should -Be $script:TestFileScreenTemplate.Active
                    $Result.IncludeGroup | Should -Be $script:TestFileScreenTemplate.IncludeGroup
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'File Screen template does not exist but should' {

                Mock Get-FsrmFileScreenTemplate
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and should but has a different Description' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and should but has a different Active' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        $Splat.Active = (-not $Splat.Active)
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and should but has a different IncludeGroup' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        $Splat.IncludeGroup = [System.Collections.ArrayList]@( 'Temporary Files' )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and but should not' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template does not exist and should not' {

                Mock Get-FsrmFileScreenTemplate
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen template does not exist but should' {

                Mock Get-FsrmFileScreenTemplate

                It 'Should return false' {
                    $Splat = $script:TestFileScreenTemplate.Clone()
                    Test-TargetResource @Splat | Should -Be $False

                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should but has a different Description' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should but has a different Active' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        $Splat.Active = (-not $Splat.Active)
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should but has a different IncludeGroup' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        $Splat.IncludeGroup = [System.Collections.ArrayList]@( 'Temporary Files' )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should and all parameters match' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }

                It 'Should return true' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and but should not' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $script:MockFileScreenTemplate }

                It 'Should return false' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template does not exist and should not' {

                Mock Get-FsrmFileScreenTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestFileScreenTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
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
