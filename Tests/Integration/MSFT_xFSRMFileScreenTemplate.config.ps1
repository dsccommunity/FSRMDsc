$fileScreenTemplate = @{
    Name            = 'IntegrationTest'
    Description     = 'Integration Test'
    Ensure          = 'Present'
    Active          = $false
    IncludeGroup    = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
}

Configuration MSFT_xFSRMFileScreenTemplate_Config {
    Import-DscResource -ModuleName xFSRM
    node localhost {
       xFSRMFileScreenTemplate Integration_Test {
            Name            = $fileScreenTemplate.Name
            Description     = $fileScreenTemplate.Description
            Ensure          = $fileScreenTemplate.Ensure
            Active          = $fileScreenTemplate.Active
            IncludeGroup    = $fileScreenTemplate.IncludeGroup
        }
    }
}
