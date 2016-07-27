configuration Sample_FSRMClassification
{
    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMClassification FSRMClassificationSettings
        {
            Id = 'Default'
            Continuous = $True
            ContinuousLog = $True
            ContinuousLogSize = 2048
            ScheduleWeekly = 'Monday','Tuesday','Wednesday'
            ScheduleRunDuration = 4
            ScheduleTime = '23:30'
        } # End of FSRMClassification Resource
    } # End of Node
} # End of Configuration
