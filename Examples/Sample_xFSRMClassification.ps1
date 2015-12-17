configuration Sample_xFSRMClassification
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMClassification FSRMClassificationSettings
        {
            Id = 'Default'
            Continuous = $True
            ContinuousLog = $True
            ContinuousLogSize = 2048
            ScheduleWeekly = 'Monday','Tuesday','Wednesday'
            ScheduleRunDuration = 4
            ScheduleTime = '23:30'
        } # End of xFSRMClassification Resource
    } # End of Node
} # End of Configuration
