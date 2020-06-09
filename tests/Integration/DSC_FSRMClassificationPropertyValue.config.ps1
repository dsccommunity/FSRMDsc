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

Configuration DSC_FSRMClassificationPropertyValue_Config {
    Import-DscResource -ModuleName FSRMDsc
    node localhost {
       FSRMClassificationPropertyValue Integration_Test {
            Name = $classificationPropertyValue.Name
            PropertyName = $classificationPropertyValue.PropertyName
            Description = $classificationpropertyValue.Description
        }
    }
}
