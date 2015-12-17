configuration Sample_xFSRMAutoQuota
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMAutoQuota DUsers
        {
            Path = 'd:\Users'
            Ensure = 'Present'
            Disabled = $false
            Template = '5 GB Limit'
        } # End of xFSRMAutoQuota Resource
    } # End of Node
} # End of Configuration
