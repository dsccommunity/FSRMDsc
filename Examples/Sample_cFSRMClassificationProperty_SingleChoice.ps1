configuration Sample_cFSRMClassificationProperty_SingleChoice
{
    Import-DscResource -Module cFSRMClassifications

    Node $NodeName
    {
        cFSRMClassificationProperty PrivacyClasificationProperty
        {
            Name = 'Privacy'
            Type = 'SingleChoice'
            DisplayName = 'File Privacy'
            Description = 'File Privacy Property'
            Ensure = 'Present'
            PossibleValue = 'Top Secret','Secret','Confidential'
        } # End of cFSRMClassificationProperty Resource
    } # End of Node
} # End of Configuration