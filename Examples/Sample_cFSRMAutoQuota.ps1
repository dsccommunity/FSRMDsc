configuration Sample_cFSRMAutoQuota
{
    Import-DscResource -Module cFSRM

    Node $NodeName
    {
        cFSRMAutoQuota DUsers
        {
            Path = 'd:\Users'
            Ensure = 'Present'
            Disabled = $false
            Template = '5 GB Limit'
        } # End of cFSRMAutoQuota Resource
    } # End of Node
} # End of Configuration
