configuration Sample_cFSRMQuotaTemplate
{
    Import-DscResource -Module cFSRMQuotas

    Node $NodeName
    {
        cFSRMQuotaTemplate HardLimit5GB
        {
            Name = '5 GB Limit'
            Description = '5 GB Hard Limit'
            Ensure = 'Present'
            Size = 5GB
            SoftLimit = $False
            ThresholdPercentages = @( 85, 100 )
        } # End of cFSRMQuotaTemplate Resource

        cFSRMQuotaTemplateAction HardLimit5GBEmail85
        {
            Name = '5 GB Limit'
            Percentage = 85
            Ensure = 'Present'
            Type = 'Email'
            Subject = '[Quota Threshold]% quota threshold exceeded'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'           
            DependsOn = "[cFSRMQuotaTemplate]HardLimit5GB" 
        } # End of cFSRMQuotaTemplateAction Resource

        cFSRMQuotaTemplateAction HardLimit5GBEvent85
        {
            Name = '5 GB Limit'
            Percentage = 85
            Ensure = 'Present'
            Type = 'Event'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            EventType = 'Warning'
            DependsOn = "[cFSRMQuotaTemplate]HardLimit5GB" 
        } # End of cFSRMQuotaTemplateAction Resource

        cFSRMQuotaTemplateAction HardLimit5GBEmail100
        {
            Name = '5 GB Limit'
            Percentage = 100
            Ensure = 'Present'
            Type = 'Email'
            Subject = '[Quota Threshold]% quota threshold exceeded'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'
            DependsOn = "[cFSRMQuotaTemplate]HardLimit5GB" 
        } # End of cFSRMQuotaTemplateAction Resource
    } # End of Node
} # End of Configuration
