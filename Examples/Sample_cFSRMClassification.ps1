configuration Sample_cFSRMClassification
{
    Import-DscResource -Module cFSRM

    Node $NodeName
    {
        cFSRMClassification FSRMClassificationSettings
        {
            Id = 'Default'
            Continuous = $True
            ContinuousLog = $True
            ContinuousLogSize = 2048
            ScheduleWeekly = 'Monday','Tuesday','Wednesday'
            ScheduleRunDuration = 4
            ScheduleTime = '23:30'
        } # End of cFSRMClassification Resource
    } # End of Node
} # End of Configuration
