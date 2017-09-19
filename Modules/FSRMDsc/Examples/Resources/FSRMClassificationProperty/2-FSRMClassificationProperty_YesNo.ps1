<#
    .EXAMPLE
        This configuration will create a FSRM Yes/No Classification Property called Confidential.
#>
Configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMClassificationProperty ConfidentialFiles
        {
            Name        = 'Confidential'
            Type        = 'YesNo'
            Description = 'Is this file a confidential file'
            Ensure      = 'Present'
        } # End of FSRMClassificationProperty Resource
    } # End of Node
} # End of Configuration