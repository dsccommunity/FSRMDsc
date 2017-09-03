<#
    .EXAMPLE
        This configuration will assign an FSRM Quota to the path 'D:\Users', with a Hard Limit
        of 5GB and threshold percentages of 85 and 100. An e-mail action is bound to each threshold.
        An event action is also bound to the 85 percent threshold.
#>
Configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMQuota DUsers
        {
            Path                 = 'd:\Users'
            Description          = '5 GB Hard Limit'
            Ensure               = 'Present'
            Size                 = 5GB
            SoftLimit            = $False
            ThresholdPercentages = @( 85, 100 )
        } # End of FSRMQuota Resource

        FSRMQuotaAction DUsersEmail85
        {
            Path       = 'd:\Users'
            Percentage = 85
            Ensure     = 'Present'
            Type       = 'Email'
            Subject    = '[Quota Threshold]% quota threshold exceeded'
            Body       = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC    = ''
            MailCC     = 'fileserveradmins@contoso.com'
            MailTo     = '[Source Io Owner Email]'
            DependsOn  = "[FSRMQuota]DUsers"
        } # End of FSRMQuotaAction Resource

        FSRMQuotaAction DUsersEvent85
        {
            Path       = 'd:\Users'
            Percentage = 85
            Ensure     = 'Present'
            Type       = 'Event'
            Body       = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            EventType  = 'Warning'
            DependsOn  = "[FSRMQuotaTemplate]DUsers"
        } # End of FSRMQuotaAction Resource

        FSRMQuotaAction DUsersEmail100
        {
            Path       = 'd:\Users'
            Percentage = 100
            Ensure     = 'Present'
            Type       = 'Email'
            Subject    = '[Quota Threshold]% quota threshold exceeded'
            Body       = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC    = ''
            MailCC     = 'fileserveradmins@contoso.com'
            MailTo     = '[Source Io Owner Email]'
            DependsOn  = "[FSRMQuotaTemplate]DUsers"
        } # End of FSRMQuotaAction Resource
    } # End of Node
} # End of Configuration
