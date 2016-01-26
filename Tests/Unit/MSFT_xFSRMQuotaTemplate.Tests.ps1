$Global:DSCModuleName   = 'xFSRM'
$Global:DSCResourceName = 'MSFT_xFSRMQuotaTemplate'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $Global:DSCResourceName {

        # Create the Mock Objects that will be used for running tests
        $Global:TestQuotaTemplate = [PSObject]@{
            Name = '5 GB Limit'
            Description = '5 GB Hard Limit'
            Ensure = 'Present'
            Size = 5GB
            SoftLimit = $False
            ThresholdPercentages = [System.Collections.ArrayList]@( 85, 100 )
        }
        $Global:Threshold1 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = $TestQuotaTemplate.ThresholdPercentages[0]
            }
        $Global:Threshold2 = New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = $TestQuotaTemplate.ThresholdPercentages[1]
            }
        $Global:MockQuotaTemplate = [PSObject]@{
            Name = $TestQuotaTemplate.Name
            Description = $TestQuotaTemplate.Description
            Size = $TestQuotaTemplate.Size
            SoftLimit = $TestQuotaTemplate.SoftLimit
            Threshold = [Microsoft.Management.Infrastructure.CimInstance[]]@(
                $Global:Threshold1, $Global:Threshold2
            )
        }
    
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
    
            Context 'No quota templates exist' {
                
                Mock Get-FsrmQuotaTemplate
    
                It 'should return absent quota template' {
                    $Result = Get-TargetResource `
                        -Name $Global:TestQuotaTemplate.Name
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
    
            Context 'Requested quota template does exist' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { return @($Global:MockQuotaTemplate) }
    
                It 'should return correct quota template' {
                    $Result = Get-TargetResource `
                        -Name $Global:TestQuotaTemplate.Name
                    $Result.Ensure | Should Be 'Present'
                    $Result.Name | Should Be $Global:TestQuotaTemplate.Name
                    $Result.Description | Should Be $Global:TestQuotaTemplate.Description
                    $Result.ThresholdPercentages | Should Be $Global:TestQuotaTemplate.ThresholdPercentages
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
        }
    
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
    
            Context 'Quota template does not exist but should' {
                
                Mock Get-FsrmQuotaTemplate
                Mock New-FsrmQuotaTemplate
                Mock Set-FsrmQuotaTemplate
                Mock Remove-FsrmQuotaTemplate
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }
    
            Context 'Quota template exists and should but has a different Description' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
                Mock New-FsrmQuotaTemplate
                Mock Set-FsrmQuotaTemplate
                Mock Remove-FsrmQuotaTemplate
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }
    
            Context 'Quota template exists and should but has a different Size' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
                Mock New-FsrmQuotaTemplate
                Mock Set-FsrmQuotaTemplate
                Mock Remove-FsrmQuotaTemplate
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.Size = $Splat.Size + 1GB
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }
    
            Context 'Quota template exists and should but has a different SoftLimit' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
                Mock New-FsrmQuotaTemplate
                Mock Set-FsrmQuotaTemplate
                Mock Remove-FsrmQuotaTemplate
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.SoftLimit = (-not $Splat.SoftLimit)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }
    
            Context 'Quota template exists and should but has an additional threshold percentage' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
                Mock New-FsrmQuotaTemplate
                Mock Set-FsrmQuotaTemplate
                Mock Remove-FsrmQuotaTemplate
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }
    
            Context 'Quota template exists and should but is missing a threshold percentage' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
                Mock New-FsrmQuotaTemplate
                Mock Set-FsrmQuotaTemplate
                Mock Remove-FsrmQuotaTemplate
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }
    
            Context 'Quota template exists and but should not' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
                Mock New-FsrmQuotaTemplate
                Mock Set-FsrmQuotaTemplate
                Mock Remove-FsrmQuotaTemplate
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 1
                }
            }
    
            Context 'Quota template does not exist and should not' {
                
                Mock Get-FsrmQuotaTemplate
                Mock New-FsrmQuotaTemplate
                Mock Set-FsrmQuotaTemplate
                Mock Remove-FsrmQuotaTemplate
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                    Assert-MockCalled -commandName New-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmQuotaTemplate -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmQuotaTemplate -Exactly 0
                }
            }
        }
    
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'Quota template does not exist but should' {
                
                Mock Get-FsrmQuotaTemplate
    
                It 'should return false' {
                    $Splat = $Global:TestQuotaTemplate.Clone()
                    Test-TargetResource @Splat | Should Be $False
                    
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
    
            Context 'Quota template exists and should but has a different Description' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
    
            Context 'Quota template exists and should but has a different Size' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.Size = $Splat.Size + 1GB
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
    
            Context 'Quota template exists and should but has a different SoftLimit' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.SoftLimit = (-not $Splat.SoftLimit)
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
    
            Context 'Quota template exists and should but has an additional threshold percentage' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 60, 85, 100 )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
    
            Context 'Quota template exists and should but is missing a threshold percentage' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
    
            Context 'Quota template exists and should and all parameters match' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
    
                It 'should return true' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
    
            Context 'Quota template exists and but should not' {
                
                Mock Get-FsrmQuotaTemplate -MockWith { $Global:MockQuotaTemplate }
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmQuotaTemplate -Exactly 1
                }
            }
    
            Context 'Quota template does not exist and should not' {
                
                Mock Get-FsrmQuotaTemplate
    
                It 'should return true' {
                    { 
                        $Splat = $Global:TestQuotaTemplate.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
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