Import-Module -Name (Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath 'CommonResourceHelper.psm1')
$LocalizedData = Get-LocalizedData -ResourceName 'MSFT_FSRMFileScreen'

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
        $($LocalizedData.GettingFileScreenMessage) `
            -f $Path
        ) -join '' )

    # Lookup the existing FileScreen
    $fileScreen = Get-FileScreen -Path $Path

    $returnValue = @{
        Path = $Path
    }
    if ($fileScreen)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.FileScreenExistsMessage) `
                -f $Path
            ) -join '' )

        $returnValue += @{
            Ensure = 'Present'
            Description = $fileScreen.Description
            Active = $fileScreen.Active
            IncludeGroup = @($fileScreen.IncludeGroup)
            Template = $fileScreen.Template
            MatchesTemplate = $fileScreen.MatchesTemplate
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.FileScreenDoesNotExistMessage) `
                -f $Path
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
        $Path,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $Active,

        [Parameter()]
        [System.String[]]
        $IncludeGroup,

        [Parameter()]
        [System.String]
        $Template,

        [Parameter()]
        [System.Boolean]
        $MatchesTemplate
    )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')
    $null = $PSBoundParameters.Remove('MatchesTemplate')

    # Lookup the existing FileScreen
    $fileScreen = Get-FileScreen -Path $Path

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureFileScreenExistsMessage) `
                -f $Path
            ) -join '' )

        if ($fileScreen)
        {
            # The FileScreen exists
            if ($MatchesTemplate -and ($Template -ne $fileScreen.Template))
            {
                # The template needs to be changed so the File Screen needs to be
                # Completely recreated.
                Remove-FSRMFileScreen `
                    -Path $Path `
                    -Confirm:$false `
                    -ErrorAction Stop
                New-FSRMFileScreen @PSBoundParameters `
                    -ErrorAction Stop

                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenRecreatedMessage) `
                        -f $Path
                    ) -join '' )
            }
            else
            {
                $PSBoundParameters.Remove('Template')
                Set-FSRMFileScreen @PSBoundParameters `
                    -ErrorAction Stop

                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenUpdatedMessage) `
                        -f $Path
                    ) -join '' )
            }
        }
        else
        {
            # Create the File Screen
            New-FSRMFileScreen @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenCreatedMessage) `
                    -f $Path
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureFileScreenDoesNotExistMessage) `
                -f $Path
            ) -join '' )

        if ($fileScreen)
        {
            # The File Screen shouldn't exist - remove it
            Remove-FSRMFileScreen -Path $Path -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenRemovedMessage) `
                    -f $Path
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
        $Path,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $Active,

        [Parameter()]
        [System.String[]]
        $IncludeGroup,

        [Parameter()]
        [System.String]
        $Template,

        [Parameter()]
        [System.Boolean]
        $MatchesTemplate
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingFileScreenMessage) `
            -f $Path
        ) -join '' )

    # Check the properties are valid.
    Test-ResourceProperty @PSBoundParameters

    # Lookup the existing FileScreen
    $fileScreen = Get-FileScreen -Path $Path

    if ($Ensure -eq 'Present')
    {
        # The FileScreen should exist
        if ($fileScreen)
        {
            # The FileScreen exists already - check the parameters
            if ($MatchesTemplate)
            {
                # MatchesTemplate is set so only care if it matches template
                if (-not $fileScreen.MatchesTemplate)
                {
                    Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($LocalizedData.FileScreenDoesNotMatchTemplateNeedsUpdateMessage) `
                            -f $Path,'Description'
                        ) -join '' )
                    $desiredConfigurationMatch = $false
                }
            }
            else
            {
                if (($PSBoundParameters.ContainsKey('Active')) `
                    -and ($fileScreen.Active -ne $Active))
                {
                    Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($LocalizedData.FileScreenPropertyNeedsUpdateMessage) `
                            -f $Path,'Active'
                        ) -join '' )
                    $desiredConfigurationMatch = $false
                }

                if (($PSBoundParameters.ContainsKey('IncludeGroup')) `
                    -and (Compare-Object `
                    -ReferenceObject $IncludeGroup `
                    -DifferenceObject $fileScreen.IncludeGroup).Count -ne 0)
                {
                    Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($LocalizedData.FileScreenPropertyNeedsUpdateMessage) `
                            -f $Path,'IncludeGroup'
                        ) -join '' )
                    $desiredConfigurationMatch = $false
                }
            } # if ($MatchesTemplate)

            if (($PSBoundParameters.ContainsKey('Description')) `
                -and ($fileScreen.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenPropertyNeedsUpdateMessage) `
                        -f $Path,'Description'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Template')) `
                -and ($fileScreen.Template -ne $Template))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenPropertyNeedsUpdateMessage) `
                        -f $Path,'Template'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # The File Screen doesn't exist but should
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenDoesNotExistButShouldMessage) `
                    -f  $Path
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The File Screen should not exist
        if ($fileScreen)
        {
            # The File Screen exists but should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenExistsButShouldNotMessage) `
                    -f  $Path
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The File Screen does not exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenDoesNotExistAndShouldNotMessage) `
                    -f  $Path
                ) -join '' )
        }
    } # if
    return $desiredConfigurationMatch
} # Test-TargetResource

# Helper Functions

Function Get-FileScreen {
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )
    try
    {
        $fileScreen = Get-FSRMFileScreen -Path $Path -ErrorAction Stop
    }
    catch [Microsoft.Management.Infrastructure.CimException]
    {
        $fileScreen = $null
    }
    catch
    {
        Throw $_
    }
    Return $fileScreen
}
<#
.Synopsis
    This function validates the parameters passed. Called by Test-Resource.
    Will throw an error if any parameters are invalid.
#>
Function Test-ResourceProperty {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $Active,

        [Parameter()]
        [System.String[]]
        $IncludeGroup,

        [Parameter()]
        [System.String]
        $Template,

        [Parameter()]
        [System.Boolean]
        $MatchesTemplate
    )
    # Check the path exists
    if (-not (Test-Path -Path $Path))
    {
        $errorId = 'FileScreenPathDoesNotExistError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.FileScreenPathDoesNotExistError) -f $Path
    }
    if ($Ensure -eq 'Absent')
    {
        # No further checks required if File Screen should be removed.
        return
    }
    if ($Template)
    {
        # Check the template exists
        try {
            $null = Get-FSRMFileScreenTemplate -Name $Template -ErrorAction Stop
        }
        catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
        {
            $errorId = 'FileScreenTemplateNotFoundError'
            $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
            $errorMessage = $($LocalizedData.FileScreenTemplateNotFoundError) -f $Path,$Template
        }
    }
    else
    {
        # A template wasn't specifed, ensure the matches template flag is false
        if ($MatchesTemplate)
        {
            $errorId = 'FileScreenTemplateEmptyError'
            $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
            $errorMessage = $($LocalizedData.FileScreenTemplateEmptyError) -f $Path
        }
    }
    if ($errorId)
    {
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
}

Export-ModuleMember -Function *-TargetResource
