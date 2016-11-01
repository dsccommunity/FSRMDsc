Import-Module -Name (Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath 'CommonResourceHelper.psm1')
$LocalizedData = Get-LocalizedData -ResourceName 'MSFT_FSRMQuotaTemplate'

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
        $($LocalizedData.GettingQuotaTemplateMessage) `
            -f $Name
        ) -join '' )

    # Lookup the existing template
    $QuotaTemplate = Get-QuotaTemplate -Name $Name

    $returnValue = @{
        Name = $Name
    }
    if ($QuotaTemplate)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.QuotaTemplateExistsMessage) `
                -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure = 'Present'
            Description = $QuotaTemplate.Description
            Size = $QuotaTemplate.Size
            SoftLimit = $QuotaTemplate.SoftLimit
            ThresholdPercentages = @($QuotaTemplate.Threshold.Percentage)
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.QuotaTemplateDoesNotExistMessage) `
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Int64]
        $Size,

        [Parameter()]
        [System.Boolean]
        $SoftLimit,

        [Parameter()]
        [ValidateRange(0,100)]
        [System.Uint32[]]
        $ThresholdPercentages
    )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')
    $null = $PSBoundParameters.Remove('ThresholdPercentages')

    # Lookup the existing Quota Template
    $QuotaTemplate = Get-QuotaTemplate -Name $Name

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureQuotaTemplateExistsMessage) `
                -f $Name
            ) -join '' )

        # Assemble the Threshold Percentages
        if ($QuotaTemplate)
        {
            $Thresholds = [System.Collections.ArrayList]$QuotaTemplate.Threshold
        }
        else
        {
            $Thresholds = [System.Collections.ArrayList]@()
        }

        # Scan through the required thresholds and add any that are misssing
        foreach ($ThresholdPercentage in $ThresholdPercentages)
        {
            If ($ThresholdPercentage -notin $Thresholds.Percentage)
            {
                # The threshold percentage is missing so add it
                $Thresholds += New-FSRMQuotaThreshold -Percentage $ThresholdPercentage

                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.QuotaTemplateThresholdAddedMessage) `
                        -f $Name,$ThresholdPercentage
                    ) -join '' )
            }
        }

        # Scan through the existing thresholds and remove any that are misssing
        for ($i = $Thresholds.Count-1; $i -ge 0; $i--)
        {
            If ($Thresholds[$i].Percentage -notin $ThresholdPercentages)
            {
                # The threshold percentage exists but shouldn not so remove it
                $Thresholds.Remove($i)

                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.QuotaTemplateThresholdRemovedMessage) `
                        -f $Name,$Thresholds[$i].Percentage
                    ) -join '' )
            }
        }

        if ($QuotaTemplate)
        {
            # The quota template exists
            Set-FSRMQuotaTemplate @PSBoundParameters `
                -Threshold @($Thresholds) `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.QuotaTemplateUpdatedMessage) `
                    -f $Name
                ) -join '' )
        }
        else
        {
            # Create the Quota Template
            New-FSRMQuotaTemplate @PSBoundParameters `
                -Threshold @($Thresholds) `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.QuotaTemplateCreatedMessage) `
                    -f $Name
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureQuotaTemplateDoesNotExistMessage) `
                -f $Name
            ) -join '' )

        if ($QuotaTemplate)
        {
            # The Quota Template shouldn't exist - remove it
            Remove-FSRMQuotaTemplate -Name $Name -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.QuotaTemplateRemovedMessage) `
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Int64]
        $Size,

        [Parameter()]
        [System.Boolean]
        $SoftLimit,

        [Parameter()]
        [ValidateRange(0,100)]
        [System.Uint32[]]
        $ThresholdPercentages
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingQuotaTemplateMessage) `
            -f $Name
        ) -join '' )

    # Lookup the existing Quota Template
    $QuotaTemplate = Get-QuotaTemplate -Name $Name

    if ($Ensure -eq 'Present')
    {
        # The Quota Template should exist
        if ($QuotaTemplate)
        {
            # The Quota Template exists already - check the parameters
            if (($PSBoundParameters.ContainsKey('Description')) `
                -and ($QuotaTemplate.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.QuotaTemplatePropertyNeedsUpdateMessage) `
                        -f $Name,'Description'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Size')) `
                -and ($QuotaTemplate.Size -ne $Size))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.QuotaTemplatePropertyNeedsUpdateMessage) `
                        -f $Name,'Size'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('SoftLimit')) `
                -and ($QuotaTemplate.SoftLimit -ne $SoftLimit))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.QuotaTemplatePropertyNeedsUpdateMessage) `
                        -f $Name,'SoftLimit'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            # Check the threshold percentages
            if (($PSBoundParameters.ContainsKey('ThresholdPercentages')) `
                -and (Compare-Object `
                -ReferenceObject $ThresholdPercentages `
                -DifferenceObject $QuotaTemplate.Threshold.Percentage).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.QuotaTemplatePropertyNeedsUpdateMessage) `
                        -f $Name,'ThresholdPercentages'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # Ths Quota Template doesn't exist but should
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.QuotaTemplateDoesNotExistButShouldMessage) `
                    -f  $Name
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The Quota Template should not exist
        if ($QuotaTemplate)
        {
            # The Quota Template exists but should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.QuotaTemplateExistsButShouldNotMessage) `
                    -f  $Name
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The Quota Template does not exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.QuotaTemplateDoesNotExistAndShouldNotMessage) `
                    -f  $Name
                ) -join '' )
        }
    } # if
    return $desiredConfigurationMatch
} # Test-TargetResource

# Helper Functions

Function Get-QuotaTemplate
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    try
    {
        $QuotaTemplate = Get-FSRMQuotaTemplate -Name $Name -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $QuotaTemplate = $null
    }
    catch
    {
        Throw $_
    }
    Return $QuotaTemplate
}

Export-ModuleMember -Function *-TargetResource
