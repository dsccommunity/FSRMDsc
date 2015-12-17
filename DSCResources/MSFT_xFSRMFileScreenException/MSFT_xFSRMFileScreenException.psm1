data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingFileScreenExceptionMessage=Getting FSRM File Screen Exception "{0}".
FileScreenExceptionExistsMessage=FSRM File Screen Exception "{0}" exists.
FileScreenExceptionDoesNotExistMessage=FSRM File Screen Exception "{0}" does not exist.
SettingFileScreenExceptionMessage=Setting FSRM File Screen Exception "{0}".
EnsureFileScreenExceptionExistsMessage=Ensuring FSRM File Screen Exception "{0}" exists.
EnsureFileScreenExceptionDoesNotExistMessage=Ensuring FSRM File Screen Exception "{0}" does not exist.
FileScreenExceptionCreatedMessage=FSRM File Screen Exception "{0}" has been created.
FileScreenExceptionUpdatedMessage=FSRM File Screen Exception "{0}" has been updated.
FileScreenExceptionRecreatedMessage=FSRM File Screen Exception "{0}" has been recreated.
FileScreenExceptionRemovedMessage=FSRM File Screen Exception "{0}" has been removed.
TestingFileScreenExceptionMessage=Testing FSRM File Screen Exception "{0}".
FileScreenExceptionPropertyNeedsUpdateMessage=FSRM File Screen Exception "{0}" {1} is different. Change required.
FileScreenExceptionDoesNotExistButShouldMessage=FSRM File Screen Exception "{0}" does not exist but should. Change required.
FileScreenExceptionExistsButShouldNotMessage=FSRM File Screen Exception "{0}" exists but should not. Change required.
FileScreenExceptionDoesNotExistAndShouldNotMessage=FSRM File Screen Exception "{0}" does not exist and should not. Change not required.
FileScreenExceptionPathDoesNotExistError=FSRM File Screen Exception "{0}" path does not exist.
FileScreenExceptionTemplateEmptyError=FSRM File Screen Exception "{0}" requires a template name to be set.
FileScreenExceptionTemplateNotFoundError=FSRM File Screen Exception "{0}" template "{1}" not found.
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
        $($LocalizedData.GettingFileScreenExceptionMessage) `
            -f $Path
        ) -join '' )

    # Lookup the existing FileScreenException
    $FileScreenException = Get-FileScreenException -Path $Path

    $returnValue = @{
        Path = $Path
    }
    if ($FileScreenException)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.FileScreenExceptionExistsMessage) `
                -f $Path
            ) -join '' )

        $returnValue += @{
            Ensure = 'Present'
            Description = $FileScreenException.Description
            IncludeGroup = @($FileScreenException.IncludeGroup)
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.FileScreenExceptionDoesNotExistMessage) `
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

        [System.String[]]
        $IncludeGroup
    )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing FileScreenException
    $FileScreenException = Get-FileScreenException -Path $Path

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureFileScreenExceptionExistsMessage) `
                -f $Path
            ) -join '' )

        if ($FileScreenException)
        {
            # The FileScreenException exists
            Set-FSRMFileScreenException @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenExceptionUpdatedMessage) `
                    -f $Path
                ) -join '' )
        }
        else
        {
            # Create the File Screen Exception
            New-FSRMFileScreenException @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenExceptionCreatedMessage) `
                    -f $Path
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureFileScreenExceptionDoesNotExistMessage) `
                -f $Path
            ) -join '' )

        if ($FileScreenException)
        {
            # The File Screen Exception shouldn't exist - remove it
            Remove-FSRMFileScreenException -Path $Path -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenExceptionRemovedMessage) `
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

        [System.String[]]
        $IncludeGroup
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingFileScreenExceptionMessage) `
            -f $Path
        ) -join '' )

    # Check the properties are valid.
    Test-ResourceProperty @PSBoundParameters

    # Lookup the existing FileScreenException
    $FileScreenException = Get-FileScreenException -Path $Path

    if ($Ensure -eq 'Present')
    {
        # The FileScreenException should exist
        if ($FileScreenException)
        {
            # The FileScreenException exists already - check the parameters           
            if (($PSBoundParameters.ContainsKey('IncludeGroup')) `
                -and (Compare-Object `
                -ReferenceObject $IncludeGroup `
                -DifferenceObject $FileScreenException.IncludeGroup).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenExceptionPropertyNeedsUpdateMessage) `
                        -f $Path,'IncludeGroup'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Description')) `
                -and ($FileScreenException.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenExceptionPropertyNeedsUpdateMessage) `
                        -f $Path,'Description'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }
        } else {
            # The File Screen Exception doesn't exist but should
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenExceptionDoesNotExistButShouldMessage) `
                    -f  $Path
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The File Screen Exception should not exist
        if ($FileScreenException)
        {
            # The File Screen Exception exists but should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenExceptionExistsButShouldNotMessage) `
                    -f  $Path
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The File Screen Exception does not exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenExceptionDoesNotExistAndShouldNotMessage) `
                    -f  $Path
                ) -join '' )
        }
    } # if
    return $desiredConfigurationMatch
} # Test-TargetResource

# Helper Functions

Function Get-FileScreenException {
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Path
    )
    try
    {
        $FileScreenException = Get-FSRMFileScreenException -Path $Path -ErrorAction Stop
    }
    catch [Microsoft.Management.Infrastructure.CimException]
    {
        $FileScreenException = $null
    }
    catch
    {
        Throw $_
    }
    Return $FileScreenException
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

        [System.String[]]
        $IncludeGroup
    )
    # Check the path exists
    if (-not (Test-Path -Path $Path))
    {
        $errorId = 'FileScreenExceptionPathDoesNotExistError'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.FileScreenExceptionPathDoesNotExistError) -f $Path
    }
    if ($Ensure -eq 'Absent')
    {
        # No further checks required if File Screen Exception should be removed.
        return
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