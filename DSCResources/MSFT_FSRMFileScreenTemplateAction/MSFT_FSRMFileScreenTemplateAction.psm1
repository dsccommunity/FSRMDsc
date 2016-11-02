Import-Module -Name (Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath 'CommonResourceHelper.psm1')
$LocalizedData = Get-LocalizedData -ResourceName 'MSFT_FSRMFileScreenTemplateAction'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingActionMessage) `
            -f $Name,$Type
        ) -join '' )

    try
    {
        $actions = (Get-FSRMFileScreenTemplate -Name $Name -ErrorAction Stop).Notification
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $errorId = 'FileScreenTemplateNotFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.FileScreenTemplateNotFoundError) `
            -f $Name,$Type
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    $action = $actions | Where-Object { $_.Type -eq $Type }

    $returnValue = @{
        Name = $Name
        Type = $Type
    }
    if ($action)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ActionExistsMessage) `
                -f $Name,$Type
            ) -join '' )
        $returnValue += @{
            Ensure = 'Present'
            Subject = $action.Subject
            Body = $action.Body
            MailBCC = $action.MailBCC
            MailCC = $action.MailCC
            MailTo = $action.MailTo
            Command = $action.Command
            CommandParameters = $action.CommandParameters
            KillTimeOut = [System.Int32] $action.KillTimeOut
            RunLimitInterval = [System.Int32] $action.RunLimitInterval
            SecurityLevel = $action.SecurityLevel
            ShouldLogError = $action.ShouldLogError
            WorkingDirectory = $action.WorkingDirectory
            EventType = $action.EventType
            ReportTypes = [System.String[]] $action.ReportTypes
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ActionDoesNotExistMessage) `
                -f $Name,$Type
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type,

        [Parameter()]
        [ValidateSet('Present','Absent')]
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
        [ValidateSet('None','Information','Warning','Error')]
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
        [ValidateSet('None','LocalService','NetworkService','LocalSystem')]
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
        $($LocalizedData.SettingActionMessage) `
            -f $Name,$Type
        ) -join '' )

    # Remove any parameters that can't be splatted.
    $Null = $PSBoundParameters.Remove('Name')
    $Null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing action
    try
    {
        $actions = (Get-FSRMFileScreenTemplate -Name $Name -ErrorAction Stop).Notification
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $errorId = 'FileScreenTemplateNotFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.FileScreenTemplateNotFoundError) `
            -f $Name,$Type
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $NewActions = New-Object 'System.Collections.ArrayList'
    $actionIndex = $null
    # Assemble the Result Object so that it contains an array of Actions
    # DO NOT change this behavior unless you are sure you know what you're doing.
    for ($a=0; $a -ilt $actions.Count; $a++)
    {
        $null = $NewActions.Add($actions[$a])
        if ($actions[$a].Type -eq $Type)
        {
            $actionIndex = $a
        }
    }

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionExistsMessage) `
                -f $Name,$Type
            ) -join '' )

        $NewAction = New-FSRMAction @PSBoundParameters -ErrorAction Stop

        if ($actionIndex -eq $null) {
            # Create the action
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionCreatedMessage) `
                    -f $Name,$Type
                ) -join '' )
        }
        else
        {
            # The action exists, remove it then update it
            $null = $NewActions.RemoveAt($actionIndex)

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionUpdatedMessage) `
                    -f $Name,$Type
                ) -join '' )
        }

        $null = $NewActions.Add($NewAction)
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionDoesNotExistMessage) `
                -f $Name,$Type
            ) -join '' )

        if ($actionIndex -eq $null)
        {
            # The action doesn't exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionNoChangeMessage) `
                    -f $Name,$Type
                ) -join '' )
            return
        }
        else
        {
            # The Action exists, but shouldn't remove it
            $null = $NewActions.RemoveAt($actionIndex)

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionRemovedMessage) `
                    -f $Name,$Type
                ) -join '' )
        } # if
    } # if
    # Now write the actual change to the appropriate place
    Set-FSRMFileScreenTemplate `
        -Name $Name `
        -Notification $NewActions `
        -ErrorAction Stop

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.ActionWrittenMessage) `
            -f $Name,$Type
        ) -join '' )
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type,

        [Parameter()]
        [ValidateSet('Present','Absent')]
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
        [ValidateSet('None','Information','Warning','Error')]
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
        [ValidateSet('None','LocalService','NetworkService','LocalSystem')]
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
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingActionMessage) `
            -f $Name,$Type
        ) -join '' )

    # Lookup the existing action and related objects
    try
    {
        $actions = (Get-FSRMFileScreenTemplate -Name $Name -ErrorAction Stop).Notification
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $errorId = 'FileScreenTemplateNotFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.FileScreenTemplateNotFoundError) `
            -f $Name,$Type
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    $action = $actions | Where-Object { $_.Type -eq $Type }

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionExistsMessage) `
                -f $Name,$Type
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
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'Subject'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Body')) `
                -and ($action.Body -ne $Body))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'Body'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailBCC')) `
                -and ($action.MailBCC -ne $MailBCC))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'MailBCC'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailCC')) `
                -and ($action.MailCC -ne $MailCC))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'MailCC'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailTo')) `
                -and ($action.MailTo -ne $MailTo))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'MailTo'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Command')) `
                -and ($action.Command -ne $Command))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'Command'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('CommandParameters')) `
                -and ($action.CommandParameters -ne $CommandParameters))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'CommandParameters'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('KillTimeOut')) `
                -and ($action.KillTimeOut -ne $KillTimeOut))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'KillTimeOut'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('RunLimitInterval')) `
                -and ($action.RunLimitInterval -ne $RunLimitInterval))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'RunLimitInterval'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('SecurityLevel')) `
                -and ($action.SecurityLevel -ne $SecurityLevel))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'SecurityLevel'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ShouldLogError')) `
                -and ($action.ShouldLogError -ne $ShouldLogError))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'ShouldLogError'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('WorkingDirectory')) `
                -and ($action.WorkingDirectory -ne $WorkingDirectory))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'WorkingDirectory'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('EventType')) `
                -and ($action.EventType -ne $EventType))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'EventType'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ReportTypes')) `
                -and ($action.ReportTypes -ne $ReportTypes))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'ReportTypes'
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
                $($LocalizedData.ActionDoesNotExistButShouldMessage) `
                    -f $Name,$Type
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
                $($LocalizedData.ActionExistsAndShouldNotMessage) `
                    -f $Name,$Type
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The action doesn't exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionDoesNotExistAndShouldNotMessage) `
                    -f $Name,$Type
                ) -join '' )
        } # if
    } # if

    return $desiredConfigurationMatch
} # Test-TargetResource

# Helper Functions

<#
.Synopsis
    This function tries to find a matching File Screen Template.
    If found, it assembles all threshold and action objects into modifiable arrays
    So that they can be worked with and then later saved back into the FileScreen Template
    Using Set-Action.
#>
Function Get-Action {
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type
    )
    $resultObject = [PSObject] @{
        ActionObjects = [System.Collections.ArrayList]@()
        ActionIndex = $null
    }
    # Lookup the FileScreen Template
    try
    {
        $fileScreenTemplate = Get-FSRMFileScreenTemplate -Name $Name -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $errorId = 'FileScreenTemplateNotFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.FileScreenTemplateNotFoundError) `
            -f $Name,$Type
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    # Assemble the Result Object so that it contains an array of Actions
    # DO NOT change this behavior unless you are sure you know what you're doing.
    for ($action = 0; $action -ilt $fileScreenTemplate.Notification.Count; $action++)
    {
        $null = $resultObject.ActionObjects.Add($fileScreenTemplate.Notification[$action])
        if ($fileScreenTemplate.Notification[$action].Type -eq $Type)
        {
            $resultObject.ActionIndex = $action
        }
    }

    # Return the result
    Return $resultObject
}

Export-ModuleMember -Function *-TargetResource
