<#
    .EXAMPLE
        This will configure the FSRM Classification settings on this server.
        It enables Continous Mode, Logging and sets the maximum Log size to 2 MB.
        The Classification schedule is also set to Monday through Wednesday at 11:30pm
        and will run a maximum of 4 hours.
#>
Configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMClassification FSRMClassificationSettings
        {
            Id                  = 'Default'
            Continuous          = $True
            ContinuousLog       = $True
            ContinuousLogSize   = 2048
            ScheduleWeekly      = 'Monday', 'Tuesday', 'Wednesday'
            ScheduleRunDuration = 4
            ScheduleTime        = '23:30'
        } # End of FSRMClassification Resource
    } # End of Node
} # End of Configuration
