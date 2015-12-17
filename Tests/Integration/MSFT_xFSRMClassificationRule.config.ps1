$classificationProperty = @{
    Name = 'IntegrationTest'
    Type = 'SingleChoice'
    PossibleValue = @( 'Value1' )
}
$classificationRule = @{
    Name                       = 'IntegrationTest'
    Description                = 'Test Rule Description'
    ClassificationMechanism    = 'Content Classifier'
    ContentRegularExpression   = @( 'Regex1','Regex2' )
    ContentString              = @( 'String1','String2' )
    ContentStringCaseSensitive = @( 'String1','String2' )
    Disabled                   = $false
    Flags                      = @( 1024 )
    Namespace                  = @( '[FolderUsage_MS=User Files]',$ENV:Temp )
    Parameters                 = @( 'FileName=*.doc','FSRMClearruleInternal=0' )
    Property                   = $classificationProperty.Name
    PropertyValue              = $classificationProperty.PossibleValue[0]
    ReevaluateProperty         = 'Never'
}

Configuration MSFT_xFSRMClassificationRule_Config {
    Import-DscResource -ModuleName xFSRM
    node localhost {
       xFSRMClassificationRule Integration_Test {
            Name                       = $classificationRule.Name
            Description                = $classificationRule.Description
            ClassificationMechanism    = $classificationRule.ClassificationMechanism
            ContentRegularExpression   = $classificationRule.ContentRegularExpression
            ContentString              = $classificationRule.ContentString
            ContentStringCaseSensitive = $classificationRule.ContentStringCaseSensitive
            Disabled                   = $classificationRule.Disabled
            Flags                      = $classificationRule.Flags
            Namespace                  = $classificationRule.Namespace
            Parameters                 = $classificationRule.Parameters
            Property                   = $classificationRule.Property
            PropertyValue              = $classificationRule.PropertyValue
            ReevaluateProperty         = $classificationRule.ReevaluateProperty
        }
    }
}
