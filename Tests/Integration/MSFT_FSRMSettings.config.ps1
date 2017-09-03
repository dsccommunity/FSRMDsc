$settings = @{
    IsSingleInstance         = 'Yes'
    SmtpServer               = 'smtp.contoso.com'
    AdminEmailAddress        = 'admin@contoso.com'
    FromEmailAddress         = 'fsrm@contoso.com'
    CommandNotificationLimit = 10
    EmailNotificationLimit   = 20
    EventNotificationLimit   = 30
}

Configuration MSFT_FSRMSettings_Config {
    Import-DscResource -ModuleName FSRMDsc
    node localhost {
       FSRMSettings Integration_Test {
            IsSingleInstance         = $settings.IsSingleInstance
            SmtpServer               = $settings.SmtpServer
            AdminEmailAddress        = $settings.AdminEmailAddress
            FromEmailAddress         = $settings.FromEmailAddress
            CommandNotificationLimit = $settings.CommandNotificationLimit
            EmailNotificationLimit   = $settings.EmailNotificationLimit
            EventNotificationLimit   = $settings.EventNotificationLimit
        }
    }
}
