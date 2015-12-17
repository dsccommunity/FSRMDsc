configuration Sample_xFSRMClassificationProperty_YesNo
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMClassificationProperty ConfidentialFiles
        {
            Name = 'Confidential'
            Type = 'YesNo'
            Description = 'Is this file a confidential file'
            Ensure = 'Present'
        } # End of xFSRMClassificationProperty Resource
    } # End of Node
} # End of Configuration