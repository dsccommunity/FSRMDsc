configuration Sample_FSRMSettings
{
    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMSettings FSRMSettings
        {
            Id = 'Default'
            SmtpServer = 'smtp.contoso.com'
            AdminEmailAddress = 'fsadmin@contoso.com'
            FromEmailAddress = 'fsuser@contoso.com'
            CommandNotificationLimit = 90
            EmailNotificationLimit = 90
            EventNotificationLimit = 90
        } # End of FSRMSettings Resource
    } # End of Node
} # End of Configuration
