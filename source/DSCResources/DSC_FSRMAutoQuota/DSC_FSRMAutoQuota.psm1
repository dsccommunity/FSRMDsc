$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

# Import Localization Strings
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        Retrieves the current state of the FSRM Auto Quota applied to the specified path.

    .PARAMETER Path
        The path this FSRM Quota applies to.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.GettingAutoQuotaMessage) `
                -f $Path
        ) -join '' )

    # Lookup the existing auto quota
    $autoQuota = Get-AutoQuota -Path $Path

    $returnValue = @{
        Path = $Path
    }

    if ($autoQuota)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.AutoQuotaExistsMessage) `
                    -f $Path
            ) -join '' )

        $returnValue += @{
            Ensure   = 'Present'
            Disabled = $AutoQuota.Disabled
            Template = $AutoQuota.Template
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.AutoQuotaDoesNotExistMessage) `
                    -f $Path
            ) -join '' )

        $returnValue += @{
            Ensure = 'Absent'
        }
    }

    return $returnValue
} # Get-TargetResource

<#
    .SYNOPSIS
        Sets the current state of the FSRM Auto Quota applied to the specified path.

    .PARAMETER Path
        The path this FSRM Quota applies to.

    .PARAMETER Ensure
        Specifies whether the FSRM Quota should exist.

    .PARAMETER Disabled
        Disables the FSRM Quota applied to this path.

    .PARAMETER Template
        The name of the FSRM Quota Template to apply to this path.
#>
function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $Disabled,

        [Parameter()]
        [System.String]
        $Template
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.SettingAutoQuotaMessage) `
                -f $Path
        ) -join '' )

    # Check the properties are valid.
    Assert-ResourcePropertiesValid @PSBoundParameters

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing Auto Quota
    $autoQuota = Get-AutoQuota -Path $Path

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureAutoQuotaExistsMessage) `
                    -f $Path
            ) -join '' )

        if ($autoQuota)
        {
            # The Auto Quota exists
            Set-FSRMAutoQuota @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AutoQuotaUpdatedMessage) `
                        -f $Path
                ) -join '' )
        }
        else
        {
            # Create the Auto Quota
            New-FSRMAutoQuota @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AutoQuotaCreatedMessage) `
                        -f $Path
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureAutoQuotaDoesNotExistMessage) `
                    -f $Path
            ) -join '' )

        if ($autoQuota)
        {
            # The Auto Quota shouldn't exist - remove it
            Remove-FSRMAutoQuota -Path $Path -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AutoQuotaRemovedMessage) `
                        -f $Path
                ) -join '' )
        } # if
    } # if
} # Set-TargetResource

<#
    .SYNOPSIS
        Tests the current state of the FSRM Auto Quota applied to the specified path.

    .PARAMETER Path
        The path this FSRM Quota applies to.

    .PARAMETER Ensure
        Specifies whether the FSRM Quota should exist.

    .PARAMETER Disabled
        Disables the FSRM Quota applied to this path.

    .PARAMETER Template
        The name of the FSRM Quota Template to apply to this path.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $Disabled,

        [Parameter()]
        [System.String]
        $Template
    )

    # Flag to signal whether settings are correct
    $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.TestingAutoQuotaMessage) `
                -f $Path
        ) -join '' )

    # Check the properties are valid.
    Assert-ResourcePropertiesValid @PSBoundParameters

    # Lookup the existing Quota
    $autoQuota = Get-AutoQuota -Path $Path

    if ($Ensure -eq 'Present')
    {
        # The Auto Quota should exist
        if ($autoQuota)
        {
            # The Auto Quota exists already - check the parameters
            if (($PSBoundParameters.ContainsKey('Disabled')) `
                    -and ($autoQuota.Disabled -ne $Disabled))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.AutoQuotaPropertyNeedsUpdateMessage) `
                            -f $Path, 'Disabled'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Template')) `
                    -and ($autoQuota.Template -ne $Template))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.AutoQuotaPropertyNeedsUpdateMessage) `
                            -f $Path, 'Template'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # Ths Auto Quota doesn't exist but should
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AutoQuotaDoesNotExistButShouldMessage) `
                        -f $Path
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The Auto Quota should not exist
        if ($autoQuota)
        {
            # The Auto Quota exists but should not
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AutoQuotaExistsButShouldNotMessage) `
                        -f $Path
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
        else
        {
            # The Auto Quota does not exist and should not
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AutoQuotaDoesNotExistAndShouldNotMessage) `
                        -f $Path
                ) -join '' )
        }
    } # if

    return $desiredConfigurationMatch
} # Test-TargetResource

<#
    .SYNOPSIS
        Retrieves the Auto Quota assigned to a specific path,

    .PARAMETER Path
        The path this FSRM Quota applies to.
#>
function Get-AutoQuota
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )
    try
    {
        $autoQuota = Get-FSRMAutoQuota -Path $Path -ErrorAction Stop
    }
    catch [Microsoft.Management.Infrastructure.CimException]
    {
        $autoQuota = $null
    }
    catch
    {
        throw $_
    }

    return $autoQuota
}

<#
    .SYNOPSIS
        This function validates the parameters passed. Called by Test-Resource.
        Will throw an error if any parameters are invalid.

    .PARAMETER Path
        The path this FSRM Quota applies to.

    .PARAMETER Ensure
        Specifies whether the FSRM Quota should exist.

    .PARAMETER Disabled
        Disables the FSRM Quota applied to this path.

    .PARAMETER Template
        The name of the FSRM Quota Template to apply to this path.
#>
function Assert-ResourcePropertiesValid
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $Disabled,

        [Parameter()]
        [System.String]
        $Template
    )

    # Check the path exists
    if (-not (Test-Path -Path $Path))
    {
        $errorMessage = $($script:localizedData.AutoQuotaPathDoesNotExistError) -f $Path
        $errorArgumentName = 'Path'
    }

    if ($Ensure -eq 'Absent')
    {
        # No further checks required if Auto Quota should be removed.
        return
    }

    if ($Template)
    {
        # Check the template exists
        try
        {
            $null = Get-FSRMQuotaTemplate -Name $Template -ErrorAction Stop
        }
        catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
        {
            $errorMessage = $($script:localizedData.AutoQuotaTemplateNotFoundError) -f $Path, $Template
            $errorArgumentName = 'Template'
        }
    }
    else
    {
        # A template wasn't specifed - it needs to be
        $errorMessage = $($script:localizedData.AutoQuotaTemplateEmptyError) -f $Path
        $errorArgumentName = 'Template'
    }

    if ($errorMessage)
    {
        New-InvalidArgumentException `
            -Message $errorMessage `
            -ArgumentName $errorArgumentName
    }
}

Export-ModuleMember -Function *-TargetResource
