$classificationproperty = @{
    Name = 'IntegrationTest'
    Type = 'SingleChoice'
    PossibleValue = @( 'Value1' )
}
$classificationPropertyValue = @{
    PropertyName = $classificationproperty.Name
    Name = $classificationproperty.PossibleValue[0]
    Description = 'Top Secret Description'
}

Configuration MSFT_xFSRMClassificationPropertyValue_Config {
    Import-DscResource -ModuleName xFSRM
    node localhost {
       xFSRMClassificationPropertyValue Integration_Test {
            Name = $classificationPropertyValue.Name
            PropertyName = $classificationPropertyValue.PropertyName
            Description = $classificationpropertyValue.Description
        }
    }
}
