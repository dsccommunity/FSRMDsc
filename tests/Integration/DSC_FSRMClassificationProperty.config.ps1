Configuration DSC_FSRMNode_Config {
    Import-DscResource -ModuleName FSRMDsc

    node localhost {
       FSRMNode Integration_Test {
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
