configuration Sample_cFSRMFileScreen_UsingTemplate
{
    Import-DscResource -Module cFSRMFileScreens

    Node $NodeName
    {
        cFSRMFileScreen DUsersFileScreens
        {
            Path = 'd:\users'
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            Template = 'Block Some Files'
            MatchesTemplate = $true 
        } # End of cFSRMFileScreen Resource
    } # End of Node
} # End of Configuration
