$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the ADCS Deployment Resource Common Module.
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'FSRMDsc.Common' `
            -ChildPath 'FSRMDsc.Common.psm1'))

# Import Localization Strings.
$script:localizedData = Get-LocalizedData -ResourceName 'DSR_FSRMFileGroup'

<#
    .SYNOPSIS
        Retrieves the FSRM File Group with the specified Name.

    .PARAMETER Name
        The name of the FSRM File Group.
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
            $($script:localizedData.GettingFileGroupMessage) `
                -f $Name
        ) -join '' )

    $fileGroup = Get-FileGroup -Name $Name

    $returnValue = @{
        Name = $Name
    }

    if ($fileGroup)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.FileGroupExistsMessage) `
                    -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure         = 'Present'
            Description    = $fileGroup.Description
            IncludePattern = $fileGroup.IncludePattern
            ExcludePattern = $fileGroup.ExcludePattern
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.FileGroupDoesNotExistMessage) `
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
        Sets the FSRM File Group with the specified Name.

    .PARAMETER Name
        The name of the FSRM File Group.

    .PARAMETER Description
        The description for the FSRM File Group.

    .PARAMETER Ensure
        Specifies whether the FSRM File Group should exist.

    .PARAMETER IncludePattern
        An array of file patterns to include in this FSRM File Group.

    .PARAMETER ExcludePattern
        An array of file patterns to exclude in this FSRM File Group.
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
        [System.String[]]
        $IncludePattern = @(''),

        [Parameter()]
        [System.String[]]
        $ExcludePattern = @('')
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.SettingFileGroupMessage) `
                -f $Name
        ) -join '' )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing file group
    $fileGroup = Get-FileGroup -Name $Name

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureFileGroupExistsMessage) `
                    -f $Name
            ) -join '' )

        if ($fileGroup)
        {
            # The file group exists
            Set-FSRMFileGroup @PSBoundParameters -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileGroupUpdatedMessage) `
                        -f $Name
                ) -join '' )
        }
        else
        {
            # Create the File Group
            New-FSRMFileGroup @PSBoundParameters -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileGroupCreatedMessage) `
                        -f $Name
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureFileGroupDoesNotExistMessage) `
                    -f $Name
            ) -join '' )

        if ($fileGroup)
        {
            # The File Group shouldn't exist - remove it
            Remove-FSRMFileGroup -Name $Name -ErrorAction Stop

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileGroupRemovedMessage) `
                        -f $Name
                ) -join '' )
        } # if
    } # if
} # Set-TargetResource

<#
    .SYNOPSIS
        Tests the FSRM File Group with the specified Name.

    .PARAMETER Name
        The name of the FSRM File Group.

    .PARAMETER Description
        The description for the FSRM File Group.

    .PARAMETER Ensure
        Specifies whether the FSRM File Group should exist.

    .PARAMETER IncludePattern
        An array of file patterns to include in this FSRM File Group.

    .PARAMETER ExcludePattern
        An array of file patterns to exclude in this FSRM File Group.
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
        [System.String[]]
        $IncludePattern = @(''),

        [Parameter()]
        [System.String[]]
        $ExcludePattern = @('')
    )

    # Flag to signal whether settings are correct
    $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.TestingFileGroupMessage) `
                -f $Name
        ) -join '' )

    # Lookup the existing file group
    $fileGroup = Get-FileGroup -Name $Name

    if ($Ensure -eq 'Present')
    {
        # The File Group should exist
        if ($fileGroup)
        {
            # The File Group exists already - check the parameters
            if (($Description) -and ($fileGroup.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.FileGroupDescriptionNeedsUpdateMessage) `
                            -f $Name
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($IncludePattern) -and (Compare-Object `
                        -ReferenceObject $IncludePattern `
                        -DifferenceObject $fileGroup.IncludePattern).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.FileGroupIncludePatternNeedsUpdateMessage) `
                            -f $Name
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($ExcludePattern) -and (Compare-Object `
                        -ReferenceObject $ExcludePattern `
                        -DifferenceObject $fileGroup.ExcludePattern).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.FileGroupExcludePatternNeedsUpdateMessage) `
                            -f $Name
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # Ths File Group doesn't exist but should
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileGroupDoesNotExistButShouldMessage) `
                        -f $Name
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The File Group should not exist
        if ($fileGroup)
        {
            # The File Group exists but should not
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileGroupExistsButShouldNotMessage) `
                        -f $Name
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
        else
        {
            # The File Group does not exist and should not
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.FileGroupDoesNotExistAndShouldNotMessage) `
                        -f $Name
                ) -join '' )
        }
    } # if

    return $desiredConfigurationMatch
} # Test-TargetResource

<#
    .SYNOPSIS
        Gets the FSRM File Group object with the specified Name.

    .PARAMETER Name
        The name of the FSRM File Group.
#>
function Get-FileGroup
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    try
    {
        $fileGroup = Get-FSRMFileGroup -Name $Name -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $fileGroup = $null
    }
    catch
    {
        throw $_
    }

    return $fileGroup
}

Export-ModuleMember -Function *-TargetResource
