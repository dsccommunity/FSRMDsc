$fileScreenTemplate = @{
    Name            = 'IntegrationTest'
    Description     = 'Integration Test'
    Ensure          = 'Present'
    Active          = $false
    IncludeGroup    = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
}
$fileScreenTemplateAction = @{
    Type = 'Email'
    Subject = '[FileScreen Threshold]% FileScreen threshold exceeded'
    Body = 'User [Source Io Owner] has exceed the [FileScreen Threshold]% FileScreen threshold for FileScreen on [FileScreen Path] on server [Server]. The FileScreen limit is [FileScreen Limit MB] MB and the current usage is [FileScreen Used MB] MB ([FileScreen Used Percent]% of limit).'
    MailBCC = ''
    MailCC = 'fileserveradmins@contoso.com'
    MailTo = '[Source Io Owner Email]'
}

Configuration BMD_cFSRMFileScreenTemplateAction_Config {
    Import-DscResource -ModuleName cFSRM
    node localhost {
       cFSRMFileScreenTemplateAction Integration_Test {
            Name            = $fileScreenTemplate.Name
            Type            = $fileScreenTemplateAction.Type
            Subject         = $fileScreenTemplateAction.Subject
            Body            = $fileScreenTemplateAction.Body
            MailBCC         = $fileScreenTemplateAction.MailBCC
            MailCC          = $fileScreenTemplateAction.MailCC
            MailTo          = $fileScreenTemplateAction.MailTo
        }
    }
}
