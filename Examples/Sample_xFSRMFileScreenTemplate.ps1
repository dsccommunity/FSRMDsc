configuration Sample_FSRMFileScreenTemplate
{
    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMFileScreenTemplate FileScreenSomeFiles
        {
            Name = 'Block Some Files'
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            Active = $true
            IncludeGroup = 'Audio and Video Files','Executable Files','Backup Files'
        } # End of FSRMFileScreenTemplate Resource

        FSRMFileScreenTemplateAction FileScreenSomeFilesEmail
        {
            Name = 'Block Some Files'
            Ensure = 'Present'
            Type = 'Email'
            Subject = 'Unauthorized file matching [Violated File Group] file group detected'
            Body = 'The system detected that user [Source Io Owner] attempted to save [Source File Path] on [File Screen Path] on server [Server]. This file matches the [Violated File Group] file group which is not permitted on the system.'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'
            DependsOn = "[FSRMFileScreenTemplate]FileScreenSomeFiles"
        } # End of FSRMFileScreenTemplateAction Resource

        FSRMFileScreenTemplateAction FileScreenSomeFilesEvent
        {
            Name = 'Block Some Files'
            Ensure = 'Present'
            Type = 'Event'
            Body = 'The system detected that user [Source Io Owner] attempted to save [Source File Path] on [File Screen Path] on server [Server]. This file matches the [Violated File Group] file group which is not permitted on the system.'
            EventType = 'Warning'
            DependsOn = "[FSRMFileScreenTemplate]FileScreenSomeFiles"
        } # End of FSRMFileScreenTemplateAction Resource
    } # End of Node
} # End of Configuration
