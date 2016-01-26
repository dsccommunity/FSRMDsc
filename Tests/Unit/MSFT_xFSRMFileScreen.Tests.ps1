$Global:DSCModuleName   = 'xFSRM'
$Global:DSCResourceName = 'MSFT_xFSRMFileScreen'

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
        $Global:TestFileScreen = [PSObject]@{
            Path = $ENV:Temp
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            Active = $false
            IncludeGroup = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
            Template = 'Block Some Files'
            MatchesTemplate = $false
        }
    
        $Global:MockFileScreen = [PSObject]@{
            Path = $Global:TestFileScreen.Path
            Description = $Global:TestFileScreen.Description
            Active = $Global:TestFileScreen.Active
            IncludeGroup = $Global:TestFileScreen.IncludeGroup.Clone()
            Template = $Global:TestFileScreen.Template
            MatchesTemplate = $Global:TestFileScreen.MatchesTemplate
        }
        $Global:MockFileScreenMatch= $Global:MockFileScreen.Clone()
        $Global:MockFileScreenMatch.MatchesTemplate = $true
    
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
    
            Context 'No File Screens exist' {
                
                Mock Get-FsrmFileScreen
    
                It 'should return absent File Screen' {
                    $Result = Get-TargetResource `
                        -Path $Global:TestFileScreen.Path
                    $Result.Ensure | Should Be 'Absent'
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                } 
            }
    
            Context 'Requested File Screen does exist' {
                
                Mock Get-FsrmFileScreen -MockWith { return @($Global:MockFileScreen) }
    
                It 'should return correct File Screen' {
                    $Result = Get-TargetResource `
                        -Path $Global:TestFileScreen.Path
                    $Result.Ensure | Should Be 'Present'
                    $Result.Path | Should Be $Global:TestFileScreen.Path
                    $Result.Description | Should Be $Global:TestFileScreen.Description
                    $Result.IncludeGroup | Should Be $Global:TestFileScreen.IncludeGroup
                    $Result.Active | Should Be $Global:TestFileScreen.Active
                    $Result.Template | Should Be $Global:TestFileScreen.Template
                    $Result.MatchesTemplate | Should Be $Global:TestFileScreen.MatchesTemplate
                }
                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
        }
    
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
    
            Context 'File Screen does not exist but should' {
                
                Mock Get-FsrmFileScreen
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 0
                }
            }
    
            Context 'File Screen exists and should but has a different Description' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.Description = 'Different'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 0
                }
            }
    
            Context 'File Screen exists and should but has a different Active' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.Active = (-not $Splat.Active)
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 0
                }
            }
    
            Context 'File Screen exists and should but has a different IncludeGroup' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.IncludeGroup = @( 'Different' )
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 0
                }
            }
    
            Context 'File Screen exists and but should not' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 1
                }
            }
    
            Context 'File Screen does not exist and should not' {
                
                Mock Get-FsrmFileScreen
                Mock New-FsrmFileScreen
                Mock Set-FsrmFileScreen
                Mock Remove-FsrmFileScreen
    
                It 'should not throw error' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                        Set-TargetResource @Splat
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                    Assert-MockCalled -commandName New-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Set-FsrmFileScreen -Exactly 0
                    Assert-MockCalled -commandName Remove-FsrmFileScreen -Exactly 0
                }
            }
        }
    
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context 'File Screen path does not exist' {
                Mock Get-FsrmFileScreenTemplate
                Mock Test-Path -MockWith { $false }
    
                It 'should throw an FileScreenPathDoesNotExistError exception' {
                    $Splat = $Global:TestFileScreen.Clone()
    
                    $errorId = 'FileScreenPathDoesNotExistError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenPathDoesNotExistError) -f $Splat.Path
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
    
                    { Test-TargetResource @Splat } | Should Throw $errorRecord                
                }
            }
    
            Context 'FileScreen template does not exist' {
                Mock Get-FSRMFileScreenTemplate -MockWith { throw (New-Object -TypeName Microsoft.PowerShell.Cmdletization.Cim.CimJobException) }
                
                It 'should throw an FileScreenTemplateNotFoundError exception' {
                    $Splat = $Global:TestFileScreen.Clone()
    
                    $errorId = 'FileScreenTemplateNotFoundError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenTemplateNotFoundError) -f $Splat.Path,$Splat.Template
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
    
                    { Test-TargetResource @Splat } | Should Throw $errorRecord                
                }
            }
    
            Context 'File Screen template not specified but MatchesTemplate is true' {           
                It 'should throw an FileScreenTemplateEmptyError exception' {
                    $Splat = $Global:TestFileScreen.Clone()
                    $Splat.MatchesTemplate = $True
                    $Splat.Template = ''
    
                    $errorId = 'FileScreenTemplateEmptyError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                    $errorMessage = $($LocalizedData.FileScreenTemplateEmptyError) -f $Splat.Path
                    $exception = New-Object -TypeName System.InvalidOperationException `
                        -ArgumentList $errorMessage
                    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                        -ArgumentList $exception, $errorId, $errorCategory, $null
    
                    { Test-TargetResource @Splat } | Should Throw $errorRecord                
                }
            }
    
            Context 'File Screen does not exist but should' {
                
                Mock Get-FsrmFileScreen
                Mock Get-FsrmFileScreenTemplate
    
                It 'should return false' {
                    $Splat = $Global:TestFileScreen.Clone()
                    Test-TargetResource @Splat | Should Be $False
                    
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
    
            Context 'File Screen exists and should but has a different Description' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.Description = 'Different'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
    
            Context 'File Screen exists and should but has a different Active' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.Active = (-not $Splat.Active)
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
    
            Context 'File Screen exists and should but has a different IncludeGroup' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.IncludeGroup = @( 'Different' )
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
    
            Context 'File Screen exists and should but has a different Template' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.Template = 'Block Image Files'
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
    
            Context 'File Screen exists and should and MatchesTemplate is set but does not match' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.MatchesTemplate = $true
                        Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
    
            Context 'File Screen exists and should and MatchesTemplate is set and does match' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreenMatch }
                Mock Get-FsrmFileScreenTemplate
    
                It 'should return true' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.MatchesTemplate = $true
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
    
            Context 'File Screen exists and should and all parameters match' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate
    
                It 'should return true' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
    
            Context 'File Screen exists and but should not' {
                
                Mock Get-FsrmFileScreen -MockWith { $Global:MockFileScreen }
                Mock Get-FsrmFileScreenTemplate
    
                It 'should return false' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                    Test-TargetResource @Splat | Should Be $False
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
                }
            }
    
            Context 'File Screen does not exist and should not' {
                
                Mock Get-FsrmFileScreen
                Mock Get-FsrmFileScreenTemplate
    
                It 'should return true' {
                    { 
                        $Splat = $Global:TestFileScreen.Clone()
                        $Splat.Ensure = 'Absent'
                        Test-TargetResource @Splat | Should Be $True
                    } | Should Not Throw
                }
                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-FsrmFileScreen -Exactly 1
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