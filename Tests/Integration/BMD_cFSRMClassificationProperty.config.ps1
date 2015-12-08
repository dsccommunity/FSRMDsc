$classificationproperty = @{
    Name = 'IntegrationTest'
    DisplayName = 'Integration Test'
    Type = 'SingleChoice'
    Ensure = 'Present'
    Description = 'Integration Test Property'
    PossibleValue = @( 'Value1', 'Value2', 'Value3' )
    Parameters = @( 'Parameter1=Value1', 'Parameter2=Value2')
}

Configuration BMD_cFSRMClassificationProperty_Config {
    Import-DscResource -ModuleName cFSRM
    node localhost {
       cFSRMClassificationProperty Integration_Test {
            Name          = $classificationproperty.Name
            DisplayName   = $classificationproperty.DisplayName
            Type          = $classificationproperty.Type
            Ensure        = $classificationproperty.Ensure
            Description   = $classificationproperty.Description
            PossibleValue = $classificationproperty.PossibleValue
            Parameters    = $classificationproperty.Parameters
        }
    }
}
