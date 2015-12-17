configuration Sample_xFSRMQuota_UsingTemplate
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMQuota DUsers
        {
            Path = 'd:\Users'
            Description = '100 MB Limit'
            Ensure = 'Present'
            Template = '100 MB Limit'
            MatchesTemplate = $true
        } # End of xFSRMQuota Resource
    } # End of Node
} # End of Configuration
