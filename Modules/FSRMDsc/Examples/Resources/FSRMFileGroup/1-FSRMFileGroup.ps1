<#
    .EXAMPLE
        This configuration will create a FSRM File Group called 'Portable Document Files'.
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
        FSRMFileGroup FSRMFileGroupPortableFiles
        {
            Name           = 'Portable Document Files'
            Description    = 'Files containing portable document formats'
            Ensure         = 'Present'
            IncludePattern = '*.eps', '*.pdf', '*.xps'
        } # End of FSRMFileGroup Resource
    } # End of Node
} # End of Configuration
