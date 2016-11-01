Import-Module -Name (Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath 'CommonResourceHelper.psm1')
$LocalizedData = Get-LocalizedData -ResourceName 'MSFT_FSRMFileScreenAction'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingActionMessage) `
            -f $Path,$Type
        ) -join '' )

    try
    {
        $Actions = (Get-FSRMFileScreen -Path $Path -ErrorAction Stop).Notification
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $errorId = 'FileScreenNotFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.FileScreenNotFoundError) `
            -f $Path
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    $Action = $Actions | Where-Object { $_.Type -eq $Type }

    $returnValue = @{
        Path = $Path
        Type = $Type
    }
    if ($Action)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ActionExistsMessage) `
                -f $Path,$Type
            ) -join '' )
        $returnValue += @{
            Ensure = 'Present'
            Subject = $Action.Subject
            Body = $Action.Body
            MailBCC = $Action.MailBCC
            MailCC = $Action.MailCC
            MailTo = $Action.MailTo
            Command = $Action.Command
            CommandParameters = $Action.CommandParameters
            KillTimeOut = [System.Int32] $Action.KillTimeOut
            RunLimitInterval = [System.Int32] $Action.RunLimitInterval
            SecurityLevel = $Action.SecurityLevel
            ShouldLogError = $Action.ShouldLogError
            WorkingDirectory = $Action.WorkingDirectory
            EventType = $Action.EventType
            ReportTypes = [System.String[]] $Action.ReportTypes
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ActionDoesNotExistMessage) `
                -f $Path,$Type
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

        [parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]$Subject,
        [System.String]$Body,
        [System.String]$MailTo,
        [System.String]$MailCC,
        [System.String]$MailBCC,
        [ValidateSet('None','Information','Warning','Error')]
        [System.String]$EventType,
        [System.String]$Command,
        [System.String]$CommandParameters,
        [System.Int32]$KillTimeOut,
        [System.Int32]$RunLimitInterval,
        [ValidateSet('None','LocalService','NetworkService','LocalSystem')]
        [System.String]$SecurityLevel,
        [System.Boolean]$ShouldLogError,
        [System.String]$WorkingDirectory,
        [System.String[]]$ReportTypes
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingActionMessage) `
            -f $Path,$Type
        ) -join '' )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Path')
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing action
    try
    {
        $Actions = (Get-FSRMFileScreen -Path $Path -ErrorAction Stop).Notification
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $errorId = 'FileScreenNotFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.FileScreenNotFoundError) `
            -f $Path
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $NewActions = New-Object 'System.Collections.ArrayList'
    $ActionIndex = $null
    # Assemble the Result Object so that it contains an array of Actions
    # DO NOT change this behavior unless you are sure you know what you're doing.
    for ($a=0; $a -ilt $Actions.Count; $a++)
    {
        $null = $NewActions.Add($Actions[$a])
        if ($Actions[$a].Type -eq $Type)
        {
            $ActionIndex = $a
        }
    }

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionExistsMessage) `
                -f $Path,$Type
            ) -join '' )

        $NewAction = New-FSRMAction @PSBoundParameters -ErrorAction Stop

        if ($ActionIndex -eq $null)
        {
            # Create the action
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionCreatedMessage) `
                    -f $Path,$Type
                ) -join '' )
        }
        else
        {
            # The action exists, remove it then update it
           $null = $NewActions.RemoveAt($ActionIndex)

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionUpdatedMessage) `
                    -f $Path,$Type
                ) -join '' )
        }

        $null = $NewActions.Add($NewAction)
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionDoesNotExistMessage) `
                -f $Path,$Type
            ) -join '' )

        if ($ActionIndex -eq $null)
        {
            # The action doesn't exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionNoChangeMessage) `
                    -f $Path,$Type
                ) -join '' )
            return
        }
        else
        {
            # The Action exists, but shouldn't remove it
            $null = $NewActions.RemoveAt($ActionIndex)

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionRemovedMessage) `
                    -f $Path,$Type
                ) -join '' )
        } # if
    } # if

    # Now write the actual change to the appropriate place
    Set-FSRMFileScreen `
        -Path $Path `
        -Notification $NewActions `
        -ErrorAction Stop

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.ActionWrittenMessage) `
            -f $Path,$Type
        ) -join '' )
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

        [parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]$Subject,
        [System.String]$Body,
        [System.String]$MailTo,
        [System.String]$MailCC,
        [System.String]$MailBCC,
        [ValidateSet('None','Information','Warning','Error')]
        [System.String]$EventType,
        [System.String]$Command,
        [System.String]$CommandParameters,
        [System.Int32]$KillTimeOut,
        [System.Int32]$RunLimitInterval,
        [ValidateSet('None','LocalService','NetworkService','LocalSystem')]
        [System.String]$SecurityLevel,
        [System.Boolean]$ShouldLogError,
        [System.String]$WorkingDirectory,
        [System.String[]]$ReportTypes
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingActionMessage) `
            -f $Path,$Type
        ) -join '' )

    # Lookup the existing action and related objects
    try
    {
        $Actions = (Get-FSRMFileScreen -Path $Path -ErrorAction Stop).Notification
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
        $errorId = 'FileScreenNotFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.FileScreenNotFoundError) `
            -f $Path
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    $Action = $Actions | Where-Object { $_.Type -eq $Type }

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionExistsMessage) `
                -f $Path,$Type
            ) -join '' )

        if ($Action)
        {
            # The action exists - check it
            #region Parameter Checks
            if (($PSBoundParameters.ContainsKey('Subject')) `
                -and ($Action.Subject -ne $Subject))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'Subject'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Body')) `
                -and ($Action.Body -ne $Body))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'Body'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailBCC')) `
                -and ($Action.MailBCC -ne $MailBCC))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'MailBCC'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailCC')) `
                -and ($Action.MailCC -ne $MailCC))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'MailCC'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailTo')) `
                -and ($Action.MailTo -ne $MailTo))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'MailTo'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Command')) `
                -and ($Action.Command -ne $Command))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'Command'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('CommandParameters')) `
                -and ($Action.CommandParameters -ne $CommandParameters))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'CommandParameters'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('KillTimeOut')) `
                -and ($Action.KillTimeOut -ne $KillTimeOut))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'KillTimeOut'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('RunLimitInterval')) `
                -and ($Action.RunLimitInterval -ne $RunLimitInterval))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'RunLimitInterval'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('SecurityLevel')) `
                -and ($Action.SecurityLevel -ne $SecurityLevel))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'SecurityLevel'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ShouldLogError')) `
                -and ($Action.ShouldLogError -ne $ShouldLogError))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'ShouldLogError'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('WorkingDirectory')) `
                -and ($Action.WorkingDirectory -ne $WorkingDirectory))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'WorkingDirectory'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('EventType')) `
                -and ($Action.EventType -ne $EventType))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'EventType'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ReportTypes')) `
                -and ($Action.ReportTypes -ne $ReportTypes))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Path,$Type,'ReportTypes'
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
                    -f $Path,$Type
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        if ($Action)
        {
            # The Action exists, but it should be removed
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionExistsAndShouldNotMessage) `
                    -f $Path,$Type
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The action doesn't exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionDoesNotExistAndShouldNotMessage) `
                    -f $Path,$Type
                ) -join '' )
        } # if
    } # if

    return $desiredConfigurationMatch
} # Test-TargetResource

Export-ModuleMember -Function *-TargetResource
