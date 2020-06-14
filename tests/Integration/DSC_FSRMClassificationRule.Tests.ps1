$script:dscModuleName = 'FSRMDsc'
$script:dscResourceName = 'DSC_FSRMclassificationRule'

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

try
{
    Describe 'FSRMAutoQuota Integration Tests' {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).Config.ps1"
        . $configFile

        Describe "$($script:dscResourceName)_Integration" {
            $configData = @{
                AllNodes = @(
                    @{
                        NodeName                   = 'localhost'
                        Name                       = 'IntegrationTest'
                        Description                = 'Test Rule Description'
                        ClassificationMechanism    = 'Content Classifier'
                        ContentRegularExpression   = @( 'Regex1', 'Regex2' )
                        ContentString              = @( 'String1', 'String2' )
                        ContentStringCaseSensitive = @( 'String1', 'String2' )
                        Disabled                   = $false
                        Flags                      = @( 1024 )
                        Namespace                  = @( '[FolderUsage_MS=User Files]', $ENV:Temp )
                        Parameters                 = @( 'FileName=*.doc', 'FSRMClearruleInternal=0', 'FSRMClearPropertyInternal=1024' )
                        Property                   = 'IntegrationTest'
                        PropertyValue              = 'Value1'
                        ReevaluateProperty         = 'Never'
                    }
                )
            }

            # Create the Classification Property that will be worked with
            New-FSRMClassificationPropertyDefinition `
                -Name $configData.AllNodes[0].Name `
                -Type 'SingleChoice' `
                -PossibleValue @(New-FSRMClassificationPropertyValue -Name 'Value1' )

            It 'Should compile and apply the MOF without throwing' {
                {
                    & "$($script:dscResourceName)_Config" `
                        -OutputPath $TestDrive `
                        -ConfigurationData $configData

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $current = Get-DscConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq "$($script:dscResourceName)_Config"
                }
                $current.Name | Should -Be $configData.AllNodes[0].Name
                $current.Description | Should -Be $configData.AllNodes[0].Description
                $current.ClassificationMechanism | Should -Be $configData.AllNodes[0].ClassificationMechanism
                $current.ContentRegularExpression | Should -Be $configData.AllNodes[0].ContentRegularExpression
                $current.ContentString | Should -Be $configData.AllNodes[0].ContentString
                $current.ContentStringCaseSenFsitive | Should -Be $configData.AllNodes[0].ContentStringCaseSensitive
                $current.Disabled | Should -Be $configData.AllNodes[0].Disabled
                $current.Flags | Should -Be 'ClearAutomaticallyClassifiedProperty'
                $current.Namespace | Should -Be $configData.AllNodes[0].Namespace
                $current.Parameters | Should -Be $configData.AllNodes[0].Parameters
                $current.Property | Should -Be $configData.AllNodes[0].Property
                $current.PropertyValue | Should -Be $configData.AllNodes[0].PropertyValue
                $current.ReevaluateProperty | Should -Be $configData.AllNodes[0].ReevaluateProperty
            }

            # Clean up
            Remove-FSRMClassificationRule `
                -Name $configData.AllNodes[0].Name `
                -Confirm:$false
            Remove-FSRMClassificationPropertyDefinition `
                -Name $configData.AllNodes[0].Name `
                -Confirm:$false
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
