$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMFileGroup'

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
        $script:DSCResourceName = 'DSR_FSRMFileGroup'

        # Create the Mock Objects that will be used for running tests
        $script:FileGroup = [PSObject]@{
            Name = 'Test Group'
            Ensure = 'Present'
            Description = 'Test Description'
            IncludePattern = @('*.eps','*.pdf','*.xps')
            ExcludePattern = @('*.epsx')
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'No file groups exist' {

                Mock Get-FsrmFileGroup

                It 'Should return absent file group' {
                    $Result = Get-TargetResource `
                        -Name $script:FileGroup.Name
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'Requested file group does exist' {

                Mock Get-FsrmFileGroup -MockWith { return @($script:FileGroup) }

                It 'Should return correct file group' {
                    $Result = Get-TargetResource `
                        -Name $script:FileGroup.Name
                    $Result.Ensure | Should Be 'Present'
                    $Result.Name | Should Be $script:FileGroup.Name
                    $Result.Description | Should Be $script:FileGroup.Description
                    $Result.IncludePattern | Should Be $script:FileGroup.IncludePattern
                    $Result.ExcludePattern | Should Be $script:FileGroup.ExcludePattern
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'File Group does not exist but should' {

                Mock Get-FsrmFileGroup
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and should but has a different Description' {

                Mock Get-FsrmFileGroup -MockWith { $script:FileGroup }
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and should but has a different IncludePattern' {

                Mock Get-FsrmFileGroup -MockWith { $script:FileGroup }
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        $Splat.IncludePattern = @('*.dif')
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and should but has a different ExcludePattern' {

                Mock Get-FsrmFileGroup -MockWith { $script:FileGroup }
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        $Splat.ExcludePattern = @('*.dif')
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and but should not' {

                Mock Get-FsrmFileGroup -MockWith { $script:FileGroup }
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group does not exist and should not' {

                Mock Get-FsrmFileGroup
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'Should not throw error' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'File Group does not exist but should' {

                Mock Get-FsrmFileGroup

                It 'Should return false' {
                    $Splat = $script:FileGroup.Clone()
                    Test-TargetResource @Splat | Should Be $False

                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should but has a different Description' {

                Mock Get-FsrmFileGroup -MockWith { $script:FileGroup }

                It 'Should return false' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should but has a different IncludePattern' {

                Mock Get-FsrmFileGroup -MockWith { $script:FileGroup }

                It 'Should return false' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        $Splat.IncludePattern = @('*.dif')
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should but has a different ExcludePattern' {

                Mock Get-FsrmFileGroup -MockWith { $script:FileGroup }

                It 'Should return false' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        $Splat.ExcludePattern = @('*.dif')
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should and all parameters match' {

                Mock Get-FsrmFileGroup -MockWith { $script:FileGroup }

                It 'Should return true' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and but should not' {

                Mock Get-FsrmFileGroup -MockWith { $script:FileGroup }

                It 'Should return false' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group does not exist and should not' {

                Mock Get-FsrmFileGroup

                It 'Should return true' {
                    {
                        $Splat = $script:FileGroup.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
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
