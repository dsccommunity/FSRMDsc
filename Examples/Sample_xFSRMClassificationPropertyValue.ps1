configuration Sample_xFSRMClassificationPropertyValue
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMClassificationPropertyValue PublicClasificationPropertyValue
        {
            Name = 'Public'
            PropertyName = 'Privacy'
            Description = 'Publically accessible files.'
            Ensure = 'Present'
        } # End of xFSRMClassificationPropertyValue Resource
    } # End of Node
} # End of Configuration