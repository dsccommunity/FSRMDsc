configuration Sample_xFSRMClassificationProperty_SingleChoice
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMClassificationProperty PrivacyClasificationProperty
        {
            Name = 'Privacy'
            Type = 'SingleChoice'
            DisplayName = 'File Privacy'
            Description = 'File Privacy Property'
            Ensure = 'Present'
            PossibleValue = 'Top Secret','Secret','Confidential'
        } # End of xFSRMClassificationProperty Resource
    } # End of Node
} # End of Configuration