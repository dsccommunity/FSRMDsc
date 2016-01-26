$Global:DSCModuleName      = 'xFSRM'
$Global:DSCResourceName    = 'MSFT_xFSRMclassificationRule'

#region HEADER (V2)
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git')
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Integration 
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Global:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($Global:DSCResourceName)_Integration" {
        # Create the Classification Property that will be worked with 
        New-FSRMClassificationPropertyDefinition `
            -Name $classificationProperty.Name `
            -Type $classificationProperty.Type `
            -PossibleValue @(New-FSRMClassificationPropertyValue -Name $classificationProperty.PossibleValue[0])

        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($Global:DSCResourceName)_Config -OutputPath `$TestEnvironment.WorkingFolder"
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            # Get the Rule details
            $classificationRuleNew = Get-FSRMclassificationRule -Name $classificationRule.Name
            $classificationRule.Name                       | Should Be  $classificationRuleNew.Name
            $classificationRule.Description                | Should Be  $classificationRuleNew.Description
            $classificationRule.ClassificationMechanism    | Should Be  $classificationRuleNew.ClassificationMechanism
            $classificationRule.ContentRegularExpression   | Should Be  $classificationRuleNew.ContentRegularExpression
            $classificationRule.ContentString              | Should Be  $classificationRuleNew.ContentString
            $classificationRule.ContentStringCaseSensitive | Should Be  $classificationRuleNew.ContentStringCaseSensitive
            $classificationRule.Disabled                   | Should Be  $classificationRuleNew.Disabled
            $classificationRule.Flags                      | Should Be  $classificationRuleNew.Flags
            $classificationRule.Namespace                  | Should Be  $classificationRuleNew.Namespace
            $classificationRule.Parameters                 | Should Be  $classificationRuleNew.Parameters
            $classificationRule.Property                   | Should Be  $classificationRuleNew.Property
            $classificationRule.PropertyValue              | Should Be  $classificationRuleNew.PropertyValue
            $classificationRule.ReevaluateProperty         | Should Be  $classificationRuleNew.ReevaluateProperty
        }
        
        # Clean up
        Remove-FSRMClassificationRule `
            -Name $classificationRule.Name `
            -Confirm:$false
        Remove-FSRMClassificationPropertyDefinition `
            -Name $classificationProperty.Name `
            -Confirm:$false
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
