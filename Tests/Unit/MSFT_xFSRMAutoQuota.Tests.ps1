$Global:DSCModuleName   = 'xFSRM'
$Global:DSCResourceName = 'MSFT_xFSRMAutoQuota'

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
        $Global:TestAutoQuota = [PSObject]@{
            Path = $ENV:Temp
            Ensure = 'Present'
            Disabled = $false
            Template = '5 GB Limit'
        }

        $Global:MockAutoQuota = [PSObject]@{
            Path = $Global:TestAutoQuota.Path
            Disabled = $Global:TestAutoQuota.Disabled
            Template = $Global:TestAutoQuota.Template
        }

        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context 'No auto quotas exist' {

                Mock Get-FsrmAutoQuota

                It 'should return absent auto quota' {
                    $Result = Get-TargetResource `
                        -Path $Global:TestAutoQuota.Path
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'Requested auto quota does exist' {

                Mock Get-FsrmAutoQuota -MockWith { return @($Global:MockAutoQuota) }

                It 'should return correct auto quota' {
                    $Result = Get-TargetResource `
                        -Path $Global:TestAutoQuota.Path
                    $Result.Ensure | Should Be 'Present'
                    $Result.Path | Should Be $Global:TestAutoQuota.Path
                    $Result.Disabled | Should Be $Global:TestAutoQuota.Disabled
                    $Result.Template | Should Be $Global:TestAutoQuota.Template
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }
        }

        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context 'auto quota does not exist but should' {

                Mock Get-FsrmAutoQuota
                Mock New-FsrmAutoQuota
                Mock Set-FsrmAutoQuota
                Mock Remove-FsrmAutoQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestAutoQuota.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmAutoQuota -Exactly 0
                }
            }

            Context 'auto quota exists and should but has a different Disabled' {

                Mock Get-FsrmAutoQuota -MockWith { $Global:MockAutoQuota }
                Mock New-FsrmAutoQuota
                Mock Set-FsrmAutoQuota
                Mock Remove-FsrmAutoQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestAutoQuota.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmAutoQuota -Exactly 0
                }
            }

            Context 'auto quota exists and should but has a different Template' {

                Mock Get-FsrmAutoQuota -MockWith { $Global:MockAutoQuota }
                Mock New-FsrmAutoQuota
                Mock Set-FsrmAutoQuota
                Mock Remove-FsrmAutoQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestAutoQuota.Clone()
                        $Splat.Template = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmAutoQuota -Exactly 0
                }
            }

            Context 'auto quota exists but should not' {

                Mock Get-FsrmAutoQuota -MockWith { $Global:MockAutoQuota }
                Mock New-FsrmAutoQuota
                Mock Set-FsrmAutoQuota
                Mock Remove-FsrmAutoQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestAutoQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota does not exist and should not' {

                Mock Get-FsrmAutoQuota
                Mock New-FsrmAutoQuota
                Mock Set-FsrmAutoQuota
                Mock Remove-FsrmAutoQuota

                It 'should not throw error' {
                    {
                        $Splat = $Global:TestAutoQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                    Assert-MockCalled -commandName New-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmAutoQuota -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmAutoQuota -Exactly 0
                }
            }
        }



        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            Context 'auto quota path does not exist' {
                Mock Get-FsrmQuotaTemplate
                Mock Test-Path -MockWith { $false }

                It 'should throw an AutoQuotaPathDoesNotExistError exception' {
                    $Splat = $Global:TestAutoQuota.Clone()

                    $errorId = 'AutoQuotaPathDoesNotExistError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.AutoQuotaPathDoesNotExistError) -f $Splat.Path
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'auto quota template does not exist' {
                Mock Get-FsrmQuotaTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }

                It 'should throw an AutoQuotaTemplateNotFoundError exception' {
                    $Splat = $Global:TestAutoQuota.Clone()

                    $errorId = 'AutoQuotaTemplateNotFoundError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.AutoQuotaTemplateNotFoundError) -f $Splat.Path,$Splat.Template
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'auto quota template not specified' {
                Mock Get-FsrmQuotaTemplate

                It 'should throw an AutoQuotaTemplateEmptyError exception' {
                    $Splat = $Global:TestAutoQuota.Clone()
                    $Splat.Template = ''

                    $errorId = 'AutoQuotaTemplateEmptyError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.AutoQuotaTemplateEmptyError) -f $Splat.Path
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null

                    { Test-TargetResource @Splat } | Should Throw $errorRecord
                }
            }

            Context 'auto quota does not exist but should' {

                Mock Get-FsrmAutoQuota
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    $Splat = $Global:TestAutoQuota.Clone()
                    Test-TargetResource @Splat | Should Be $False

                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Disabled' {

                Mock Get-FsrmAutoQuota -MockWith { $Global:MockAutoQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestAutoQuota.Clone()
                        $Splat.Disabled = (-not $Splat.Disabled)
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'quota exists and should but has a different Template' {

                Mock Get-FsrmAutoQuota -MockWith { $Global:MockAutoQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestAutoQuota.Clone()
                        $Splat.Template = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota exists and should and all parameters match' {

                Mock Get-FsrmAutoQuota -MockWith { $Global:MockAutoQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return true' {
                    {
                        $Splat = $Global:TestAutoQuota.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota exists and but should not' {

                Mock Get-FsrmAutoQuota -MockWith { $Global:MockAutoQuota }
                Mock Get-FsrmQuotaTemplate

                It 'should return false' {
                    {
                        $Splat = $Global:TestAutoQuota.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
                }
            }

            Context 'auto quota does not exist and should not' {

                Mock Get-FsrmAutoQuota
                Mock Get-FsrmQuotaTemplate

                It 'should return true' {
                    {
                        $Splat = $Global:TestAutoQuota.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmAutoQuota -Exactly 1
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