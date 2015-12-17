configuration Sample_xFSRMFileGroup
{
    Import-DscResource -Module xFSRM

    Node $NodeName
    {
        xFSRMFileGroup FSRMFileGroupPortableFiles
        {
            Name = 'Portable Document Files'
            Description = 'Files containing portable document formats'
            Ensure = 'Present'
            IncludePattern = '*.eps','*.pdf','*.xps'
        } # End of xFSRMFileGroup Resource
    } # End of Node
} # End of Configuration