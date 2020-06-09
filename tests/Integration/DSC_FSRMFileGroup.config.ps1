$filegroup = @{
    Name = 'Test Group'
    Ensure = 'Present'
    Description = 'Test Description'
    IncludePattern = @('*.eps','*.pdf','*.xps')
    ExcludePattern = @('*.epsx')
}

Configuration DSC_FSRMFileGroup_Config {
    Import-DscResource -ModuleName FSRMDsc
    node localhost {
       FSRMFileGroup Integration_Test {
            Name                       = $filegroup.Name
            Ensure                     = $filegroup.Ensure
            Description                = $filegroup.Description
            IncludePattern             = $filegroup.IncludePattern
            ExcludePattern             = $filegroup.ExcludePattern
        }
    }
}
