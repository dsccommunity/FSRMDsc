data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingClassificationMessage=Getting FSRM Classification Configuration "{0}".
SettingClassificationMessage=Setting FSRM Classification Configuration "{0}".
ClassificationScheduleUpdatedMessage=FSRM Classification Schedule "{0}" Updated.
ClassificationUpdatedMessage=FSRM Classification Configuration "{0}" Updated.
TestingClassificationMessage=Testing FSRM Classification Configuration "{0}".
ClassificationNeedsUpdateMessage=FSRM Classification Configuration "{0}" {1} is different. Change required.
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
        $Id
    )
    
    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingClassificationMessage) `
            -f $Id
        ) -join '' )

    $Classification = Get-FSRMClassification -ErrorAction Stop

    $returnValue = @{
        Id = $Id
        Continuous = $Classification.Continuous
        ContinuousLog = $Classification.ContinuousLog
        ContinuousLogSize = $Classification.ContinuousLogSize
        ExcludeNamespace = $Classification.ExcludeNamespace
        ScheduleMonthly = [System.Uint32[]] @($Classification.Schedule.Monthly)
        ScheduleWeekly = [String[]] @($Classification.Schedule.Weekly)
        ScheduleRunDuration = [System.Uint32] $Classification.Schedule.RunDuration
        ScheduleTime = $Classification.Schedule.Time
        LastError = $Classification.LastError
        Status = $Classification.Status
    }

    return $returnValue
} # Get-TargetResource


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Id,

        [System.Boolean]$Continuous,
        [System.Boolean]$ContinuousLog,
        [System.Uint32]$ContinuousLogSize,
        [System.String[]]$ExcludeNamespace,
        [System.Uint32[]]$ScheduleMonthly,
        [System.String[]]$ScheduleWeekly,
        [System.Int32]$ScheduleRunDuration,
        [System.String]$ScheduleTime
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingClassificationMessage) `
            -f $Id
        ) -join '' )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Id')

    # Are there any schedule parameters?
    if ($PSBoundParameters.ContainsKey('ScheduleMonthly') `
        -or $PSBoundParameters.ContainsKey('ScheduleWeekly') `
        -or $PSBoundParameters.ContainsKey('ScheduleRunDuration') `
        -or $PSBoundParameters.ContainsKey('ScheduleTime'))
    {

        # There are so a scheduled task object needs to be modified or created
        $Schedule = (Get-FSRMClassification).Schedule

        # Create a splat to use to create the new Scheduled Task
        $Splat = @{}

        if ($PSBoundParameters.ContainsKey('ScheduleMonthly'))
        {
            # The Schedule monthly is passed in as [System.Uint32[]].
            # DSC does not support [System.Int32[]] types as parameters.
            # But the New-FSRMScheduledTask Monthly parameter only supports [System.Int32[]] types.
            # So this must be converted manually. Cast does not seem to work here.
            $ConvertedScheduleMonthly = [System.Array]::CreateInstance([System.Int32],$ScheduleMonthly.Length)
            for ($i=0; $i -lt $ScheduleMonthly.Length; $i++) { 
                $ConvertedScheduleMonthly[$i] = $ScheduleMonthly[$i]
            }
            $Splat += @{ Monthly = $ConvertedScheduleMonthly }
        }
        elseif ( $Schedule.Monthly )
        {
            $Splat += @{ Monthly = $Schedule.Monthly }
        }
        
        if ($PSBoundParameters.ContainsKey('ScheduleWeekly'))
        {
            $Splat += @{ Weekly = $ScheduleWeekly }
        }
        elseif ( $Schedule.Weekly )
        {
            $Splat += @{ Weekly = $Schedule.Weekly }
        }

        if ($PSBoundParameters.ContainsKey('ScheduleRunDuration'))
        {
            $Splat += @{ RunDuration = $ScheduleRunDuration }
        }
        elseif ( $Schedule.RunDuration )
        {
            $Splat += @{ RunDuration = $Schedule.RunDuration }
        }

        if ($PSBoundParameters.ContainsKey('ScheduleTime'))
        {
            $Splat += @{ Time = $ScheduleTime }
        }
        elseif ( $Schedule.Time )
        {
            $Splat += @{ Time = $Schedule.Time }
        }

        # Remove the schedule parameters
        $null = $PSBoundParameters.Remove('ScheduleMonthly')        
        $null = $PSBoundParameters.Remove('ScheduleWeekly')        
        $null = $PSBoundParameters.Remove('ScheduleRunDuration')        
        $null = $PSBoundParameters.Remove('ScheduleTime')

        # Add the new scheduled task parameter
        $NewSchedule = New-FSRMScheduledTask @Splat
        $null = $PSBoundParameters.Add('Schedule',$NewSchedule)        

        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationScheduleUpdatedMessage) `
                -f $Id
            ) -join '' )
    }
    # Set the existing Classification with a splat
    Set-FSRMClassification @PSBoundParameters

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.ClassificationUpdatedMessage) `
            -f $Id
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
        $Id,

        [System.Boolean]$Continuous,
        [System.Boolean]$ContinuousLog,
        [System.Uint32]$ContinuousLogSize,
        [System.String[]]$ExcludeNamespace,
        [System.Uint32[]]$ScheduleMonthly,
        [System.String[]]$ScheduleWeekly,
        [System.Int32]$ScheduleRunDuration,
        [System.String]$ScheduleTime
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingClassificationMessage) `
            -f $Id
        ) -join '' )

    # Lookup the existing Classification
    $Classification = Get-FSRMClassification

    # The Classification exists already - check the parameters
    if (($Continuous) -and ($Classification.Continuous -ne $Continuous))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'Continuous'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ContinuousLog) -and ($Classification.ContinuousLog -ne $ContinuousLog))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'ContinuousLog'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ContinuousLogSize) -and ($Classification.ContinuousLogSize -ne $ContinuousLogSize))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'ContinuousLogSize'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ExcludeNamespace) `
        -and (Compare-Object `
            -ReferenceObject $ExcludeNamespace `
            -DifferenceObject ($Classification.ExcludeNamespace,@(),1 -ne $null)[0]).Count -ne 0)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'ExcludeNamespace'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ScheduleMonthly) `
        -and (Compare-Object `
            -ReferenceObject $ScheduleMonthly `
            -DifferenceObject ($Classification.Schedule.Monthly,1 -ne $null)[0]).Count -ne 0)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'ScheduleMonthly'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ScheduleWeekly) `
        -and (Compare-Object `
            -ReferenceObject $ScheduleWeekly `
            -DifferenceObject ($Classification.Schedule.Weekly,1 -ne $null)[0]).Count -ne 0)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'ScheduleWeekly'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ScheduleRunDuration) -and ($Classification.Schedule.RunDuration -ne $ScheduleRunDuration))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'ScheduleRunDuration'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ScheduleTime) -and ($Classification.Schedule.Time -ne $ScheduleTime))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'ScheduleTime'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    return $desiredConfigurationMatch
} # Test-TargetResource

Export-ModuleMember -Function *-TargetResource