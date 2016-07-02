$Global:DSCModuleName   = 'xFSRM'
$Global:DSCResourceName = 'MSFT_xFSRMFileScreenException'

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
        $Global:TestFileScreenException = [PSObject]@{
            Path = $ENV:Temp
            Description = 'File Screen Exception'
            Ensure = 'Present'
            IncludeGroup = [System.Collections.ArrayList]@( 'E-mail Files' )
        }

        $Global:MockFileScreenException = [PSObject]@{
            Path = $Global:TestFileScreenException.Path
            Description = $Global:TestFileScreenException.Description
            IncludeGroup = $Global:TestFileScreenException.IncludeGroup.Clone()
        }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'No File Screen Exceptions exist' {

                Mock Get-FsrmFileScreenException

                It 'should return absent File Screen Exception' {
                    $Result = Get-TargetResource `
                        -Path $Global:TestFileScreenException.Path
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'Requested File Screen Exception does exist' {

                Mock Get-FsrmFileScreenException -MockWith { return @($Global:MockFileScreenException) }

                It 'should return correct File Screen Exception' {
                    $Result = Get-TargetResource `
                        -Path $Global:TestFileScreenException.Path
                    $Result.Ensure | Should Be 'Present'
                    $Result.Path | Should Be $Global:TestFileScreenException.Path
                    $Result.Description | Should Be $Global:TestFileScreenException.Description
                    $Result.IncludeGroup | Should Be $Global:TestFileScreenException.IncludeGroup
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'File Screen Exception does not exist but should' {

                Mock Get-FsrmFileScreenException
                Mock New-FsrmFileScreenException
                Mock Set-FsrmFileScreenException
                Mock Remove-FsrmFileScreenException

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenException.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenException -Exactly 0
                }
            }

            Context 'File Screen Exception exists and should but has a different Description' {

                Mock Get-FsrmFileScreenException -MockWith { $Global:MockFileScreenException }
                Mock New-FsrmFileScreenException
                Mock Set-FsrmFileScreenException
                Mock Remove-FsrmFileScreenException

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenException.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreenException -Exactly 0
                }
            }

            Context 'File Screen Exception exists and should but has a different IncludeGroup' {

                Mock Get-FsrmFileScreenException -MockWith { $Global:MockFileScreenException }
                Mock New-FsrmFileScreenException
                Mock Set-FsrmFileScreenException
                Mock Remove-FsrmFileScreenException

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenException.Clone()
                        $Splat.IncludeGroup = @( 'Different' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreenException -Exactly 0
                }
            }

            Context 'File Screen Exception exists and but should not' {

                Mock Get-FsrmFileScreenException -MockWith { $Global:MockFileScreenException }
                Mock New-FsrmFileScreenException
                Mock Set-FsrmFileScreenException
                Mock Remove-FsrmFileScreenException

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenException.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception does not exist and should not' {

                Mock Get-FsrmFileScreenException
                Mock New-FsrmFileScreenException
                Mock Set-FsrmFileScreenException
                Mock Remove-FsrmFileScreenException

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestFileScreenException.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreenException -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreenException -Exactly 0
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen Exception path does not exist' {
                Mock Get-FsrmFileScreenException
                Mock Test-Path -MockWith { $false }

                It 'should throw an FileScreenExceptionPathDoesNotExistError exception' {
                    $Splat = $Global:TestFileScreenException.Clone()

                    $errorId = 'FileScreenExceptionPathDoesNotExistError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenExceptionPathDoesNotExistError) -f $Splat.Path
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'File Screen Exception does not exist but should' {

                Mock Get-FsrmFileScreenException

                It 'should return false' {
                    $Splat = $Global:TestFileScreenException.Clone()
                    Test-TargetResource @Splat | Should Be $False

                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and should but has a different Description' {

                Mock Get-FsrmFileScreenException -MockWith { $Global:MockFileScreenException }

                It 'should return false' {
                    {
                        $Splat = $Global:TestFileScreenException.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and should but has a different IncludeGroup' {

                Mock Get-FsrmFileScreenException -MockWith { $Global:MockFileScreenException }

                It 'should return false' {
                    {
                        $Splat = $Global:TestFileScreenException.Clone()
                        $Splat.IncludeGroup = @( 'Different' )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and should and all parameters match' {

                Mock Get-FsrmFileScreenException -MockWith { $Global:MockFileScreenException }

                It 'should return true' {
                    {
                        $Splat = $Global:TestFileScreenException.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception exists and but should not' {

                Mock Get-FsrmFileScreenException -MockWith { $Global:MockFileScreenException }

                It 'should return false' {
                    {
                        $Splat = $Global:TestFileScreenException.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreenException -Exactly 1
                }
            }

            Context 'File Screen Exception does not exist and should not' {

                Mock Get-FsrmFileScreenException

                It 'should return true' {
                    {
                        $Splat = $Global:TestFileScreenException.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
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