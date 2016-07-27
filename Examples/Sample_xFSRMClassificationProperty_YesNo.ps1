configuration Sample_FSRMClassificationProperty_YesNo
{
    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMClassificationProperty ConfidentialFiles
        {
            Name = 'Confidential'
            Type = 'YesNo'
            Description = 'Is this file a confidential file'
            Ensure = 'Present'
        } # End of FSRMClassificationProperty Resource
    } # End of Node
} # End of Configuration
