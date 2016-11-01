Import-Module -Name (Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath 'CommonResourceHelper.psm1')
$LocalizedData = Get-LocalizedData -ResourceName 'MSFT_FSRMClassification'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Id,

        [Parameter()]
        [System.Boolean]
        $Continuous,

        [Parameter()]
        [System.Boolean]
        $ContinuousLog,

        [Parameter()]
        [System.Uint32]
        $ContinuousLogSize,

        [Parameter()]
        [System.String[]]
        $ExcludeNamespace,

        [Parameter()]
        [System.Uint32[]]
        $ScheduleMonthly,

        [Parameter()]
        [System.String[]]
        $ScheduleWeekly,

        [Parameter()]
        [System.Int32]
        $ScheduleRunDuration,

        [Parameter()]
        [System.String]
        $ScheduleTime
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
        $schedule = (Get-FSRMClassification).Schedule

        # Create a splat to use to create the new Scheduled Task
        $splat = @{}

        if ($PSBoundParameters.ContainsKey('ScheduleMonthly'))
        {
            # The Schedule monthly is passed in as [System.Uint32[]].
            # DSC does not support [System.Int32[]] types as parameters.
            # But the New-FSRMScheduledTask Monthly parameter only supports [System.Int32[]] types.
            # So this must be converted manually. Cast does not seem to work here.
            $convertedScheduleMonthly = `
                [System.Array]::CreateInstance([System.Int32],$ScheduleMonthly.Length)
            for ($i=0; $i -lt $ScheduleMonthly.Length; $i++) {
                $convertedScheduleMonthly[$i] = $ScheduleMonthly[$i]
            }
            $splat += @{ Monthly = $convertedScheduleMonthly }
        }
        elseif ( $schedule.Monthly )
        {
            $splat += @{ Monthly = $schedule.Monthly }
        }

        if ($PSBoundParameters.ContainsKey('ScheduleWeekly'))
        {
            $splat += @{ Weekly = $ScheduleWeekly }
        }
        elseif ( $schedule.Weekly )
        {
            $splat += @{ Weekly = $schedule.Weekly }
        }

        if ($PSBoundParameters.ContainsKey('ScheduleRunDuration'))
        {
            $splat += @{ RunDuration = $ScheduleRunDuration }
        }
        elseif ( $schedule.RunDuration )
        {
            $splat += @{ RunDuration = $schedule.RunDuration }
        }

        if ($PSBoundParameters.ContainsKey('ScheduleTime'))
        {
            $splat += @{ Time = $ScheduleTime }
        }
        elseif ( $schedule.Time )
        {
            $splat += @{ Time = $schedule.Time }
        }

        # Remove the schedule parameters
        $null = $PSBoundParameters.Remove('ScheduleMonthly')
        $null = $PSBoundParameters.Remove('ScheduleWeekly')
        $null = $PSBoundParameters.Remove('ScheduleRunDuration')
        $null = $PSBoundParameters.Remove('ScheduleTime')

        # Add the new scheduled task parameter
        $newSchedule = New-FSRMScheduledTask @Splat
        $null = $PSBoundParameters.Add('Schedule',$newSchedule)

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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Id,

        [Parameter()]
        [System.Boolean]
        $Continuous,

        [Parameter()]
        [System.Boolean]
        $ContinuousLog,

        [Parameter()]
        [System.Uint32]
        $ContinuousLogSize,

        [Parameter()]
        [System.String[]]
        $ExcludeNamespace,

        [Parameter()]
        [System.Uint32[]]
        $ScheduleMonthly,

        [Parameter()]
        [System.String[]]
        $ScheduleWeekly,

        [Parameter()]
        [System.Int32]
        $ScheduleRunDuration,

        [Parameter()]
        [System.String]
        $ScheduleTime
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingClassificationMessage) `
            -f $Id
        ) -join '' )

    # Lookup the existing Classification
    $classification = Get-FSRMClassification

    # The Classification exists already - check the parameters
    if (($Continuous) -and ($classification.Continuous -ne $Continuous))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'Continuous'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ContinuousLog) -and ($classification.ContinuousLog -ne $ContinuousLog))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'ContinuousLog'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ContinuousLogSize) -and ($classification.ContinuousLogSize -ne $ContinuousLogSize))
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
            -DifferenceObject ($classification.ExcludeNamespace,@(),1 -ne $null)[0]).Count -ne 0)
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
            -DifferenceObject ($classification.Schedule.Monthly,1 -ne $null)[0]).Count -ne 0)
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
            -DifferenceObject ($classification.Schedule.Weekly,1 -ne $null)[0]).Count -ne 0)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'ScheduleWeekly'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ScheduleRunDuration) -and ($lassification.Schedule.RunDuration -ne $ScheduleRunDuration))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ClassificationNeedsUpdateMessage) `
                -f $Id,'ScheduleRunDuration'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($ScheduleTime) -and ($classification.Schedule.Time -ne $ScheduleTime))
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
