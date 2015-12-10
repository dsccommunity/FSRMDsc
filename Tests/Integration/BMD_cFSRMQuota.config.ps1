$quota = @{
    Path = $ENV:Temp
    Description = 'Integration Test'
    Ensure = 'Present'
    Size = 5GB
    SoftLimit = $false
    ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
    Disabled = $false
}

Configuration BMD_cFSRMQuota_Config {
    Import-DscResource -ModuleName cFSRM
    node localhost {
       cFSRMQuota Integration_Test {
            Path = $quota.Path
            Description = $quota.Description
            Ensure = $quota.Ensure
            Size = $quota.Size
            SoftLimit = $quota.SoftLimit
            ThresholdPercentages = $quota.ThresholdPercentages
            Disabled = $quota.Disabled
        }
    }
}
