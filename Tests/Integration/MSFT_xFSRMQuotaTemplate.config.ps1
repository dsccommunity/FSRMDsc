$quotaTemplate = @{
    Name = 'IntegrationTest'
    Description = 'Integration Test'
    Ensure = 'Present'
    Size = 5GB
    SoftLimit = $false
    ThresholdPercentages = [System.Collections.ArrayList]@( 85, 100 )
}

Configuration MSFT_xFSRMQuotaTemplate_Config {
    Import-DscResource -ModuleName xFSRM
    node localhost {
       xFSRMQuotaTemplate Integration_Test {
            Name = $quotaTemplate.Name
            Description = $quotaTemplate.Description
            Ensure = $quotaTemplate.Ensure
            Size = $quotaTemplate.Size
            SoftLimit = $quotaTemplate.SoftLimit
            ThresholdPercentages = $quotaTemplate.ThresholdPercentages
        }
    }
}
