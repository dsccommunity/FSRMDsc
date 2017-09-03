<#
    .EXAMPLE
        This configuration will create a FSRM Classification Property Value called 'Public' assigned to
        the Classification Property called 'Privacy'.
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
        FSRMClassificationPropertyValue PublicClasificationPropertyValue
        {
            Name         = 'Public'
            PropertyName = 'Privacy'
            Description  = 'Publically accessible files.'
            Ensure       = 'Present'
        } # End of FSRMClassificationPropertyValue Resource
    } # End of Node
} # End of Configuration
