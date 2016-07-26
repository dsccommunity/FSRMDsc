data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingFileScreenMessage=Getting FSRM File Screen "{0}".
FileScreenExistsMessage=FSRM File Screen "{0}" exists.
FileScreenDoesNotExistMessage=FSRM File Screen "{0}" does not exist.
SettingFileScreenMessage=Setting FSRM File Screen "{0}".
EnsureFileScreenExistsMessage=Ensuring FSRM File Screen "{0}" exists.
EnsureFileScreenDoesNotExistMessage=Ensuring FSRM File Screen "{0}" does not exist.
FileScreenCreatedMessage=FSRM File Screen "{0}" has been created.
FileScreenUpdatedMessage=FSRM File Screen "{0}" has been updated.
FileScreenRecreatedMessage=FSRM File Screen "{0}" has been recreated.
FileScreenRemovedMessage=FSRM FileScreen "{0}" has been removed.
TestingFileScreenMessage=Testing FSRM File Screen "{0}".
FileScreenDoesNotMatchTemplateNeedsUpdateMessage=FSRM File Screen "{0}" {1} does not match template. Change required.
FileScreenPropertyNeedsUpdateMessage=FSRM File Screen "{0}" {1} is different. Change required.
FileScreenDoesNotExistButShouldMessage=FSRM File Screen "{0}" does not exist but should. Change required.
FileScreenExistsButShouldNotMessage=FSRM File Screen "{0}" exists but should not. Change required.
FileScreenDoesNotExistAndShouldNotMessage=FSRM File Screen "{0}" does not exist and should not. Change not required.
FileScreenPathDoesNotExistError=FSRM File Screen "{0}" path does not exist.
FileScreenTemplateEmptyError=FSRM File Screen "{0}" requires a template name to be set.
FileScreenTemplateNotFoundError=FSRM File Screen "{0}" template "{1}" not found.
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
        $Path
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingFileScreenMessage) `
            -f $Path
        ) -join '' )

    # Lookup the existing FileScreen
    $FileScreen = Get-FileScreen -Path $Path

    $returnValue = @{
        Path = $Path
    }
    if ($FileScreen)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.FileScreenExistsMessage) `
                -f $Path
            ) -join '' )

        $returnValue += @{
            Ensure = 'Present'
            Description = $FileScreen.Description
            Active = $FileScreen.Active
            IncludeGroup = @($FileScreen.IncludeGroup)
            Template = $FileScreen.Template
            MatchesTemplate = $FileScreen.MatchesTemplate
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [System.String]
        $Description,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.Boolean]
        $Active,

        [System.String[]]
        $IncludeGroup,

        [System.String]
        $Template,

        [System.Boolean]
        $MatchesTemplate
    )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')
    $null = $PSBoundParameters.Remove('MatchesTemplate')

    # Lookup the existing FileScreen
    $FileScreen = Get-FileScreen -Path $Path

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureFileScreenExistsMessage) `
                -f $Path
            ) -join '' )

        if ($FileScreen)
        {
            # The FileScreen exists
            if ($MatchesTemplate -and ($Template -ne $FileScreen.Template))
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

        if ($FileScreen)
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [System.String]
        $Description,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.Boolean]
        $Active,

        [System.String[]]
        $IncludeGroup,

        [System.String]
        $Template,

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
    $FileScreen = Get-FileScreen -Path $Path

    if ($Ensure -eq 'Present')
    {
        # The FileScreen should exist
        if ($FileScreen)
        {
            # The FileScreen exists already - check the parameters
            if ($MatchesTemplate)
            {
                # MatchesTemplate is set so only care if it matches template
                if (-not $FileScreen.MatchesTemplate)
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
                    -and ($FileScreen.Active -ne $Active))
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
                    -DifferenceObject $FileScreen.IncludeGroup).Count -ne 0)
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
                -and ($FileScreen.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenPropertyNeedsUpdateMessage) `
                        -f $Path,'Description'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Template')) `
                -and ($FileScreen.Template -ne $Template))
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
        if ($FileScreen)
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Path
    )
    try
    {
        $FileScreen = Get-FSRMFileScreen -Path $Path -ErrorAction Stop
    }
    catch [Microsoft.Management.Infrastructure.CimException]
    {
        $FileScreen = $null
    }
    catch
    {
        Throw $_
    }
    Return $FileScreen
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [System.String]
        $Description,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.Boolean]
        $Active,

        [System.String[]]
        $IncludeGroup,

        [System.String]
        $Template,

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
