configuration Sample_FSRMQuota_UsingTemplate
{
    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMQuota DUsers
        {
            Path = 'd:\Users'
            Description = '100 MB Limit'
            Ensure = 'Present'
            Template = '100 MB Limit'
            MatchesTemplate = $true
        } # End of FSRMQuota Resource
    } # End of Node
} # End of Configuration
