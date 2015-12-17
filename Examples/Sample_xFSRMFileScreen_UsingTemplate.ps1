configuration Sample_xFSRMFileScreen_UsingTemplate
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMFileScreen DUsersFileScreens
        {
            Path = 'd:\users'
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            Template = 'Block Some Files'
            MatchesTemplate = $true 
        } # End of xFSRMFileScreen Resource
    } # End of Node
} # End of Configuration
