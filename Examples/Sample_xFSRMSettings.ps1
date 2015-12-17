configuration Sample_xFSRMSettings
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMSettings FSRMSettings
        {
            Id = 'Default'
            SmtpServer = 'smtp.contoso.com'
            AdminEmailAddress = 'fsadmin@contoso.com'
            FromEmailAddress = 'fsuser@contoso.com'
            CommandNotificationLimit = 90
            EmailNotificationLimit = 90
            EventNotificationLimit = 90
        } # End of xFSRMSettings Resource
    } # End of Node
} # End of Configuration
