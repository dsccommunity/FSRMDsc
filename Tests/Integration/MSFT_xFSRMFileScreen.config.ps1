$fileScreen = @{
    Path            = $ENV:Temp
    Description     = 'Integration Test'
    Ensure          = 'Present'
    Active          = $false
    IncludeGroup    = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
    Template        = (Get-FSRMFileScreenTemplate | Select-Object -First 1).Name
    MatchesTemplate = $false
}

Configuration MSFT_xFSRMFileScreen_Config {
    Import-DscResource -ModuleName xFSRM
    node localhost {
       xFSRMFileScreen Integration_Test {
            Path            = $fileScreen.Path
            Description     = $fileScreen.Description
            Ensure          = $fileScreen.Ensure
            Active          = $fileScreen.Active
            IncludeGroup    = $fileScreen.IncludeGroup
            Template        = $fileScreen.Template
            MatchesTemplate = $fileScreen.MatchesTemplate
        }
    }
}
