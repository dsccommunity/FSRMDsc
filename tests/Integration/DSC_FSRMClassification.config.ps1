Configuration DSC_FSRMClassification_Config {
    Import-DscResource -ModuleName FSRMDsc

    node localhost {
       FSRMClassification Integration_Test {
            Id                  = $Node.Id
            Continuous          = $Node.Continuous
            ContinuousLog       = $Node.ContinuousLog
            ContinuousLogSize   = $Node.ContinuousLogSize
            ExcludeNamespace    = $Node.ExcludeNamespace
            ScheduleMonthly     = $Node.ScheduleMonthly
            ScheduleRunDuration = $Node.ScheduleRunDuration
            ScheduleTime        = $Node.ScheduleTime
        }
    }
}
