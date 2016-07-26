configuration Sample_FSRMClassificationProperty_SingleChoice
{
    Import-DscResource -Module FSRM

    Node $NodeName
    {
        FSRMClassificationProperty PrivacyClasificationProperty
        {
            Name = 'Privacy'
            Type = 'SingleChoice'
            DisplayName = 'File Privacy'
            Description = 'File Privacy Property'
            Ensure = 'Present'
            PossibleValue = 'Top Secret','Secret','Confidential'
        } # End of FSRMClassificationProperty Resource
    } # End of Node
} # End of Configuration
