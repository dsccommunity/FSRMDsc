# This configuration will create a FSRM Classification Rule called 'Confidential' that
# will assign a Privacy value of Confidential to any files containing the text
# Confidential in the folder d:\users or any folder categorized as 'User Files'.
configuration Sample_FSRMClassificationRule
{
    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMClassificationRule ConfidentialPrivacyClasificationRule
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
        } # End of FSRMClassificationRule Resource
    } # End of Node
} # End of Configuration
