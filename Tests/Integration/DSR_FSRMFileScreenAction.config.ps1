$fileScreen = @{
    Path            = $ENV:Temp
    Description     = 'Integration Test'
    Ensure          = 'Present'
    Active          = $false
    IncludeGroup    = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
    Template        = (Get-FSRMFileScreenTemplate | Select-Object -First 1).Name
    MatchesTemplate = $false
}
$fileScreenAction = @{
    Type = 'Email'
    Subject = '[FileScreen Threshold]% FileScreen threshold exceeded'
    Body = 'User [Source Io Owner] has exceed the [FileScreen Threshold]% FileScreen threshold for FileScreen on [FileScreen Path] on server [Server]. The FileScreen limit is [FileScreen Limit MB] MB and the current usage is [FileScreen Used MB] MB ([FileScreen Used Percent]% of limit).'
    MailBCC = ''
    MailCC = 'fileserveradmins@contoso.com'
    MailTo = '[Source Io Owner Email]'
}

Configuration DSR_FSRMFileScreenAction_Config {
    Import-DscResource -ModuleName FSRMDsc
    node localhost {
       FSRMFileScreenAction Integration_Test {
            Path            = $fileScreen.Path
            Type            = $fileScreenAction.Type
            Subject         = $fileScreenAction.Subject
            Body            = $fileScreenAction.Body
            MailBCC         = $fileScreenAction.MailBCC
            MailCC          = $fileScreenAction.MailCC
            MailTo          = $fileScreenAction.MailTo
        }
    }
}
