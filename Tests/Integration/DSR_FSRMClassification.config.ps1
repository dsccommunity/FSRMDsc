$classification = @{
    Id                  = 'Default'
    Continuous          = $False
    ContinuousLog       = $False
    ContinuousLogSize   = 2048
    ExcludeNamespace    = @('[AllVolumes]\$Extend /','[AllVolumes]\System Volume Information /s')
    ScheduleMonthly     = @( 12,13 )
    ScheduleRunDuration = 10
    ScheduleTime        = '13:00'
}

Configuration DSR_FSRMClassification_Config {
    Import-DscResource -ModuleName FSRMDsc
    node localhost {
       FSRMClassification Integration_Test {
            Id                  = $classification.Id
            Continuous          = $classification.Continuous
            ContinuousLog       = $classification.ContinuousLog
            ContinuousLogSize   = $classification.ContinuousLogSize
            ExcludeNamespace    = $classification.ExcludeNamespace
            ScheduleMonthly     = $classification.ScheduleMonthly
            ScheduleRunDuration = $classification.ScheduleRunDuration
            ScheduleTime        = $classification.ScheduleTime
        }
    }
}
