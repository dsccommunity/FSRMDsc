data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingFileScreenTemplateMessage=Getting FSRM File Screen Template "{0}".
FileScreenTemplateExistsMessage=FSRM File Screen Template "{0}" exists.
FileScreenTemplateDoesNotExistMessage=FSRM File Screen Template "{0}" does not exist.
SettingFileScreenTemplateMessage=Setting FSRM File Screen Template "{0}".
EnsureFileScreenTemplateExistsMessage=Ensuring FSRM File Screen Template "{0}" exists.
EnsureFileScreenTemplateDoesNotExistMessage=Ensuring FSRM File Screen Template "{0}" does not exist.
FileScreenTemplateCreatedMessage=FSRM File Screen Template "{0}" has been created.
FileScreenTemplateUpdatedMessage=FSRM File Screen Template "{0}" has been updated.
FileScreenTemplateRemovedMessage=FSRM File Screen Template "{0}" has been removed.
TestingFileScreenTemplateMessage=Testing FSRM File Screen Template "{0}".
FileScreenTemplatePropertyNeedsUpdateMessage=FSRM File Screen Template "{0}" {1} is different. Change required.
FileScreenTemplateDoesNotExistButShouldMessage=FSRM File Screen Template "{0}" does not exist but should. Change required.
FileScreenTemplateExistsButShouldNotMessage=FSRM File Screen Template "{0}" exists but should not. Change required.
FileScreenTemplateDoesNotExistAndShouldNotMessage=FSRM File Screen Template "{0}" does not exist and should not. Change not required.
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
        $Name
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingFileScreenTemplateMessage) `
            -f $Name
        ) -join '' )

    # Lookup the existing template
    $FileScreenTemplate = Get-FileScreenTemplate -Name $Name

    $returnValue = @{
        Name = $Name
    }
    if ($FileScreenTemplate)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.FileScreenTemplateExistsMessage) `
                -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure = 'Present'
            Description = $FileScreenTemplate.Description
            Active = $FileScreenTemplate.Active
            IncludeGroup = @($FileScreenTemplate.IncludeGroup)
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.FileScreenTemplateDoesNotExistMessage) `
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

        [System.Boolean]
        $Active,

        [System.String[]]
        $IncludeGroup
    )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing FileScreen Template
    $FileScreenTemplate = Get-FileScreenTemplate -Name $Name

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureFileScreenTemplateExistsMessage) `
                -f $Name
            ) -join '' )

        if ($FileScreenTemplate)
        {
            # The File Screen template exists
            Set-FSRMFileScreenTemplate @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenTemplateUpdatedMessage) `
                    -f $Name
                ) -join '' )
        }
        else
        {
            # Create the FileScreen Template
            New-FSRMFileScreenTemplate @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenTemplateCreatedMessage) `
                    -f $Name
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureFileScreenTemplateDoesNotExistMessage) `
                -f $Name
            ) -join '' )

        if ($FileScreenTemplate)
        {
            # The FileScreen Template shouldn't exist - remove it
            Remove-FSRMFileScreenTemplate `
                -Name $Name `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenTemplateRemovedMessage) `
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

        [System.Boolean]
        $Active,

        [System.String[]]
        $IncludeGroup
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingFileScreenTemplateMessage) `
            -f $Name
        ) -join '' )

    # Lookup the existing FileScreen Template
    $FileScreenTemplate = Get-FileScreenTemplate -Name $Name

    if ($Ensure -eq 'Present')
    {
        # The FileScreen Template should exist
        if ($FileScreenTemplate)
        {
            # The FileScreen Template exists already - check the parameters
            if (($PSBoundParameters.ContainsKey('Description')) `
                -and ($FileScreenTemplate.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenTemplatePropertyNeedsUpdateMessage) `
                        -f $Name,'Description'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Active')) `
                -and ($FileScreenTemplate.Active -ne $Active))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenTemplatePropertyNeedsUpdateMessage) `
                        -f $Name,'Active'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('IncludeGroup')) `
                -and (Compare-Object `
                -ReferenceObject $IncludeGroup `
                -DifferenceObject $FileScreenTemplate.IncludeGroup).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenTemplatePropertyNeedsUpdateMessage) `
                        -f $Name,'IncludeGroup'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # Ths File Screen Template doesn't exist but should
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenTemplateDoesNotExistButShouldMessage) `
                    -f  $Name
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The File Screen Template should not exist
        if ($FileScreenTemplate)
        {
            # The File Screen Template exists but should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenTemplateExistsButShouldNotMessage) `
                    -f  $Name
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The File Screen Template does not exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenTemplateDoesNotExistAndShouldNotMessage) `
                    -f  $Name
                ) -join '' )
        }
    } # if
    return $desiredConfigurationMatch
} # Test-TargetResource

# Helper Functions

Function Get-FileScreenTemplate {
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    try
    {
        $FileScreenTemplate = Get-FSRMFileScreenTemplate `
            -Name $Name `
            -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $FileScreenTemplate = $null
    }
    catch
    {
        Throw $_
    }
    Return $FileScreenTemplate
}

Export-ModuleMember -Function *-TargetResource
