Configuration DSC_FSRMClassificationRule_Config {
    Import-DscResource -ModuleName FSRMDsc

    node localhost {
       FSRMClassificationRule Integration_Test {
            Name                       = $Node.Name
            Description                = $Node.Description
            ClassificationMechanism    = $Node.ClassificationMechanism
            ContentRegularExpression   = $Node.ContentRegularExpression
            ContentString              = $Node.ContentString
            ContentStringCaseSensitive = $Node.ContentStringCaseSensitive
            Disabled                   = $Node.Disabled
            Flags                      = $Node.Flags
            Namespace                  = $Node.Namespace
            Parameters                 = $Node.Parameters
            Property                   = $Node.Property
            PropertyValue              = $Node.PropertyValue
            ReevaluateProperty         = $Node.ReevaluateProperty
        }
    }
}
