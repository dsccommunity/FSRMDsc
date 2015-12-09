configuration Sample_cFSRMFileScreenException
{
    Import-DscResource -Module cFSRM

    Node $NodeName
    {
        cFSRMFileScreenException DUsersFileScreenException
        {
            Path = 'd:\users'
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            IncludeGroup = 'E-mail Files'
        } # End of cFSRMFileScreenException Resource
    } # End of Node
} # End of Configuration
