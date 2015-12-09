configuration Sample_cFSRMClassificationProperty_YesNo
{
    Import-DscResource -Module cFSRM

    Node $NodeName
    {
        cFSRMClassificationProperty ConfidentialFiles
        {
            Name = 'Confidential'
            Type = 'YesNo'
            Description = 'Is this file a confidential file'
            Ensure = 'Present'
        } # End of cFSRMClassificationProperty Resource
    } # End of Node
} # End of Configuration