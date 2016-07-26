$Global:DSCModuleName   = 'FSRMDsc'
$Global:DSCResourceName = 'MSFT_FSRMFileGroup'

#region HEADER
# Unit Test Template Version: 1.1.0
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $Global:DSCResourceName {

        # Create the Mock Objects that will be used for running tests
        $Global:FileGroup = [PSObject]@{
            Name = 'Test Group'
            Ensure = 'Present'
            Description = 'Test Description'
            IncludePattern = @('*.eps','*.pdf','*.xps')
            ExcludePattern = @('*.epsx')
        }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'No file groups exist' {

                Mock Get-FsrmFileGroup

                It 'should return absent file group' {
                    $Result = Get-TargetResource `
                        -Name $Global:FileGroup.Name
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'Requested file group does exist' {

                Mock Get-FsrmFileGroup -MockWith { return @($Global:FileGroup) }

                It 'should return correct file group' {
                    $Result = Get-TargetResource `
                        -Name $Global:FileGroup.Name
                    $Result.Ensure | Should Be 'Present'
                    $Result.Name | Should Be $Global:FileGroup.Name
                    $Result.Description | Should Be $Global:FileGroup.Description
                    $Result.IncludePattern | Should Be $Global:FileGroup.IncludePattern
                    $Result.ExcludePattern | Should Be $Global:FileGroup.ExcludePattern
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'File Group does not exist but should' {

                Mock Get-FsrmFileGroup
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'should not throw error' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and should but has a different Description' {

                Mock Get-FsrmFileGroup -MockWith { $Global:FileGroup }
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'should not throw error' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and should but has a different IncludePattern' {

                Mock Get-FsrmFileGroup -MockWith { $Global:FileGroup }
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'should not throw error' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        $Splat.IncludePattern = @('*.dif')
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and should but has a different ExcludePattern' {

                Mock Get-FsrmFileGroup -MockWith { $Global:FileGroup }
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'should not throw error' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        $Splat.ExcludePattern = @('*.dif')
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 0
                }
            }

            Context 'File Group exists and but should not' {

                Mock Get-FsrmFileGroup -MockWith { $Global:FileGroup }
                Mock New-FsrmFileGroup
                Mock Set-FsrmFileGroup
                Mock Remove-FsrmFileGroup

                It 'should not throw error' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
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

                It 'should not throw error' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileGroup -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileGroup -Exactly 0
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'File Group does not exist but should' {

                Mock Get-FsrmFileGroup

                It 'should return false' {
                    $Splat = $Global:FileGroup.Clone()
                    Test-TargetResource @Splat | Should Be $False

                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should but has a different Description' {

                Mock Get-FsrmFileGroup -MockWith { $Global:FileGroup }

                It 'should return false' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should but has a different IncludePattern' {

                Mock Get-FsrmFileGroup -MockWith { $Global:FileGroup }

                It 'should return false' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        $Splat.IncludePattern = @('*.dif')
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should but has a different ExcludePattern' {

                Mock Get-FsrmFileGroup -MockWith { $Global:FileGroup }

                It 'should return false' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        $Splat.ExcludePattern = @('*.dif')
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and should and all parameters match' {

                Mock Get-FsrmFileGroup -MockWith { $Global:FileGroup }

                It 'should return true' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group exists and but should not' {

                Mock Get-FsrmFileGroup -MockWith { $Global:FileGroup }

                It 'should return false' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileGroup -Exactly 1
                }
            }

            Context 'File Group does not exist and should not' {

                Mock Get-FsrmFileGroup

                It 'should return true' {
                    {
                        $Splat = $Global:FileGroup.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
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