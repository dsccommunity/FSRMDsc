$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

# Import Localization Strings
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        Retrieves the FSRM Quota Template with the specified Name.

    .PARAMETER Name
        The unique name for this FSRM Quota Template.
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
            $($script:localizedData.GettingQuotaTemplateMessage) `
                -f $Name
        ) -join '' )

    # Lookup the existing template
    $quotaTemplate = Get-QuotaTemplate -Name $Name

    $returnValue = @{
        Name = $Name
    }

    if ($quotaTemplate)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.QuotaTemplateExistsMessage) `
                    -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure               = 'Present'
            Description          = $quotaTemplate.Description
            Size                 = $quotaTemplate.Size
            SoftLimit            = $quotaTemplate.SoftLimit
            ThresholdPercentages = @($quotaTemplate.Threshold.Percentage)
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.QuotaTemplateDoesNotExistMessage) `
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
        Sets the FSRM Quota Template with the specified Name.

    .PARAMETER Name
        The unique name for this FSRM Quota Template.

    .PARAMETER Description
        An optional description for this FSRM Quota Template.

    .PARAMETER Ensure
        Specifies whether the FSRM Quota Template should exist.

    .PARAMETER Size
        The size in bytes of this FSRM Quota Template limit.

    .PARAMETER SoftLimit
        Controls whether this FSRM Quota Template has a hard or soft limit.

    .PARAMETER ThresholdPercentages
        An array of threshold percentages in this FSRM Quota Template.
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
        [System.Int64]
        $Size,

        [Parameter()]
        [System.Boolean]
        $SoftLimit,

        [Parameter()]
        [ValidateRange(0, 100)]
        [System.Uint32[]]
        $ThresholdPercentages
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($script:localizedData.SettingQuotaTemplateMessage) `
            -f $Name
    ) -join '' )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')
    $null = $PSBoundParameters.Remove('ThresholdPercentages')

    # Lookup the existing Quota Template
    $quotaTemplate = Get-QuotaTemplate -Name $Name

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureQuotaTemplateExistsMessage) `
                    -f $Name
            ) -join '' )

        # Assemble the Threshold Percentages
        if ($quotaTemplate)
        {
            $thresholds = [System.Collections.ArrayList]$quotaTemplate.Threshold
        }
        else
        {
            $thresholds = [System.Collections.ArrayList]@()
        }

        # Scan through the required thresholds and add any that are misssing
        foreach ($ThresholdPercentage in $ThresholdPercentages)
        {
            if ($ThresholdPercentage -notin $thresholds.Percentage)
            {
                # The threshold percentage is missing so add it
                $thresholds += New-FSRMQuotaThreshold -Percentage $ThresholdPercentage

                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.QuotaTemplateThresholdAddedMessage) `
                            -f $Name, $ThresholdPercentage
                    ) -join '' )
            }
        }

        # Scan through the existing thresholds and remove any that are misssing
        for ($counter = $thresholds.Count - 1; $counter -ge 0; $counter--)
        {
            if ($thresholds[$counter].Percentage -notin $ThresholdPercentages)
            {
                # The threshold percentage exists but shouldn not so remove it
                $thresholds.Remove($counter)

                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.QuotaTemplateThresholdRemovedMessage) `
                            -f $Name, $thresholds[$counter].Percentage
                    ) -join '' )
            }
        }

        if ($quotaTemplate)
        {
            # The quota template exists
            Set-FSRMQuotaTemplate @PSBoundParameters `
                -Threshold @($thresholds) `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.QuotaTemplateUpdatedMessage) `
                        -f $Name
                ) -join '' )
        }
        else
        {
            # Create the Quota Template
            New-FSRMQuotaTemplate @PSBoundParameters `
                -Threshold @($thresholds) `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.QuotaTemplateCreatedMessage) `
                        -f $Name
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureQuotaTemplateDoesNotExistMessage) `
                    -f $Name
            ) -join '' )

        if ($quotaTemplate)
        {
            # The Quota Template shouldn't exist - remove it
            Remove-FSRMQuotaTemplate -Name $Name -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.QuotaTemplateRemovedMessage) `
                        -f $Name
                ) -join '' )
        } # if
    } # if
} # Set-TargetResource

<#
    .SYNOPSIS
        Tests the FSRM Quota Template with the specified Name.

    .PARAMETER Name
        The unique name for this FSRM Quota Template.

    .PARAMETER Description
        An optional description for this FSRM Quota Template.

    .PARAMETER Ensure
        Specifies whether the FSRM Quota Template should exist.

    .PARAMETER Size
        The size in bytes of this FSRM Quota Template limit.

    .PARAMETER SoftLimit
        Controls whether this FSRM Quota Template has a hard or soft limit.

    .PARAMETER ThresholdPercentages
        An array of threshold percentages in this FSRM Quota Template.
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
        [System.Int64]
        $Size,

        [Parameter()]
        [System.Boolean]
        $SoftLimit,

        [Parameter()]
        [ValidateRange(0, 100)]
        [System.Uint32[]]
        $ThresholdPercentages
    )

    # Flag to signal whether settings are correct
    $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.TestingQuotaTemplateMessage) `
                -f $Name
        ) -join '' )

    # Lookup the existing Quota Template
    $quotaTemplate = Get-QuotaTemplate -Name $Name

    if ($Ensure -eq 'Present')
    {
        # The Quota Template should exist
        if ($quotaTemplate)
        {
            # The Quota Template exists already - check the parameters
            if (($PSBoundParameters.ContainsKey('Description')) `
                    -and ($quotaTemplate.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.QuotaTemplatePropertyNeedsUpdateMessage) `
                            -f $Name, 'Description'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Size')) `
                    -and ($quotaTemplate.Size -ne $Size))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.QuotaTemplatePropertyNeedsUpdateMessage) `
                            -f $Name, 'Size'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('SoftLimit')) `
                    -and ($quotaTemplate.SoftLimit -ne $SoftLimit))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.QuotaTemplatePropertyNeedsUpdateMessage) `
                            -f $Name, 'SoftLimit'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            # Check the threshold percentages
            if (($PSBoundParameters.ContainsKey('ThresholdPercentages')) `
                    -and (Compare-Object `
                        -ReferenceObject $ThresholdPercentages `
                        -DifferenceObject $quotaTemplate.Threshold.Percentage).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.QuotaTemplatePropertyNeedsUpdateMessage) `
                            -f $Name, 'ThresholdPercentages'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # Ths Quota Template doesn't exist but should
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.QuotaTemplateDoesNotExistButShouldMessage) `
                        -f $Name
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The Quota Template should not exist
        if ($quotaTemplate)
        {
            # The Quota Template exists but should not
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.QuotaTemplateExistsButShouldNotMessage) `
                        -f $Name
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
        else
        {
            # The Quota Template does not exist and should not
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.QuotaTemplateDoesNotExistAndShouldNotMessage) `
                        -f $Name
                ) -join '' )
        }
    } # if

    return $desiredConfigurationMatch
} # Test-TargetResource

<#
    .SYNOPSIS
        Gets the FSRM Quota Template with the specified Name.

    .PARAMETER Name
        The unique name for this FSRM Quota Template.
#>
function Get-QuotaTemplate
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    try
    {
        $quotaTemplate = Get-FSRMQuotaTemplate -Name $Name -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $quotaTemplate = $null
    }
    catch
    {
        throw $_
    }

    return $quotaTemplate
}

Export-ModuleMember -Function *-TargetResource
