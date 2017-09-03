<#
    .EXAMPLE
        This configuration will create a FSRM Single Choice Classification Property called Privacy.
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
        FSRMClassificationProperty PrivacyClasificationProperty
        {
            Name          = 'Privacy'
            Type          = 'SingleChoice'
            DisplayName   = 'File Privacy'
            Description   = 'File Privacy Property'
            Ensure        = 'Present'
            PossibleValue = 'Top Secret', 'Secret', 'Confidential'
        } # End of FSRMClassificationProperty Resource
    } # End of Node
} # End of Configuration
