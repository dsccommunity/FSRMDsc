$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

# Import Localization Strings
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        Retrieves the FSRM File Template with the specified Name.

    .PARAMETER Name
        The name of the FSRM File Template.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.GettingFileScreenTemplateMessage) `
                -f $Name
        ) -join '' )

    # Lookup the existing template
    $fileScreenTemplate = Get-FileScreenTemplate -Name $Name

    $returnValue = @{
        Name = $Name
    }

    if ($fileScreenTemplate)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.FileScreenTemplateExistsMessage) `
                    -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure       = 'Present'
            Description  = $fileScreenTemplate.Description
            Active       = $fileScreenTemplate.Active
            IncludeGroup = @($fileScreenTemplate.IncludeGroup)
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.FileScreenTemplateDoesNotExistMessage) `
                    -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure = 'Absent'
        }
    }

    return $returnValue
} # Get-TargetResource

<#
    .SYNOPSIS
        Sets the FSRM File Template with the specified Name.

    .PARAMETER Name
        The name of the FSRM File Template.

    .PARAMETER Description
        An optional description for this FSRM File Screen Template.

    .PARAMETER Ensure
        Specifies whether the FSRM File Screen Template should exist.

    .PARAMETER Active
        Boolean setting that controls if server should fail any I/O operations if the File
        Screen is violated.

    .PARAMETER IncludeGroup
        An array of File Groups to include in this File Screen.
#>
function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $Active,

        [Parameter()]
        [System.String[]]
        $IncludeGroup
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($script:localizedData.SettingFileScreenTemplateMessage) `
            -f $Name
    ) -join '' )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing FileScreen Template
    $fileScreenTemplate = Get-FileScreenTemplate -Name $Name

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureFileScreenTemplateExistsMessage) `
                    -f $Name
            ) -join '' )

        if ($fileScreenTemplate)
        {
            # The File Screen template exists
            Set-FSRMFileScreenTemplate @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileScreenTemplateUpdatedMessage) `
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
                    $($script:localizedData.FileScreenTemplateCreatedMessage) `
                        -f $Name
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureFileScreenTemplateDoesNotExistMessage) `
                    -f $Name
            ) -join '' )

        if ($fileScreenTemplate)
        {
            # The FileScreen Template shouldn't exist - remove it
            Remove-FSRMFileScreenTemplate `
                -Name $Name `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileScreenTemplateRemovedMessage) `
                        -f $Name
                ) -join '' )
        } # if
    } # if
} # Set-TargetResource

<#
    .SYNOPSIS
        Tests the FSRM File Template with the specified Name.

    .PARAMETER Name
        The name of the FSRM File Template.

    .PARAMETER Description
        An optional description for this FSRM File Screen Template.

    .PARAMETER Ensure
        Specifies whether the FSRM File Screen Template should exist.

    .PARAMETER Active
        Boolean setting that controls if server should fail any I/O operations if the File
        Screen is violated.

    .PARAMETER IncludeGroup
        An array of File Groups to include in this File Screen.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $Active,

        [Parameter()]
        [System.String[]]
        $IncludeGroup
    )

    # Flag to signal whether settings are correct
    $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.TestingFileScreenTemplateMessage) `
                -f $Name
        ) -join '' )

    # Lookup the existing FileScreen Template
    $fileScreenTemplate = Get-FileScreenTemplate -Name $Name

    if ($Ensure -eq 'Present')
    {
        # The FileScreen Template should exist
        if ($fileScreenTemplate)
        {
            # The FileScreen Template exists already - check the parameters
            if (($PSBoundParameters.ContainsKey('Description')) `
                    -and ($fileScreenTemplate.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.FileScreenTemplatePropertyNeedsUpdateMessage) `
                            -f $Name, 'Description'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Active')) `
                    -and ($fileScreenTemplate.Active -ne $Active))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.FileScreenTemplatePropertyNeedsUpdateMessage) `
                            -f $Name, 'Active'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('IncludeGroup')) `
                    -and (Compare-Object `
                        -ReferenceObject $IncludeGroup `
                        -DifferenceObject $fileScreenTemplate.IncludeGroup).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.FileScreenTemplatePropertyNeedsUpdateMessage) `
                            -f $Name, 'IncludeGroup'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # Ths File Screen Template doesn't exist but should
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileScreenTemplateDoesNotExistButShouldMessage) `
                        -f $Name
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The File Screen Template should not exist
        if ($fileScreenTemplate)
        {
            # The File Screen Template exists but should not
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileScreenTemplateExistsButShouldNotMessage) `
                        -f $Name
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
        else
        {
            # The File Screen Template does not exist and should not
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileScreenTemplateDoesNotExistAndShouldNotMessage) `
                        -f $Name
                ) -join '' )
        }
    } # if

    return $desiredConfigurationMatch
} # Test-TargetResource

<#
    .SYNOPSIS
        Gets the FSRM File Template Object with the specified Name.

    .PARAMETER Name
        The name of the FSRM File Template.
#>
function Get-FileScreenTemplate
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    try
    {
        $fileScreenTemplate = Get-FSRMFileScreenTemplate `
            -Name $Name `
            -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $fileScreenTemplate = $null
    }
    catch
    {
        throw $_
    }

    return $fileScreenTemplate
}

Export-ModuleMember -Function *-TargetResource
