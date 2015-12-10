$fileScreenTemplate = @{
    Name            = 'IntegrationTest'
    Description     = 'Integration Test'
    Ensure          = 'Present'
    Active          = $false
    IncludeGroup    = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
}

Configuration BMD_cFSRMFileScreenTemplate_Config {
    Import-DscResource -ModuleName cFSRM
    node localhost {
       cFSRMFileScreenTemplate Integration_Test {
            Name            = $fileScreenTemplate.Name
            Description     = $fileScreenTemplate.Description
            Ensure          = $fileScreenTemplate.Ensure
            Active          = $fileScreenTemplate.Active
            IncludeGroup    = $fileScreenTemplate.IncludeGroup
        }
    }
}
