$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

# Import Localization Strings
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        Retrieves the FSRM File Screen Action assigned to the specified Path.

    .PARAMETER Path
        The path of the FSRM File Screen the action applies to.

    .PARAMETER Type
        The type of FSRM Action.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email', 'Event', 'Command', 'Report')]
        [System.String]
        $Type
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.GettingActionMessage) `
                -f $Path, $Type
        ) -join '' )

    try
    {
        $actions = (Get-FSRMFileScreen -Path $Path -ErrorAction Stop).Notification
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        New-InvalidArgumentException `
            -Message ($($script:localizedData.FileScreenNotFoundError) -f $Path) `
            -ArgumentName 'Path'
    }

    $action = $actions | Where-Object -FilterScript { $_.Type -eq $Type }

    $returnValue = @{
        Path = $Path
        Type = $Type
    }

    if ($action)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.ActionExistsMessage) `
                    -f $Path, $Type
            ) -join '' )

        $returnValue += @{
            Ensure            = 'Present'
            Subject           = $action.Subject
            Body              = $action.Body
            MailBCC           = $action.MailBCC
            MailCC            = $action.MailCC
            MailTo            = $action.MailTo
            Command           = $action.Command
            CommandParameters = $action.CommandParameters
            KillTimeOut       = [System.Int32] $action.KillTimeOut
            RunLimitInterval  = [System.Int32] $action.RunLimitInterval
            SecurityLevel     = $action.SecurityLevel
            ShouldLogError    = $action.ShouldLogError
            WorkingDirectory  = $action.WorkingDirectory
            EventType         = $action.EventType
            ReportTypes       = [System.String[]] $action.ReportTypes
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.ActionNotExistMessage) `
                    -f $Path, $Type
            ) -join '' )

        $returnValue += @{
            Ensure = 'Absent'
        }
    }

    return $returnValue
} # Get-TargetResource

<#
    .SYNOPSIS
        Sets the FSRM File Screen Action assigned to the specified Path.

    .PARAMETER Path
        The path of the FSRM File Screen the action applies to.

    .PARAMETER Type
        The type of FSRM Action.

    .PARAMETER Ensure
        Specifies whether the FSRM Action should exist.

    .PARAMETER Subject
        The subject of the e-mail sent. Required when Type is Email.

    .PARAMETER Body
        The body text of the e-mail or event. Required when Type is Email or Event.

    .PARAMETER MailTo
        The mail to of the e-mail sent. Required when Type is Email.

    .PARAMETER MailCC
        The mail CC of the e-mail sent. Required when Type is Email.

    .PARAMETER MailBCC
        The mail BCC of the e-mail sent. Required when Type is Email.

    .PARAMETER EventType
        The type of event created. Required when Type is Event.

    .PARAMETER Command
        The Command to execute. Required when Type is Command.

    .PARAMETER CommandParameters
        The Command Parameters. Required when Type is Command.

    .PARAMETER KillTimeOut
        Int containing kill timeout of the command. Required when Type is Command.

    .PARAMETER RunLimitInterval
        Int containing the run limit interval of the command. Required when Type is Command.

    .PARAMETER SecurityLevel
        The security level the command runs under. Required when Type is Command.

    .PARAMETER ShouldLogError
        Boolean specifying if command errors should be logged. Required when Type is Command.

    .PARAMETER WorkingDirectory
        The working directory of the command. Required when Type is Command.

    .PARAMETER ReportTypes
        Array of Reports to create. Required when Type is Report.
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email', 'Event', 'Command', 'Report')]
        [System.String]
        $Type,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $Subject,

        [Parameter()]
        [System.String]
        $Body,

        [Parameter()]
        [System.String]
        $MailTo,

        [Parameter()]
        [System.String]
        $MailCC,

        [Parameter()]
        [System.String]
        $MailBCC,

        [Parameter()]
        [ValidateSet('None', 'Information', 'Warning', 'Error')]
        [System.String]
        $EventType,

        [Parameter()]
        [System.String]
        $Command,

        [Parameter()]
        [System.String]
        $CommandParameters,

        [Parameter()]
        [System.Int32]
        $KillTimeOut,

        [Parameter()]
        [System.Int32]
        $RunLimitInterval,

        [Parameter()]
        [ValidateSet('None', 'LocalService', 'NetworkService', 'LocalSystem')]
        [System.String]
        $SecurityLevel,

        [Parameter()]
        [System.Boolean]
        $ShouldLogError,

        [Parameter()]
        [System.String]
        $WorkingDirectory,

        [Parameter()]
        [System.String[]]
        $ReportTypes
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.SettingActionMessage) `
                -f $Path, $Type
        ) -join '' )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Path')
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing action
    try
    {
        $actions = (Get-FSRMFileScreen -Path $Path -ErrorAction Stop).Notification
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        New-InvalidArgumentException `
            -Message ($($script:localizedData.FileScreenNotFoundError) -f $Path) `
            -ArgumentName 'Path'
    }

    $newActions = New-Object -TypeName 'System.Collections.ArrayList'
    $actionIndex = $null

    <#
        Assemble the Result Object so that it contains an array of Actions
        DO NOT change this behavior unless you are sure you know what you're doing.
    #>
    for ($action = 0; $action -ilt $actions.Count; $action++)
    {
        $null = $newActions.Add($actions[$action])
        if ($actions[$action].Type -eq $Type)
        {
            $actionIndex = $action
        }
    }

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureActionExistsMessage) `
                    -f $Path, $Type
            ) -join '' )

        $newAction = New-FSRMAction @PSBoundParameters -ErrorAction Stop

        if ($null -eq $actionIndex)
        {
            # Create the action
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.ActionCreatedMessage) `
                        -f $Path, $Type
                ) -join '' )
        }
        else
        {
            # The action exists, remove it then update it
            $null = $newActions.RemoveAt($actionIndex)

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.ActionUpdatedMessage) `
                        -f $Path, $Type
                ) -join '' )
        }

        $null = $newActions.Add($newAction)
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureActionDoesNotExistMessage) `
                    -f $Path, $Type
            ) -join '' )

        if ($null -eq $actionIndex)
        {
            # The action doesn't exist and should not
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.ActionNoChangeMessage) `
                        -f $Path, $Type
                ) -join '' )

            return
        }
        else
        {
            # The Action exists, but shouldn't remove it
            $null = $newActions.RemoveAt($actionIndex)

            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.ActionRemovedMessage) `
                        -f $Path, $Type
                ) -join '' )
        } # if
    } # if

    # Now write the actual change to the appropriate place
    Set-FSRMFileScreen `
        -Path $Path `
        -Notification $newActions `
        -ErrorAction Stop

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.ActionWrittenMessage) `
                -f $Path, $Type
        ) -join '' )
} # Set-TargetResource

