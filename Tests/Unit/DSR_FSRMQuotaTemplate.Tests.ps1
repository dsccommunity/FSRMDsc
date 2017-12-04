$script:DSCModuleName   = 'FSRMDsc'
$script:DSCResourceName = 'DSR_FSRMQuotaTemplate'

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
        $script:DSCResourceName = 'DSR_FSRMQuotaTemplate'

        # Create the Mock -CommandName Objects that will be used for running tests
        $script:TestQuotaTemplate = [PSObject]@{
            Name = '5 GB Limit'
            Description = '5 GB Hard Limit'
            Ensure = 'Present'
            Size = 5GB
            SoftLimit = $False
            ThresholdPercentages = [System.Collections.ArrayList]@( 85, 100 )
        }
        $script:Threshold1 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = $TestQuotaTemplate.ThresholdPercentages[0]
            }
        $script:Threshold2 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = $TestQuotaTemplate.ThresholdPercentages[1]
            }
        $script:MockQuotaTemplate = [PSObject]@{
            Name = $TestQuotaTemplate.Name
            Description = $TestQuotaTemplate.Description
            Size = $TestQuotaTemplate.Size
            SoftLimit = $TestQuotaTemplate.SoftLimit
            Threshold = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                $script:Threshold1, $script:Threshold2
            )
        }

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'No quota templates exist' {

                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return absent quota template' {
                    $Result = Get-TargetResource `
                        -Name $script:TestQuotaTemplate.Name
                    $Result.Ensure | Should -Be 'Absent'
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Requested quota template does exist' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { return @($script:MockQuotaTemplate) }

                It 'Should return correct quota template' {
                    $Result = Get-TargetResource `
                        -Name $script:TestQuotaTemplate.Name
                    $Result.Ensure | Should -Be 'Present'
                    $Result.Name | Should -Be $script:TestQuotaTemplate.Name
                    $Result.Description | Should -Be $script:TestQuotaTemplate.Description
                    $Result.ThresholdPercentages | Should -Be $script:TestQuotaTemplate.ThresholdPercentages
                }
                It 'Should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
        }

        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Context 'Quota template does not exist but should' {

                Mock -CommandName Get-FsrmQuotaTemplate
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and should but has a different Description' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and should but has a different Size' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.Size = $Splat.Size + 1GB
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and should but has a different SoftLimit' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.SoftLimit = (-not $Splat.SoftLimit)
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and should but has an additional threshold percentage' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and should but is missing a threshold percentage' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }

            Context 'Quota template exists and but should not' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template does not exist and should not' {

                Mock -CommandName Get-FsrmQuotaTemplate
                Mock -CommandName New-FsrmQuotaTemplate
                Mock -CommandName Set-FsrmQuotaTemplate
                Mock -CommandName Remove-FsrmQuotaTemplate

                It 'Should Not Throw error' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context 'Quota template does not exist but should' {

                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return false' {
                    $Splat = $script:TestQuotaTemplate.Clone()
                    Test-TargetResource @Splat | Should -Be $False

                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should but has a different Description' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should but has a different Size' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.Size = $Splat.Size + 1GB
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should but has a different SoftLimit' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.SoftLimit = (-not $Splat.SoftLimit)
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should but has an additional threshold percentage' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should but is missing a threshold percentage' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and should and all parameters match' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return true' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template exists and but should not' {

                Mock -CommandName Get-FsrmQuotaTemplate -MockWith { $script:MockQuotaTemplate }

                It 'Should return false' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should -Be $False
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }

            Context 'Quota template does not exist and should not' {

                Mock -CommandName Get-FsrmQuotaTemplate

                It 'Should return true' {
                    {
                        $Splat = $script:TestQuotaTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should -Be $True
                    } | Should -Not -Throw
                }
                It 'Should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
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
