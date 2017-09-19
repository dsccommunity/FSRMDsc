<#
    .EXAMPLE
        This configuration will assign the 'Block Some Files' file screen template to the
        path 'D:\Users'. It will also force the File Screen assigned to this path to
        exactly match the 'Block Some Files' template. Any changes to the actions, include
        groups or active setting on the File Screen assigned to this path will cause
        the File Screen to be removed and reapplied.
#>
Configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DscResource -Module FSRMDsc

    Node $NodeName
    {
        FSRMFileScreen DUsersFileScreens
        {
            Path            = 'd:\users'
            Description     = 'File Screen for Blocking Some Files'
            Ensure          = 'Present'
            Template        = 'Block Some Files'
            MatchesTemplate = $true
        } # End of FSRMFileScreen Resource
    } # End of Node
} # End of Configuration
