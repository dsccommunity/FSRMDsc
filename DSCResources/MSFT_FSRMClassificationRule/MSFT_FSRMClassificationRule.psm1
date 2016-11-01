Import-Module -Name (Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath 'CommonResourceHelper.psm1')
$LocalizedData = Get-LocalizedData -ResourceName 'MSFT_FSRMClassificationRule'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingClassificationRuleMessage) `
            -f $Name
        ) -join '' )

    $ClassificationRule = Get-ClassificationRule -Name $Name

    $returnValue = @{
        Name = $Name
    }
    if ($ClassificationRule)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationRuleExistsMessage) `
                -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure = 'Present'
            Description = $ClassificationRule.Description
            Property = $ClassificationRule.Property
            PropertyValue = $ClassificationRule.PropertyValue
            ClassificationMechanism = $ClassificationRule.ClassificationMechanism
            ContentRegularExpression = $ClassificationRule.ContentRegularExpression
            ContentString = $ClassificationRule.ContentString
            ContentStringCaseSensitive = $ClassificationRule.ContentStringCaseSensitive
            Disabled = $ClassificationRule.Disabled
            Flags = $ClassificationRule.Flags
            Parameters = $ClassificationRule.Parameters
            Namespace = $ClassificationRule.Namespace
            ReevaluateProperty = $ClassificationRule.ReevaluateProperty
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationRuleDoesNotExistMessage) `
                -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure = 'Absent'
        }
    }

    $returnValue
} # Get-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Description,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]
        $Property,

        [System.String]
        $PropertyValue,

        [System.String]
        $ClassificationMechanism,

        [System.String[]]
        $ContentRegularExpression,

        [System.String[]]
        $ContentString,

        [System.String[]]
        $ContentStringCaseSensitive,

        [System.Boolean]
        $Disabled,

        [System.String[]]
        $Flags,

        [System.String[]]
        $Parameters,

        [System.String[]]
        $Namespace,

        [ValidateSet('Never','Overwrite','Aggregate')]
        [System.String]
        $ReevaluateProperty
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingClassificationRuleMessage) `
            -f $Name
        ) -join '' )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing Classification Rule
    $ClassificationRule = Get-ClassificationRule -Name $Name

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureClassificationRuleExistsMessage) `
                -f $Name
            ) -join '' )

        if ($ClassificationRule)
        {
            # The Classification Rule exists
            Set-FSRMClassificationRule @PSBoundParameters -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ClassificationRuleUpdatedMessage) `
                    -f $Name
                ) -join '' )
        }
        else
        {
            # Create the Classification Rule
            New-FSRMClassificationRule @PSBoundParameters -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ClassificationRuleCreatedMessage) `
                    -f $Name
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureClassificationRuleDoesNotExistMessage) `
                -f $Name
            ) -join '' )

        if ($ClassificationRule)
        {
            # The Classification Rule shouldn't exist - remove it
            Remove-FSRMClassificationRule -Name $Name -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ClassificationRuleRemovedMessage) `
                    -f $Name
                ) -join '' )
        } # if
    } # if
} # Set-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Description,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]
        $Property,

        [System.String]
        $PropertyValue,

        [System.String]
        $ClassificationMechanism,

        [System.String[]]
        $ContentRegularExpression,

        [System.String[]]
        $ContentString,

        [System.String[]]
        $ContentStringCaseSensitive,

        [System.Boolean]
        $Disabled,

        [System.String[]]
        $Flags,

        [System.String[]]
        $Parameters,

        [System.String[]]
        $Namespace,

        [ValidateSet('Never','Overwrite','Aggregate')]
        [System.String]
        $ReevaluateProperty
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingClassificationRuleMessage) `
            -f $Name
        ) -join '' )

    # Lookup the existing Classification Rule
    $ClassificationRule = Get-ClassificationRule -Name $Name

    if ($Ensure -eq 'Present')
    {
        # The Classification Rule should exist
        if ($ClassificationRule)
        {
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ClassificationRuleExistsAndShouldMessage) `
                    -f $Name
                ) -join '' )

            # The Classification Rule exists already - check the parameters
            if (($Description) -and ($ClassificationRule.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'Description'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($Property) -and ($ClassificationRule.Property -ne $Property))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'Property'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PropertyValue) -and ($ClassificationRule.PropertyValue -ne $PropertyValue))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'PropertyValue'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($ClassificationMechanism) `
                -and ($ClassificationRule.ClassificationMechanism -ne $ClassificationMechanism))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'ClassificationMechanism'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($ContentRegularExpression) `
                -and (Compare-Object `
                -ReferenceObject $ContentRegularExpression `
                -DifferenceObject $ClassificationRule.ContentRegularExpression).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'ContentRegularExpression'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($ContentString) `
                -and (Compare-Object `
                -ReferenceObject $ContentString `
                -DifferenceObject $ClassificationRule.ContentString).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'ContentString'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($ContentStringCaseSensitive) `
                -and (Compare-Object `
                -ReferenceObject $ContentStringCaseSensitive `
                -DifferenceObject $ClassificationRule.ContentStringCaseSensitive).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'ContentStringCaseSensitive'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($Disabled) -and ($ClassificationRule.Disabled -ne $Disabled))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'Disabled'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($Flags) `
                -and (Compare-Object `
                -ReferenceObject $Flags `
                -DifferenceObject ($ClassificationRule.Flags,@(),1 -ne $null)[0]).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'Flags'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($Parameters) `
                -and (Compare-Object `
                -ReferenceObject $Parameters `
                -DifferenceObject ($ClassificationRule.Parameters,@(),1 -ne $null)[0]).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'Parameters'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($Namespace) `
                -and (Compare-Object `
                -ReferenceObject $Namespace `
                -DifferenceObject $ClassificationRule.Namespace).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'Namespace'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($ReevaluateProperty) `
                -and ($ClassificationRule.ReevaluateProperty -ne $ReevaluateProperty))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationRuleNeedsUpdateMessage) `
                        -f $Name,'ReevaluateProperty'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # Ths Classification Rule doesn't exist but should
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.ClassificationRuleDoesNotExistButShouldMessage) `
                    -f  $Name
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The Classification Rule should not exist
        if ($ClassificationRule)
        {
            # The Classification Rule exists but should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.ClassificationRuleExistsButShouldNotMessage) `
                    -f  $Name
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The Classification Rule does not exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.ClassificationRuleDoesNotExistAndShouldNotMessage) `
                    -f  $Name
                ) -join '' )
        }
    } # if
    return $desiredConfigurationMatch
} # Test-TargetResource

# Helper Functions

Function Get-ClassificationRule {
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    try
    {
        $ClassificationRule = Get-FSRMClassificationRule -Name $Name -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $ClassificationRule = $null
    }
    catch
    {
        Throw $_
    }
    Return $ClassificationRule
}

Export-ModuleMember -Function *-TargetResource
