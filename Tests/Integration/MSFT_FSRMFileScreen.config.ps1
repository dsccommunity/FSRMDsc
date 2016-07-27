$fileScreen = @{
    Path            = $ENV:Temp
    Description     = 'Integration Test'
    Ensure          = 'Present'
    Active          = $false
    IncludeGroup    = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
    Template        = (Get-FSRMFileScreenTemplate | Select-Object -First 1).Name
    MatchesTemplate = $false
}

Configuration MSFT_FSRMFileScreen_Config {
    Import-DscResource -ModuleName FSRMDsc
    node localhost {
       FSRMFileScreen Integration_Test {
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
