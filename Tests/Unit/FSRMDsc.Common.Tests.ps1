$script:ModuleName = 'FSRMDsc.Common'

Import-Module -Name (Join-Path -Path (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath 'TestHelpers') -ChildPath 'CommonTestHelper.psm1') -Global

#region HEADER
# Unit Test Template Version: 1.1.0
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
Import-Module (Join-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath $script:ModuleName)) -ChildPath "$script:ModuleName.psm1") -Force
#endregion HEADER

# Begin Testing
try
{
    InModuleScope $script:ModuleName {
        Describe 'FSRMDsc.Common\Test-IsNanoServer' {
            Context 'When the cmdlet Get-ComputerInfo does not exist' {
                BeforeAll {
                    Mock -CommandName Test-Command -MockWith {
                        return $false
                    }
                }

                Test-IsNanoServer | Should -Be $false
            }

            Context 'When the current computer is a Nano server' {
                BeforeAll {
                    Mock -CommandName Test-Command -MockWith {
                        return $true
                    }

                    Mock -CommandName Get-ComputerInfo -MockWith {
                        return @{
                            OsProductType = 'Server'
                            OsServerLevel = 'NanoServer'
                        }
                    }
                }

                Test-IsNanoServer | Should -Be $true
            }

            Context 'When the current computer is not a Nano server' {
                BeforeAll {
                    Mock -CommandName Test-Command -MockWith {
                        return $true
                    }

                    Mock -CommandName Get-ComputerInfo -MockWith {
                        return @{
                            OsProductType = 'Server'
                            OsServerLevel = 'FullServer'
                        }
                    }
                }

                Test-IsNanoServer | Should -Be $false
            }
        }

        Describe 'FSRMDsc.Common\Get-LocalizedData' {
            $mockTestPath = {
                return $mockTestPathReturnValue
            }

            $mockImportLocalizedData = {
                $BaseDirectory | Should -Be $mockExpectedLanguagePath
            }

            BeforeEach {
                Mock -CommandName Test-Path -MockWith $mockTestPath -Verifiable
                Mock -CommandName Import-LocalizedData -MockWith $mockImportLocalizedData -Verifiable
            }

            Context 'When loading localized data for Swedish' {
                $mockExpectedLanguagePath = 'sv-SE'
                $mockTestPathReturnValue = $true

                It 'Should call Import-LocalizedData with sv-SE language' {
                    Mock -CommandName Join-Path -MockWith {
                        return 'sv-SE'
                    } -Verifiable

                    { Get-LocalizedData -ResourceName 'DummyResource' } | Should -Not -Throw

                    Assert-MockCalled -CommandName Join-Path -Exactly -Times 3 -Scope It
                    Assert-MockCalled -CommandName Test-Path -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Import-LocalizedData -Exactly -Times 1 -Scope It
                }

                $mockExpectedLanguagePath = 'en-US'
                $mockTestPathReturnValue = $false

                It 'Should call Import-LocalizedData and fallback to en-US if sv-SE language does not exist' {
                    Mock -CommandName Join-Path -MockWith {
                        return $ChildPath
                    } -Verifiable

                    { Get-LocalizedData -ResourceName 'DummyResource' } | Should -Not -Throw

                    Assert-MockCalled -CommandName Join-Path -Exactly -Times 4 -Scope It
                    Assert-MockCalled -CommandName Test-Path -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Import-LocalizedData -Exactly -Times 1 -Scope It
                }

                Context 'When $ScriptRoot is set to a path' {
                    $mockExpectedLanguagePath = 'sv-SE'
                    $mockTestPathReturnValue = $true

                    It 'Should call Import-LocalizedData with sv-SE language' {
                        Mock -CommandName Join-Path -MockWith {
                            return 'sv-SE'
                        } -Verifiable

                        { Get-LocalizedData -ResourceName 'DummyResource' -ScriptRoot '.' } | Should -Not -Throw

                        Assert-MockCalled -CommandName Join-Path -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Test-Path -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Import-LocalizedData -Exactly -Times 1 -Scope It
                    }

                    $mockExpectedLanguagePath = 'en-US'
                    $mockTestPathReturnValue = $false

                    It 'Should call Import-LocalizedData and fallback to en-US if sv-SE language does not exist' {
                        Mock -CommandName Join-Path -MockWith {
                            return $ChildPath
                        } -Verifiable

                        { Get-LocalizedData -ResourceName 'DummyResource' -ScriptRoot '.' } | Should -Not -Throw

                        Assert-MockCalled -CommandName Join-Path -Exactly -Times 2 -Scope It
                        Assert-MockCalled -CommandName Test-Path -Exactly -Times 1 -Scope It
                        Assert-MockCalled -CommandName Import-LocalizedData -Exactly -Times 1 -Scope It
                    }
                }
            }

            Context 'When loading localized data for English' {
                Mock -CommandName Join-Path -MockWith {
                    return 'en-US'
                } -Verifiable

                $mockExpectedLanguagePath = 'en-US'
                $mockTestPathReturnValue = $true

                It 'Should call Import-LocalizedData with en-US language' {
                    { Get-LocalizedData -ResourceName 'DummyResource' } | Should -Not -Throw
                }
            }

            Assert-VerifiableMock
        }

        Describe 'FSRMDsc.Common\New-InvalidResultException' {
            Context 'When calling with Message parameter only' {
                It 'Should throw the correct error' {
                    $mockErrorMessage = 'Mocked error'

                    { New-InvalidResultException -Message $mockErrorMessage } | Should -Throw $mockErrorMessage
                }
            }

            Context 'When calling with both the Message and ErrorRecord parameter' {
                It 'Should throw the correct error' {
                    $mockErrorMessage = 'Mocked error'
                    $mockExceptionErrorMessage = 'Mocked exception error message'

                    $mockException = New-Object -TypeName System.Exception -ArgumentList $mockExceptionErrorMessage
                    $mockErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $mockException, $null, 'InvalidResult', $null

                    { New-InvalidResultException -Message $mockErrorMessage -ErrorRecord $mockErrorRecord } | Should -Throw ('System.Exception: {0} ---> System.Exception: {1}' -f $mockErrorMessage, $mockExceptionErrorMessage)
                }
            }

            Assert-VerifiableMock
        }

        Describe 'FSRMDsc.Common\New-ObjectNotFoundException' {
            Context 'When calling with Message parameter only' {
                It 'Should throw the correct error' {
                    $mockErrorMessage = 'Mocked error'

                    { New-ObjectNotFoundException -Message $mockErrorMessage } | Should -Throw $mockErrorMessage
                }
            }

            Context 'When calling with both the Message and ErrorRecord parameter' {
                It 'Should throw the correct error' {
                    $mockErrorMessage = 'Mocked error'
                    $mockExceptionErrorMessage = 'Mocked exception error message'

                    $mockException = New-Object -TypeName System.Exception -ArgumentList $mockExceptionErrorMessage
                    $mockErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $mockException, $null, 'InvalidResult', $null

                    { New-ObjectNotFoundException -Message $mockErrorMessage -ErrorRecord $mockErrorRecord } | Should -Throw ('System.Exception: {0} ---> System.Exception: {1}' -f $mockErrorMessage, $mockExceptionErrorMessage)
                }
            }

            Assert-VerifiableMock
        }

        Describe 'FSRMDsc.Common\New-InvalidOperationException' {
            Context 'When calling with Message parameter only' {
                It 'Should throw the correct error' {
                    $mockErrorMessage = 'Mocked error'

                    { New-InvalidOperationException -Message $mockErrorMessage } | Should -Throw $mockErrorMessage
                }
            }

            Context 'When calling with both the Message and ErrorRecord parameter' {
                It 'Should throw the correct error' {
                    $mockErrorMessage = 'Mocked error'
                    $mockExceptionErrorMessage = 'Mocked exception error message'

                    $mockException = New-Object -TypeName System.Exception -ArgumentList $mockExceptionErrorMessage
                    $mockErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $mockException, $null, 'InvalidResult', $null

                    { New-InvalidOperationException -Message $mockErrorMessage -ErrorRecord $mockErrorRecord } | Should -Throw ('System.InvalidOperationException: {0} ---> System.Exception: {1}' -f $mockErrorMessage, $mockExceptionErrorMessage)
                }
            }

            Assert-VerifiableMock
        }

        Describe 'FSRMDsc.Common\New-NotImplementedException' {
            Context 'When called with Message parameter only' {
                It 'Should throw the correct error' {
                    $mockErrorMessage = 'Mocked error'

                    { New-NotImplementedException -Message $mockErrorMessage } | Should -Throw $mockErrorMessage
                }
            }

            Context 'When called with both the Message and ErrorRecord parameter' {
                It 'Should throw the correct error' {
                    $mockErrorMessage = 'Mocked error'
                    $mockExceptionErrorMessage = 'Mocked exception error message'

                    $mockException = New-Object -TypeName System.Exception -ArgumentList $mockExceptionErrorMessage
                    $mockErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $mockException, $null, 'InvalidResult', $null

                    { New-NotImplementedException -Message $mockErrorMessage -ErrorRecord $mockErrorRecord } | Should -Throw ('System.NotImplementedException: {0} ---> System.Exception: {1}' -f $mockErrorMessage, $mockExceptionErrorMessage)
                }
            }

            Assert-VerifiableMock
        }

        Describe 'FSRMDsc.Common\New-InvalidArgumentException' {
            Context 'When calling with both the Message and ArgumentName parameter' {
                It 'Should throw the correct error' {
                    $mockErrorMessage = 'Mocked error'
                    $mockArgumentName = 'MockArgument'

                    { New-InvalidArgumentException -Message $mockErrorMessage -ArgumentName $mockArgumentName } | Should -Throw ('Parameter name: {0}' -f $mockArgumentName)
                }
            }

            Assert-VerifiableMock
        }

        Describe 'FSRMDsc.Common\Test-DscParameterState' {
            $verbose = $true

            Context 'When testing single values' {
                $currentValues = @{
                    String    = 'a string'
                    Bool      = $true
                    Int       = 99
                    Array     = 'a', 'b', 'c'
                    Hashtable = @{
                        k1 = 'Test'
                        k2 = 123
                        k3 = 'v1', 'v2', 'v3'
                    }
                }

                Context '== All match' {
                    $desiredValues = [PSObject] @{
                        String    = 'a string'
                        Bool      = $true
                        Int       = 99
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $true' {
                        $script:result | Should -Be $true
                    }
                }

                Context '!= string mismatch' {
                    $desiredValues = [PSObject] @{
                        String    = 'different string'
                        Bool      = $true
                        Int       = 99
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= boolean mismatch' {
                    $desiredValues = [PSObject] @{
                        String    = 'a string'
                        Bool      = $false
                        Int       = 99
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= int mismatch' {
                    $desiredValues = [PSObject] @{
                        String    = 'a string'
                        Bool      = $true
                        Int       = 1
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= Type mismatch' {
                    $desiredValues = [PSObject] @{
                        String = 'a string'
                        Bool   = $true
                        Int    = '99'
                        Array  = 'a', 'b', 'c'
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= Type mismatch but TurnOffTypeChecking is used' {
                    $desiredValues = [PSObject] @{
                        String = 'a string'
                        Bool   = $true
                        Int    = '99'
                        Array  = 'a', 'b', 'c'
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -TurnOffTypeChecking `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $true' {
                        $script:result | Should -Be $true
                    }
                }

                Context '== mismatches but valuesToCheck is used to exclude them' {
                    $desiredValues = [PSObject] @{
                        String = 'a string'
                        Bool   = $false
                        Int    = 1
                        Array  = @( 'a', 'b' )
                    }

                    $valuesToCheck = @(
                        'String'
                    )

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -ValuesToCheck $valuesToCheck `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $true' {
                        $script:result | Should -Be $true
                    }
                }
            }

            Context 'When testing array values' {
                $currentValues = @{
                    String    = 'a string'
                    Bool      = $true
                    Int       = 99
                    Array     = 'a', 'b', 'c', 1
                    Hashtable = @{
                        k1 = 'Test'
                        k2 = 123
                        k3 = 'v1', 'v2', 'v3'
                    }
                }

                Context '!= Array missing a value' {
                    $desiredValues = [PSObject]@{
                        String    = 'a string'
                        Bool      = $true
                        Int       = 1
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= Array has an additional value' {
                    $desiredValues = [PSObject] @{
                        String = 'a string'
                        Bool   = $true
                        Int    = 1
                        Array  = 'a', 'b', 'c', 1, 2
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= Array has a different value' {
                    $desiredValues = [PSObject] @{
                        String = 'a string'
                        Bool   = $true
                        Int    = 1
                        Array  = 'a', 'x', 'c', 1
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= Array has different order' {
                    $desiredValues = [PSObject] @{
                        String = 'a string'
                        Bool   = $true
                        Int    = 1
                        Array  = 'c', 'b', 'a', 1
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '== Array has different order but SortArrayValues is used' {
                    $desiredValues = [PSObject] @{
                        String = 'a string'
                        Bool   = $true
                        Int    = 1
                        Array  = 'c', 'b', 'a', 1
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -SortArrayValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }


                Context '!= Array has a value with a different type' {
                    $desiredValues = [PSObject] @{
                        String = 'a string'
                        Bool   = $true
                        Int    = 99
                        Array  = 'a', 'b', 'c', '1'
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '== Array has a value with a different type but TurnOffTypeChecking is used' {
                    $desiredValues = [PSObject] @{
                        String = 'a string'
                        Bool   = $true
                        Int    = 99
                        Array  = 'a', 'b', 'c', '1'
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -TurnOffTypeChecking `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $true' {
                        $script:result | Should -Be $true
                    }
                }
            }

            Context 'When testing hashtables' {
                $currentValues = @{
                    String    = 'a string'
                    Bool      = $true
                    Int       = 99
                    Array     = 'a', 'b', 'c'
                    Hashtable = @{
                        k1 = 'Test'
                        k2 = 123
                        k3 = 'v1', 'v2', 'v3', 99
                    }
                }

                Context '!= Hashtable missing a value' {
                    $desiredValues = [PSObject]@{
                        String    = 'a string'
                        Bool      = $true
                        Int       = 99
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= Hashtable has an additional value' {
                    $desiredValues = [PSObject]@{
                        String    = 'a string'
                        Bool      = $true
                        Int       = 99
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3', 99, 100
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= Hashtable has a different value' {
                    $desiredValues = [PSObject]@{
                        String    = 'a string'
                        Bool      = $true
                        Int       = 99
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'xx', 'v2', 'v3', 99
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= Array in hashtable has different order' {
                    $desiredValues = [PSObject]@{
                        String    = 'a string'
                        Bool      = $true
                        Int       = 99
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v3', 'v2', 'v1', 99
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '== Array in hashtable has different order but SortArrayValues is used' {
                    $desiredValues = [PSObject]@{
                        String    = 'a string'
                        Bool      = $true
                        Int       = 99
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v3', 'v2', 'v1', 99
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -SortArrayValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $true' {
                        $script:result | Should -Be $true
                    }
                }


                Context '!= Hashtable has a value with a different type' {
                    $desiredValues = [PSObject]@{
                        String    = 'a string'
                        Bool      = $true
                        Int       = 99
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3', '99'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '== Hashtable has a value with a different type but TurnOffTypeChecking is used' {
                    $desiredValues = [PSObject]@{
                        String    = 'a string'
                        Bool      = $true
                        Int       = 99
                        Array     = 'a', 'b', 'c'
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3', 99
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -TurnOffTypeChecking `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $true' {
                        $script:result | Should -Be $true
                    }
                }
            }

            Context 'When testing CimInstances / hashtables' {
                $currentValues = @{
                    String       = 'a string'
                    Bool         = $true
                    Int          = 99
                    Array        = 'a', 'b', 'c'
                    Hashtable    = @{
                        k1 = 'Test'
                        k2 = 123
                        k3 = 'v1', 'v2', 'v3', 99
                    }
                    CimInstances = [CimInstance[]](ConvertTo-CimInstance -Hashtable @{
                            String = 'a string'
                            Bool   = $true
                            Int    = 99
                            Array  = 'a, b, c'
                        })
                }

                Context '== Everything matches' {
                    $desiredValues = [PSObject]@{
                        String       = 'a string'
                        Bool         = $true
                        Int          = 99
                        Array        = 'a', 'b', 'c'
                        Hashtable    = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3', 99
                        }
                        CimInstances = [CimInstance[]](ConvertTo-CimInstance -Hashtable @{
                                String = 'a string'
                                Bool   = $true
                                Int    = 99
                                Array  = 'a, b, c'
                            })
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $true' {
                        $script:result | Should -Be $true
                    }
                }

                Context '== CimInstances missing a value in the desired state (not recognized)' {
                    $desiredValues = [PSObject]@{
                        String       = 'a string'
                        Bool         = $true
                        Int          = 99
                        Array        = 'a', 'b', 'c'
                        Hashtable    = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3', 99
                        }
                        CimInstances = @{
                            String = 'a string'
                            Bool   = $true
                            Array  = 'a, b, c'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $true' {
                        $script:result | Should -Be $true
                    }
                }

                Context '!= CimInstances missing a value in the desired state (recognized using ReverseCheck)' {
                    $desiredValues = [PSObject]@{
                        String       = 'a string'
                        Bool         = $true
                        Int          = 99
                        Array        = 'a', 'b', 'c'
                        Hashtable    = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3', 99
                        }
                        CimInstances = @{
                            String = 'a string'
                            Bool   = $true
                            Array  = 'a, b, c'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -ReverseCheck `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= CimInstances have an additional value' {
                    $desiredValues = [PSObject]@{
                        String       = 'a string'
                        Bool         = $true
                        Int          = 99
                        Array        = 'a', 'b', 'c'
                        Hashtable    = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3', 99
                        }
                        CimInstances = @{
                            String = 'a string'
                            Bool   = $true
                            Int    = 99
                            Array  = 'a, b, c'
                            Test   = 'Some string'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= CimInstances have a different value' {
                    $desiredValues = [PSObject]@{
                        String       = 'a string'
                        Bool         = $true
                        Int          = 99
                        Array        = 'a', 'b', 'c'
                        Hashtable    = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3', 99
                        }
                        CimInstances = @{
                            String = 'some other string'
                            Bool   = $true
                            Int    = 99
                            Array  = 'a, b, c'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '!= CimInstaces have a value with a different type' {
                    $desiredValues = [PSObject]@{
                        String       = 'a string'
                        Bool         = $true
                        Int          = 99
                        Array        = 'a', 'b', 'c'
                        Hashtable    = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3', 99
                        }
                        CimInstances = @{
                            String = 'a string'
                            Bool   = $true
                            Int    = '99'
                            Array  = 'a, b, c'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }

                Context '== CimInstaces have a value with a different type but TurnOffTypeChecking is used' {
                    $desiredValues = [PSObject]@{
                        String       = 'a string'
                        Bool         = $true
                        Int          = 99
                        Array        = 'a', 'b', 'c'
                        Hashtable    = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3', 99
                        }
                        CimInstances = @{
                            String = 'a string'
                            Bool   = $true
                            Int    = '99'
                            Array  = 'a, b, c'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -TurnOffTypeChecking `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $true' {
                        $script:result | Should -Be $true
                    }
                }
            }

            Context 'When reverse checking' {
                $currentValues = @{
                    String    = 'a string'
                    Bool      = $true
                    Int       = 99
                    Array     = 'a', 'b', 'c', 1
                    Hashtable = @{
                        k1 = 'Test'
                        k2 = 123
                        k3 = 'v1', 'v2', 'v3'
                    }
                }

                Context '== even if missing property in the desired state' {
                    $desiredValues = [PSObject] @{
                        Array     = 'a', 'b', 'c', 1
                        Hashtable = @{
                            k1 = 'Test'
                            k2 = 123
                            k3 = 'v1', 'v2', 'v3'
                        }
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $true' {
                        $script:result | Should -Be $true
                    }
                }

                Context '!= missing property in the desired state' {
                    $currentValues = @{
                        String = 'a string'
                        Bool   = $true
                    }

                    $desiredValues = [PSObject] @{
                        String = 'a string'
                    }

                    It 'Should not throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -ReverseCheck `
                                -Verbose:$verbose } | Should -Not -Throw
                    }

                    It 'Should return $false' {
                        $script:result | Should -Be $false
                    }
                }
            }

            Context 'When testing parameter types' {

                Context 'When desired value is of the wrong type' {
                    $currentValues = @{
                        String = 'a string'
                    }

                    $desiredValues = 1, 2, 3

                    It 'Should throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Throw
                    }
                }

                Context 'When current value is of the wrong type' {
                    $currentValues = 1, 2, 3

                    $desiredValues = @{
                        String = 'a string'
                    }

                    It 'Should throw exception' {
                        { $script:result = Test-DscParameterState `
                                -CurrentValues $currentValues `
                                -DesiredValues $desiredValues `
                                -Verbose:$verbose } | Should -Throw
                    }
                }
            }
        }

        Describe 'FSRMDsc.Common\Test-DscObjectHasProperty' {
            # Use the Get-Verb cmdlet to just get a simple object fast
            $testDscObject = (Get-Verb)[0]

            Context 'The object contains the expected property' {
                It 'Should not throw exception' {
                    { $script:result = Test-DscObjectHasProperty -Object $testDscObject -PropertyName 'Verb' -Verbose } | Should -Not -Throw
                }

                It 'Should return $true' {
                    $script:result | Should -Be $true
                }
            }

            Context 'The object does not contain the expected property' {
                It 'Should not throw exception' {
                    { $script:result = Test-DscObjectHasProperty -Object $testDscObject -PropertyName 'Missing' -Verbose } | Should -Not -Throw
                }

                It 'Should return $false' {
                    $script:result | Should -Be $false
                }
            }
        }

        Describe 'FSRMDsc.Common\ConvertTo-CimInstance' {
            $hashtable = @{
                k1 = 'v1'
                k2 = 100
                k3 = 1, 2, 3
            }

            Context 'The array contains the expected record count' {
                It 'Should not throw exception' {
                    { $script:result = [CimInstance[]]($hashtable | ConvertTo-CimInstance) } | Should -Not -Throw
                }

                It "Record count should be $($hashTable.Count)" {
                    $script:result.Count | Should -Be $hashtable.Count
                }

                It 'Result should be of type CimInstance[]' {
                    $script:result.GetType().Name | Should -Be 'CimInstance[]'
                }

                It 'Value "k1" in the CimInstance array should be "v1"' {
                    ($script:result | Where-Object Key -eq k1).Value | Should -Be 'v1'
                }

                It 'Value "k2" in the CimInstance array should be "100"' {
                    ($script:result | Where-Object Key -eq k2).Value | Should -Be 100
                }

                It 'Value "k3" in the CimInstance array should be "1,2,3"' {
                    ($script:result | Where-Object Key -eq k3).Value | Should -Be '1,2,3'
                }
            }
        }

        Describe 'FSRMDsc.Common\ConvertTo-HashTable' {
            [CimInstance[]]$cimInstances = ConvertTo-CimInstance -Hashtable @{
                k1 = 'v1'
                k2 = 100
                k3 = 1, 2, 3
            }

            Context 'The array contains the expected record count' {
                It 'Should not throw exception' {
                    { $script:result = $cimInstances | ConvertTo-HashTable } | Should -Not -Throw
                }

                It "Record count should be $($cimInstances.Count)" {
                    $script:result.Count | Should -Be $cimInstances.Count
                }

                It 'Result should be of type [System.Collections.Hashtable]' {
                    $script:result | Should -BeOfType [System.Collections.Hashtable]
                }

                It 'Value "k1" in the hashtable should be "v1"' {
                    $script:result.k1 | Should -Be 'v1'
                }

                It 'Value "k2" in the hashtable should be "100"' {
                    $script:result.k2 | Should -Be 100
                }

                It 'Value "k3" in the hashtable should be "1,2,3"' {
                    $script:result.k3 | Should -Be '1,2,3'
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    #endregion
}
