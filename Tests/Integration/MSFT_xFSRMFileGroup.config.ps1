$filegroup = @{
    Name = 'Test Group'
    Ensure = 'Present'
    Description = 'Test Description'
    IncludePattern = @('*.eps','*.pdf','*.xps')
    ExcludePattern = @('*.epsx')
}

Configuration MSFT_xFSRMFileGroup_Config {
    Import-DscResource -ModuleName xFSRM
    node localhost {
       xFSRMFileGroup Integration_Test {
            Name                       = $filegroup.Name
            Ensure                     = $filegroup.Ensure
            Description                = $filegroup.Description
            IncludePattern             = $filegroup.IncludePattern
            ExcludePattern             = $filegroup.ExcludePattern
        }
    }
}
