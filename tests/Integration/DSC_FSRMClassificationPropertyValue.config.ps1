Configuration DSC_FSRMClassificationPropertyValue_Config {
    Import-DscResource -ModuleName FSRMDsc

    node localhost {
        FSRMClassificationPropertyValue Integration_Test {
            Name         = $Node.Name
            PropertyName = $Node.PropertyName
            Description  = $Node.Description
        }
    }
}
