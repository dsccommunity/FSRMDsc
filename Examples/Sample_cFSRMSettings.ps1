configuration Sample_cFSRMSettings
{
    Import-DscResource -Module cFSRM

    Node $NodeName
    {
        cFSRMSettings FSRMSettings
        {
            Id = 'Default'
            SmtpServer = 'smtp.contoso.com'
            AdminEmailAddress = 'fsadmin@contoso.com'
            FromEmailAddress = 'fsuser@contoso.com'
            CommandNotificationLimit = 90
            EmailNotificationLimit = 90
            EventNotificationLimit = 90
        } # End of cFSRMSettings Resource
    } # End of Node
} # End of Configuration
