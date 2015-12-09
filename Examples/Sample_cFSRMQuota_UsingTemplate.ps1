configuration Sample_cFSRMQuota_UsingTemplate
{
    Import-DscResource -Module cFSRM

    Node $NodeName
    {
        cFSRMQuota DUsers
        {
            Path = 'd:\Users'
            Description = '100 MB Limit'
            Ensure = 'Present'
            Template = '100 MB Limit'
            MatchesTemplate = $true
        } # End of cFSRMQuota Resource
    } # End of Node
} # End of Configuration
