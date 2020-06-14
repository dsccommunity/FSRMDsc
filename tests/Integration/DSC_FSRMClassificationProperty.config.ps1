Configuration DSC_FSRMClassificationProperty_Config {
    Import-DscResource -ModuleName FSRMDsc

    node localhost {
       FSRMClassificationProperty Integration_Test {
            Name          = $Node.Name
            DisplayName   = $Node.DisplayName
            Type          = $Node.Type
            Ensure        = $Node.Ensure
            Description   = $Node.Description
            PossibleValue = $Node.PossibleValue
            Parameters    = $Node.Parameters
        }
    }
}
