configuration Sample_cFSRMFileGroup
{
    Import-DscResource -Module cFSRM

    Node $NodeName
    {
        cFSRMFileGroup FSRMFileGroupPortableFiles
        {
            Name = 'Portable Document Files'
            Description = 'Files containing portable document formats'
            Ensure = 'Present'
            IncludePattern = '*.eps','*.pdf','*.xps'
        } # End of cFSRMFileGroup Resource
    } # End of Node
} # End of Configuration