$quotaTemplate = @{
    Name = 'IntegrationTest'
    Description = 'Integration Test'
    Ensure = 'Present'
    Size = 5GB
    SoftLimit = $false
    ThresholdPercentages = [System.Collections.ArrayList]@( 85, 100 )
}

Configuration BMD_cFSRMQuotaTemplate_Config {
    Import-DscResource -ModuleName cFSRM
    node localhost {
       cFSRMQuotaTemplate Integration_Test {
            Name = $quotaTemplate.Name
            Description = $quotaTemplate.Description
            Ensure = $quotaTemplate.Ensure
            Size = $quotaTemplate.Size
            SoftLimit = $quotaTemplate.SoftLimit
            ThresholdPercentages = $quotaTemplate.ThresholdPercentages
        }
    }
}
