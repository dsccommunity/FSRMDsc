configuration Sample_FSRMClassificationPropertyValue
{
    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMClassificationPropertyValue PublicClasificationPropertyValue
        {
            Name = 'Public'
            PropertyName = 'Privacy'
            Description = 'Publically accessible files.'
            Ensure = 'Present'
        } # End of FSRMClassificationPropertyValue Resource
    } # End of Node
} # End of Configuration