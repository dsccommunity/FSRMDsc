configuration Sample_cFSRMClassificationPropertyValue
{
    Import-DscResource -Module cFSRM

    Node $NodeName
    {
        cFSRMClassificationPropertyValue PublicClasificationPropertyValue
        {
            Name = 'Public'
            PropertyName = 'Privacy'
            Description = 'Publically accessible files.'
            Ensure = 'Present'
        } # End of cFSRMClassificationPropertyValue Resource
    } # End of Node
} # End of Configuration