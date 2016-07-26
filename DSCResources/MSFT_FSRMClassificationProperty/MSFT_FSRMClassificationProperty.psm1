data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingClassificationPropertyMessage=Getting FSRM Classification Property Definition "{0}".
ClassificationPropertyExistsMessage=FSRM Classification Property Definition "{0}" exists.
ClassificationPropertyDoesNotExistMessage=FSRM Classification Property Definition "{0}" does not exist.
SettingClassificationPropertyMessage=Setting FSRM Classification Property Definition "{0}".
EnsureClassificationPropertyExistsMessage=Ensuring FSRM Classification Property Definition "{0}" exists.
EnsureClassificationPropertyDoesNotExistMessage=Ensuring FSRM Classification Property Definition "{0}" does not exist.
ClassificationPropertyCreatedMessage=FSRM Classification Property Definition "{0}" has been created.
ClassificationPropertyUpdatedMessage=FSRM Classification Property Definition "{0}" has been updated.
ClassificationPropertyRecreatedMessage=FSRM Classification Property Definition "{0}" has been recreated.
ClassificationPropertyRemovedMessage=FSRM Classification Property Definition "{0}" has been removed.
TestingClassificationPropertyMessage=Testing FSRM Classification Property Definition "{0}".
ClassificationPropertyNeedsUpdateMessage=FSRM Classification Property Definition "{0}" {1} is different. Change required.
ClassificationPropertyDoesNotExistButShouldMessage=FSRM Classification Property Definition "{0}" does not exist but should. Change required.
ClassificationPropertyExistsButShouldNotMessage=FSRM Classification Property Definition "{0}" exists but should not. Change required.
ClassificationPropertyDoesNotExistAndShouldNotMessage=FSRM Classification Property Definition "{0}" does not exist and should not. Change not required.
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateSet('OrderedList','MultiChoice','SingleChoice','String','MultiString','Integer','YesNo','DateTime')]
        [Parameter(Mandatory = $true)]
        [System.String]
        $Type
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingClassificationPropertyMessage) `
            -f $Name
        ) -join '' )

    $ClassificationProperty = Get-ClassificationProperty -Name $Name

    $returnValue = @{
        Name = $Name
    }
    if ($ClassificationProperty)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationPropertyExistsMessage) `
                -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure = 'Present'
            DisplayName = $ClassificationProperty.DisplayName
            Description = $ClassificationProperty.Description
            Type = $ClassificationProperty.Type
            PossibleValue = $ClassificationProperty.PossibleValue.Name
            Parameters = $ClassificationProperty.Parameters
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationPropertyDoesNotExistMessage) `
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

        [ValidateSet('OrderedList','MultiChoice','SingleChoice','String','MultiString','Integer','YesNo','DateTime')]
        [Parameter(Mandatory = $true)]
        [System.String]
        $Type,

        [System.String]
        $DisplayName,

        [System.String]
        $Description,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String[]]
        $PossibleValue,

        [System.String[]]
        $Parameters
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingClassificationPropertyMessage) `
            -f $Name
        ) -join '' )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing Classification Property
    $ClassificationProperty = Get-ClassificationProperty -Name $Name

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureClassificationPropertyExistsMessage) `
                -f $Name
            ) -join '' )

        # Assemble an ArrayList of MSFT_FSRMClassificationPropertyDefinitionValue if
        # the PossibleValue parameter was passed
        $NewPossibleValue = @()
        if ($PSBoundParameters.ContainsKey('PossibleValue'))
        {
            foreach ($p in $PossibleValue)
            {
                $NewPossibleValue += @(New-FSRMClassificationPropertyValue -Name $p)
            }
        }
        $null = $PSBoundParameters.Remove('PossibleValue')

        if ($ClassificationProperty) {
            # The Classification Property exists

            # Copy the descriptions from any existing Possible Value items into the
            # Descriptions of any of the matching Possible Values that were passed
            foreach ($p in $NewPossibleValue)
            {
                foreach ($q in $ClassificationProperty.PossibleValue)
                {
                    if ($p.Name -eq $q.Name)
                    {
                        # PossibleValue already exists - copy the description
                        $p.Description = $q.Description
                    }
                }
            }

            # Do we need to assign any PossibleValues?
            if ($NewPossibleValue.Count -gt 0)
            {
                $null = $PSBoundParameters.Add('PossibleValue',$NewPossibleValue)
            }

            # Is the type specified and different?
            if ($PSBoundParameters.ContainsKey('Type') `
                -and ($Type -ne $ClassificationProperty.Type))
            {
                # The type is different so the Classification Property needs to be removed
                # and re-created.
                Remove-FSRMClassificationPropertyDefinition -Name $Name -ErrorAction Stop
                New-FSRMClassificationPropertyDefinition @PSBoundParameters -ErrorAction Stop

                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationPropertyRecreatedMessage) `
                        -f $Name
                    ) -join '' )
            }
            else
            {
                $null = $PSBoundParameters.Remove('Type')
                Set-FSRMClassificationPropertyDefinition @PSBoundParameters -ErrorAction Stop
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationPropertyUpdatedMessage) `
                        -f $Name
                    ) -join '' )
            }
        }
        else
        {
            # Do we need to assign any PossibleValues?
            if ($NewPossibleValue.Count -gt 0)
            {
                $null = $PSBoundParameters.Add('PossibleValue',$NewPossibleValue)
            }

            # Create the Classification Property
            New-FSRMClassificationPropertyDefinition @PSBoundParameters -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ClassificationPropertyCreatedMessage) `
                    -f $Name
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureClassificationPropertyDoesNotExistMessage) `
                -f $Name
            ) -join '' )

        if ($ClassificationProperty)
        {
            # The Classification Property shouldn't exist - remove it
            Remove-FSRMClassificationPropertyDefinition -Name $Name -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ClassificationPropertyRemovedMessage) `
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

        [ValidateSet('OrderedList','MultiChoice','SingleChoice','String','MultiString','Integer','YesNo','DateTime')]
        [Parameter(Mandatory = $true)]
        [System.String]
        $Type,

        [System.String]
        $DisplayName,

        [System.String]
        $Description,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String[]]
        $PossibleValue,

        [System.String[]]
        $Parameters
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingClassificationPropertyMessage) `
            -f $Name
        ) -join '' )

    # Lookup the existing Classification Property
    $ClassificationProperty = Get-ClassificationProperty -Name $Name

    if ($Ensure -eq 'Present')
    {
        # The Classification Property should exist
        if ($ClassificationProperty)
        {
            # The Classification Property exists already - check the parameters
            if (($Description) -and ($ClassificationProperty.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationPropertyNeedsUpdateMessage) `
                        -f $Name,'Description'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($DisplayName) -and ($ClassificationProperty.DisplayName -ne $DisplayName))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationPropertyNeedsUpdateMessage) `
                        -f $Name,'DisplayName'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($Type) -and ($ClassificationProperty.Type -ne $Type))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationPropertyNeedsUpdateMessage) `
                        -f $Name,'Type'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            # Logic: If Parameters is provided and is different to existing parameters.
            if (($Parameters) `
                -and (Compare-Object `
                -ReferenceObject $Parameters `
                -DifferenceObject ($ClassificationProperty.Parameters,@(),1 -ne $null)[0]).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationPropertyNeedsUpdateMessage) `
                        -f $Name,'Parameters'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PossibleValue) `
                -and (Compare-Object `
                -ReferenceObject $PossibleValue `
                -DifferenceObject $ClassificationProperty.PossibleValue.Name).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ClassificationPropertyNeedsUpdateMessage) `
                        -f $Name,'PossibleValue'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

        }
        else
        {
            # Ths Classification Property doesn't exist but should
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.ClassificationPropertyDoesNotExistButShouldMessage) `
                    -f  $Name
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The Classification Property should not exist
        if ($ClassificationProperty)
        {
            # The Classification Property exists but should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.ClassificationPropertyExistsButShouldNotMessage) `
                    -f  $Name
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The Classification Property does not exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.ClassificationPropertyDoesNotExistAndShouldNotMessage) `
                    -f  $Name
                ) -join '' )
        }
    } # if
    return $desiredConfigurationMatch
} # Test-TargetResource

# Helper Functions

Function Get-ClassificationProperty {
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    try
    {
        $ClassificationProperty = Get-FSRMClassificationPropertyDefinition `
            -Name $Name `
            -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $ClassificationProperty = $null
    }
    catch
    {
        Throw $_
    }
    Return $ClassificationProperty
}

Export-ModuleMember -Function *-TargetResource
