# This configuration will assign the '100 MB Limit' template to the path 'D:\Users'.
# It will also force the quota assigned to this path to exactly match the '100 MB Limit'
# template. Any changes to the thresholds or actions on the quota assigned to this path
# will cause the template to be removed and reapplied.
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