<#
    .SYNOPSIS
        Tests the FSRM File Screen Action assigned to the specified Path.

    .PARAMETER Path
        The path of the FSRM FIle Screen the action applies to.

    .PARAMETER Type
        The type of FSRM Action.

    .PARAMETER Ensure
        Specifies whether the FSRM Action should exist.

    .PARAMETER Subject
        The subject of the e-mail sent. Required when Type is Email.

    .PARAMETER Body
        The body text of the e-mail or event. Required when Type is Email or Event.

    .PARAMETER MailTo
        The mail to of the e-mail sent. Required when Type is Email.

    .PARAMETER MailCC
        The mail CC of the e-mail sent. Required when Type is Email.

    .PARAMETER MailBCC
        The mail BCC of the e-mail sent. Required when Type is Email.

    .PARAMETER EventType
        The type of event created. Required when Type is Event.

    .PARAMETER Command
        The Command to execute. Required when Type is Command.

    .PARAMETER CommandParameters
        The Command Parameters. Required when Type is Command.

    .PARAMETER KillTimeOut
        Int containing kill timeout of the command. Required when Type is Command.

    .PARAMETER RunLimitInterval
        Int containing the run limit interval of the command. Required when Type is Command.

    .PARAMETER SecurityLevel
        The security level the command runs under. Required when Type is Command.

    .PARAMETER ShouldLogError
        Boolean specifying if command errors should be logged. Required when Type is Command.

    .PARAMETER WorkingDirectory
        The working directory of the command. Required when Type is Command.

    .PARAMETER ReportTypes
        Array of Reports to create. Required when Type is Report.
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email', 'Event', 'Command', 'Report')]
        [System.String]
        $Type,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $Subject,

        [Parameter()]
        [System.String]
        $Body,

        [Parameter()]
        [System.String]
        $MailTo,

        [Parameter()]
        [System.String]
        $MailCC,

        [Parameter()]
        [System.String]
        $MailBCC,

        [Parameter()]
        [ValidateSet('None', 'Information', 'Warning', 'Error')]
        [System.String]
        $EventType,

        [Parameter()]
        [System.String]
        $Command,

        [Parameter()]
        [System.String]
        $CommandParameters,

        [Parameter()]
        [System.Int32]
        $KillTimeOut,

        [Parameter()]
        [System.Int32]
        $RunLimitInterval,

        [Parameter()]
        [ValidateSet('None', 'LocalService', 'NetworkService', 'LocalSystem')]
        [System.String]
        $SecurityLevel,

        [Parameter()]
        [System.Boolean]
        $ShouldLogError,

        [Parameter()]
        [System.String]
        $WorkingDirectory,

        [Parameter()]
        [System.String[]]
        $ReportTypes
    )

    # Flag to signal whether settings are correct
    $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.TestingActionMessage) `
                -f $Path, $Type
        ) -join '' )

    # Lookup the existing action and related objects
    try
    {
        $actions = (Get-FSRMFileScreen -Path $Path -ErrorAction Stop).Notification
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        New-InvalidArgumentException `
            -Message ($($script:localizedData.FileScreenNotFoundError) -f $Path) `
            -ArgumentName 'Path'
    }

    $action = $actions | Where-Object -FilterScript { $_.Type -eq $Type }

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.EnsureActionExistsMessage) `
                    -f $Path, $Type
            ) -join '' )

        if ($action)
        {
            # The action exists - check it
            #region Parameter Checks
            if (($PSBoundParameters.ContainsKey('Subject')) `
                    -and ($action.Subject -ne $Subject))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'Subject'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Body')) `
                    -and ($action.Body -ne $Body))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'Body'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailBCC')) `
                    -and ($action.MailBCC -ne $MailBCC))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'MailBCC'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailCC')) `
                    -and ($action.MailCC -ne $MailCC))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'MailCC'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailTo')) `
                    -and ($action.MailTo -ne $MailTo))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'MailTo'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Command')) `
                    -and ($action.Command -ne $Command))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'Command'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('CommandParameters')) `
                    -and ($action.CommandParameters -ne $CommandParameters))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'CommandParameters'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('KillTimeOut')) `
                    -and ($action.KillTimeOut -ne $KillTimeOut))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'KillTimeOut'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('RunLimitInterval')) `
                    -and ($action.RunLimitInterval -ne $RunLimitInterval))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'RunLimitInterval'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('SecurityLevel')) `
                    -and ($action.SecurityLevel -ne $SecurityLevel))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'SecurityLevel'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ShouldLogError')) `
                    -and ($action.ShouldLogError -ne $ShouldLogError))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'ShouldLogError'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('WorkingDirectory')) `
                    -and ($action.WorkingDirectory -ne $WorkingDirectory))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'WorkingDirectory'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('EventType')) `
                    -and ($action.EventType -ne $EventType))
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'EventType'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }

            # Get the existing report types into an array
            if ($null -eq $action.ReportTypes)
            {
                [System.String[]] $existingReportTypes = @()
            }
            else
            {
                [System.String[]] $existingReportTypes = $action.ReportTypes
            }

            if ($PSBoundParameters.ContainsKey('ReportTypes') -and `
                (Compare-Object -ReferenceObject $existingReportTypes -DifferenceObject $ReportTypes).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                        "$($MyInvocation.MyCommand): "
                        $($script:localizedData.ActionPropertyNeedsUpdateMessage) `
                            -f $Path, $Type, 'ReportTypes'
                    ) -join '' )

                $desiredConfigurationMatch = $false
            }
            #endregion
        }
        else
        {
            # The action does not exist but should
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.ActionDoesNotExistButShouldMessage) `
                        -f $Path, $Type
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        if ($action)
        {
            # The Action exists, but it should be removed
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.ActionExistsAndShouldNotMessage) `
                        -f $Path, $Type
                ) -join '' )

            $desiredConfigurationMatch = $false
        }
        else
        {
            # The action doesn't exist and should not
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.ActionDoesNotExistAndShouldNotMessage) `
                        -f $Path, $Type
                ) -join '' )
        } # if
    } # if

    return $desiredConfigurationMatch
} # Test-TargetResource

Export-ModuleMember -Function *-TargetResource
