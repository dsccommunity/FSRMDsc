configuration Sample_xFSRMQuota
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMQuota DUsers
        {
            Path = 'd:\Users'
            Description = '5 GB Hard Limit'
            Ensure = 'Present'
            Size = 5GB
            SoftLimit = $False
            ThresholdPercentages = @( 85, 100 )
        } # End of xFSRMQuota Resource

        xFSRMQuotaAction DUsersEmail85
        {
            Path = 'd:\Users'
            Percentage = 85
            Ensure = 'Present'
            Type = 'Email'
            Subject = '[Quota Threshold]% quota threshold exceeded'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'           
            DependsOn = "[xFSRMQuota]DUsers" 
        } # End of xFSRMQuotaAction Resource

        xFSRMQuotaAction DUsersEvent85
        {
            Path = 'd:\Users'
            Percentage = 85
            Ensure = 'Present'
            Type = 'Event'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            EventType = 'Warning'
            DependsOn = "[xFSRMQuotaTemplate]DUsers" 
        } # End of xFSRMQuotaAction Resource

        xFSRMQuotaAction DUsersEmail100
        {
            Path = 'd:\Users'
            Percentage = 100
            Ensure = 'Present'
            Type = 'Email'
            Subject = '[Quota Threshold]% quota threshold exceeded'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'
            DependsOn = "[xFSRMQuotaTemplate]DUsers" 
        } # End of xFSRMQuotaAction Resource
    } # End of Node
} # End of Configuration
