configuration Sample_cFSRMClassificationRule
{
    Import-DscResource -Module cFSRM

    Node $NodeName
    {
        cFSRMClassificationRule ConfidentialPrivacyClasificationRule
        {
            Name = 'Confidential'
            Description = 'Set Confidential'
            Ensure = 'Present'
            Property = 'Privacy'
            PropertyValue = 'Confidential'
            ClassificationMechanism = ''
            ContentString = 'Confidential'
            Namespace = '[FolderUsage_MS=User Files]','d:\Users'
            ReevaluateProperty = 'Overwrite'                
        } # End of cFSRMClassificationRule Resource
    } # End of Node
} # End of Configuration