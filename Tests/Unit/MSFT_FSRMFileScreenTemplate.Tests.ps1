$Global:DSCModuleName   = 'FSRMDsc'
$Global:DSCResourceName = 'MSFT_FSRMFileScreenTemplate'

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
        $Global:TestFileScreenTemplate = [PSObject]@{
            Name = 'Block Some Files'
            Description = 'File Screen Templates for Blocking Some Files'
            Ensure = 'Present'
            Active = $False
            IncludeGroup = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
        }
        $Global:MockFileScreenTemplate = [PSObject]@{
            Name = $TestFileScreenTemplate.Name
            Description = $TestFileScreenTemplate.Description
            Active = $TestFileScreenTemplate.Active
            IncludeGroup = $TestFileScreenTemplate.IncludeGroup
        }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'No File Screen templates exist' {

                Mock Get-FsrmFileScreenTemplate

                It 'should return absent File Screen template' {
                    $Result = Get-TargetResource `
                        -Name $Global:TestFileScreenTemplate.Name
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'Requested File Screen template does exist' {

                Mock Get-FsrmFileScreenTemplate -MockWith { return @($Global:MockFileScreenTemplate) }

                It 'should return correct FileScreen template' {
                    $Result = Get-TargetResource `
                        -Name $Global:TestFileScreenTemplate.Name
                    $Result.Ensure | Should Be 'Present'
                    $Result.Name | Should Be $Global:TestFileScreenTemplate.Name
                    $Result.Description | Should Be $Global:TestFileScreenTemplate.Description
                    $Result.Active | Should Be $Global:TestFileScreenTemplate.Active
                    $Result.IncludeGroup | Should Be $Global:TestFileScreenTemplate.IncludeGroup
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'File Screen template does not exist but should' {

                Mock Get-FsrmFileScreenTemplate
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and should but has a different Description' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $Global:MockFileScreenTemplate }
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and should but has a different Active' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $Global:MockFileScreenTemplate }
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        $Splat.Active = (-not $Splat.Active)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and should but has a different IncludeGroup' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $Global:MockFileScreenTemplate }
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        $Splat.IncludeGroup = [System.Collections.ArrayList]@( 'Temporary Files' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }

            Context 'File Screen template exists and but should not' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $Global:MockFileScreenTemplate }
                Mock New-FsrmFileScreenTemplate
                Mock Set-FsrmFileScreenTemplate
                Mock Remove-FsrmFileScreenTemplate

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
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

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenTemplate -Exactly 0
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen template does not exist but should' {

                Mock Get-FsrmFileScreenTemplate

                It 'should return false' {
                    $Splat = $Global:TestFileScreenTemplate.Clone()
                    Test-TargetResource @Splat | Should Be $False

                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should but has a different Description' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $Global:MockFileScreenTemplate }

                It 'should return false' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should but has a different Active' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $Global:MockFileScreenTemplate }

                It 'should return false' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        $Splat.Active = (-not $Splat.Active)
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should but has a different IncludeGroup' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $Global:MockFileScreenTemplate }

                It 'should return false' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        $Splat.IncludeGroup = [System.Collections.ArrayList]@( 'Temporary Files' )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and should and all parameters match' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $Global:MockFileScreenTemplate }

                It 'should return true' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template exists and but should not' {

                Mock Get-FsrmFileScreenTemplate -MockWith { $Global:MockFileScreenTemplate }

                It 'should return false' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenTemplate -Exactly 1
                }
            }

            Context 'File Screen template does not exist and should not' {

                Mock Get-FsrmFileScreenTemplate

                It 'should return true' {
                    {
                        $Splat = $Global:TestFileScreenTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
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