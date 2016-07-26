$quotaTemplate = @{
    Name = 'IntegrationTest'
    Description = 'Integration Test'
    Ensure = 'Present'
    Size = 5GB
    SoftLimit = $false
    ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
}
$quotaAction = @{
    Type = 'Email'
    Subject = '[FileScreen Threshold]% FileScreen threshold exceeded'
    Body = 'User [Source Io Owner] has exceed the [FileScreen Threshold]% FileScreen threshold for FileScreen on [FileScreen Path] on server [Server]. The FileScreen limit is [FileScreen Limit MB] MB and the current usage is [FileScreen Used MB] MB ([FileScreen Used Percent]% of limit).'
    MailBCC = ''
    MailCC = 'fileserveradmins@contoso.com'
    MailTo = '[Source Io Owner Email]'
}

Configuration MSFT_FSRMQuotaTemplateAction_Config {
    Import-DscResource -ModuleName FSRMDsc
    node localhost {
       FSRMQuotaTemplateAction Integration_Test {
            Name            = $quotaTemplate.Name
            Percentage      = $quotaTemplate.ThresholdPercentages[0]
            Type            = $quotaAction.Type
            Subject         = $quotaAction.Subject
            Body            = $quotaAction.Body
            MailBCC         = $quotaAction.MailBCC
            MailCC          = $quotaAction.MailCC
            MailTo          = $quotaAction.MailTo
        }
    }
}
