$fileScreen = @{
    Path            = $ENV:Temp
    Description     = 'Integration Test'
    Ensure          = 'Present'
    Active          = $false
    IncludeGroup    = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
    Template        = (Get-FSRMFileScreenTemplate | Select-Object -First 1).Name
    MatchesTemplate = $false
}
$fileScreenException = @{
    Path            = $ENV:Temp
    Description     = 'Integration Test'
    Ensure          = 'Present'
    IncludeGroup    = [System.Collections.ArrayList]@( 'Audio and Video Files','Executable Files','Backup Files' )
}

Configuration BMD_cFSRMFileScreenException_Config {
    Import-DscResource -ModuleName cFSRM
    node localhost {
       cFSRMFileScreenException Integration_Test {
            Path            = $fileScreenException.Path
            Description     = $fileScreenException.Description
            Ensure          = $fileScreenException.Ensure
            IncludeGroup    = $fileScreenException.IncludeGroup
        }
    }
}
