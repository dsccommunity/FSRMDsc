$filegroup = @{
    Name = 'Test Group'
    Ensure = 'Present'
    Description = 'Test Description'
    IncludePattern = @('*.eps','*.pdf','*.xps')
    ExcludePattern = @('*.epsx')
}

Configuration BMD_cFSRMFileGroup_Config {
    Import-DscResource -ModuleName cFSRM
    node localhost {
       cFSRMFileGroup Integration_Test {
            Name                       = $filegroup.Name
            Ensure                     = $filegroup.Ensure
            Description                = $filegroup.Description
            IncludePattern             = $filegroup.IncludePattern
            ExcludePattern             = $filegroup.ExcludePattern
        }
    }
}
