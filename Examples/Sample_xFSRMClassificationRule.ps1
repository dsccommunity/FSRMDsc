configuration Sample_xFSRMClassificationRule
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMClassificationRule ConfidentialPrivacyClasificationRule
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
        } # End of xFSRMClassificationRule Resource
    } # End of Node
} # End of Configuration