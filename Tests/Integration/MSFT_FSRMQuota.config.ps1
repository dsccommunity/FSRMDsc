$quota = @{
    Path = $ENV:Temp
    Description = 'Integration Test'
    Ensure = 'Present'
    Size = 5GB
    SoftLimit = $false
    ThresholdPercentages = [System.Collections.ArrayList]@( 100 )
    Disabled = $false
}

Configuration MSFT_FSRMQuota_Config {
    Import-DscResource -ModuleName FSRMDsc
    node localhost {
       FSRMQuota Integration_Test {
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
