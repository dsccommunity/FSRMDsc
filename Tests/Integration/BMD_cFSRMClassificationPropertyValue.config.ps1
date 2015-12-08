$classificationproperty = @{
    Name = 'Privacy'
    Type = 'SingleChoice'
    PossibleValue = @( 'Top Secret' )
}
$classificationPropertyValue = @{
    PropertyName = $classificationproperty.Name
    Name = $classificationproperty.PossibleValue[0]
    Description = 'Top Secret Description'
}

Configuration BMD_cFSRMClassificationPropertyValue_Config {
    Import-DscResource -ModuleName cFSRM
    node localhost {
       cFSRMClassificationPropertyValue Integration_Test {
            Name = $classificationPropertyValue.Name
            PropertyName = $classificationPropertyValue.PropertyName
            Description = $classificationpropertyValue.Description
        }
    }
}
