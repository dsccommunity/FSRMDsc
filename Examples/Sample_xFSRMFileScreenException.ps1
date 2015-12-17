configuration Sample_xFSRMFileScreenException
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMFileScreenException DUsersFileScreenException
        {
            Path = 'd:\users'
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            IncludeGroup = 'E-mail Files'
        } # End of xFSRMFileScreenException Resource
    } # End of Node
} # End of Configuration
