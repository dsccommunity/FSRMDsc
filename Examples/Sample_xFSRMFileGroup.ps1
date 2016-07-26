configuration Sample_FSRMFileGroup
{
    Import-DscResource -Module FSRMDSc

    Node $NodeName
    {
        FSRMFileGroup FSRMFileGroupPortableFiles
        {
            Name = 'Portable Document Files'
            Description = 'Files containing portable document formats'
            Ensure = 'Present'
            IncludePattern = '*.eps','*.pdf','*.xps'
        } # End of FSRMFileGroup Resource
    } # End of Node
} # End of Configuration
