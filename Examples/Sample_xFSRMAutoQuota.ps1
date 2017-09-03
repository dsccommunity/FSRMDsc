# This configuration will assign an FSRM Auto Quota to the path 'd:\users' using the
# template '5 GB Limit'.
configuration Sample_FSRMAutoQuota
{
    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMAutoQuota DUsers
        {
            Path = 'd:\Users'
            Ensure = 'Present'
            Disabled = $false
            Template = '5 GB Limit'
        } # End of FSRMAutoQuota Resource
    } # End of Node
} # End of Configuration
