data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingActionMessage=Getting FSRM File Screen Template Action for {1} "{0}".
ActionExistsMessage=FSRM File Screen Template Action for {1} "{0}" exists.
ActionNotExistMessage=FSRM File Screen Template Action for {1} "{0}" does not exist.
SettingActionMessage=Setting FSRM File Screen Template Action for {1} "{0}".
EnsureActionExistsMessage=Ensuring FSRM File Screen Template Action for {1} "{0}" exists.
EnsureActionDoesNotExistMessage=Ensuring FSRM File Screen Template Action for {1} "{0}" does not exist.
ActionCreatedMessage=FSRM File Screen Template Action for {1} "{0}" has been created.
ActionUpdatedMessage=FSRM File Screen Template Action for {1} "{0}" has been updated.
ActionRemovedMessage=FSRM File Screen Template Action for {1} "{0}" has been removed.
ActionNoChangeMessage=FSRM File Screen Template Action for {1} "{0}" required not changes.
ActionWrittenMessage=FSRM File Screen Template Action for {1} "{0}" has been written.
TestingActionMessage=Testing FSRM File Screen Template Action for {1} "{0}".
ActionPropertyNeedsUpdateMessage=FSRM File Screen Template Action for {1} "{0}" {2} is different. Change required.
ActionDoesNotExistButShouldMessage=FSRM File Screen Template Action for {1} "{0}" does not exist but should. Change required.
ActionExistsAndShouldNotMessage=FSRM File Screen Template Action for {1} "{0}" exists but should not. Change required.
ActionDoesNotExistAndShouldNotMessage=FSRM File Screen Template Action for {1} "{0}" does not exist and should not. Change not required.
FileScreenTemplateNotFoundError=FSRM File Screen Template "{0}" not found.
FileScreenTemplateThresholdNotFoundError=FSRM File Screen Template "{0}" not found.
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
        $Name,
       
        [parameter(Mandatory = $true)]
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
        $Actions = (Get-FSRMFileScreenTemplate -Name $Name -ErrorAction Stop).Notification
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
    $Action = $Actions | Where-Object { $_.Type -eq $Type }

    $returnValue = @{
        Name = $Name
        Type = $Type
    }
    if ($Action)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ActionExistsMessage) `
                -f $Name,$Type
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

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
            -f $Name,$Type
        ) -join '' )

    # Remove any parameters that can't be splatted.
    $Null = $PSBoundParameters.Remove('Name')
    $Null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing action
    try
    {
        $Actions = (Get-FSRMFileScreenTemplate -Name $Name -ErrorAction Stop).Notification
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
                -f $Name,$Type
            ) -join '' )

        $NewAction = New-FSRMAction @PSBoundParameters -ErrorAction Stop

        if ($ActionIndex -eq $null) {
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
            $null = $NewActions.RemoveAt($ActionIndex)

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

        if ($ActionIndex -eq $null)
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
            $null = $NewActions.RemoveAt($ActionIndex)

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
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

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
    # Could check report types here
    # @('DuplicateFiles','FilesByFileGroup','FilesByOwner','FilesByProperty','LargeFiles','LeastRecentlyAccessed','MostRecentlyAccessed','FileScreenUsage')

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
        $Actions = (Get-FSRMFileScreenTemplate -Name $Name -ErrorAction Stop).Notification
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
    $Action = $Actions | Where-Object { $_.Type -eq $Type }

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionExistsMessage) `
                -f $Name,$Type
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
                        -f $Name,$Type,'Subject'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Body')) `
                -and ($Action.Body -ne $Body))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'Body'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailBCC')) `
                -and ($Action.MailBCC -ne $MailBCC))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'MailBCC'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailCC')) `
                -and ($Action.MailCC -ne $MailCC))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'MailCC'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailTo')) `
                -and ($Action.MailTo -ne $MailTo))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'MailTo'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Command')) `
                -and ($Action.Command -ne $Command))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'Command'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('CommandParameters')) `
                -and ($Action.CommandParameters -ne $CommandParameters))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'CommandParameters'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('KillTimeOut')) `
                -and ($Action.KillTimeOut -ne $KillTimeOut))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'KillTimeOut'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('RunLimitInterval')) `
                -and ($Action.RunLimitInterval -ne $RunLimitInterval))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'RunLimitInterval'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('SecurityLevel')) `
                -and ($Action.SecurityLevel -ne $SecurityLevel))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'SecurityLevel'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ShouldLogError')) `
                -and ($Action.ShouldLogError -ne $ShouldLogError))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'ShouldLogError'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('WorkingDirectory')) `
                -and ($Action.WorkingDirectory -ne $WorkingDirectory))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'WorkingDirectory'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('EventType')) `
                -and ($Action.EventType -ne $EventType))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Type,'EventType'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ReportTypes')) `
                -and ($Action.ReportTypes -ne $ReportTypes))
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
        if ($Action)
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type
    )
    $ResultObject = [PSObject] @{
        ActionObjects = [System.Collections.ArrayList]@()
        ActionIndex = $null
    }
    # Lookup the FileScreen Template
    try
    {
        $Actions = (Get-FSRMFileScreenTemplate -Name $Name -ErrorAction Stop).Notification
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
    for ($a=0; $a -ilt $FileScreenTemplate.Notification.Count; $a++)
    {
        $null = $ResultObject.ActionObjects.Add($FileScreenTemplate.Notification[$a])
        if ($FileScreenTemplate.Notification[$a].Type -eq $Type)
        {
            $ResultObject.ActionIndex = $a
        }
    }

    # Return the result
    Return $ResultObject
}

Export-ModuleMember -Function *-TargetResource