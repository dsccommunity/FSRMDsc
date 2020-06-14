Configuration DSC_FSRMSettings_Config {
    Import-DscResource -ModuleName FSRMDsc

    node localhost {
       FSRMSettings Integration_Test {
            IsSingleInstance         = $Node.IsSingleInstance
            SmtpServer               = $Node.SmtpServer
            AdminEmailAddress        = $Node.AdminEmailAddress
            FromEmailAddress         = $Node.FromEmailAddress
            CommandNotificationLimit = $Node.CommandNotificationLimit
            EmailNotificationLimit   = $Node.EmailNotificationLimit
            EventNotificationLimit   = $Node.EventNotificationLimit
        }
    }
}
