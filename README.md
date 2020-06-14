# FSRMDsc

[![Build Status](https://dev.azure.com/dsccommunity/FSRMDsc/_apis/build/status/dsccommunity.FSRMDsc?branchName=master)](https://dev.azure.com/dsccommunity/FSRMDsc/_build/latest?definitionId=18&branchName=master)
![Code Coverage](https://img.shields.io/azure-devops/coverage/dsccommunity/FSRMDsc/18/master)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/dsccommunity/FSRMDsc/18/master)](https://dsccommunity.visualstudio.com/FSRMDsc/_test/analytics?definitionId=18&contextType=build)
[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/FSRMDsc?label=FSRMDsc%20Preview)](https://www.powershellgallery.com/packages/FSRMDsc/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/FSRMDsc?label=FSRMDsc)](https://www.powershellgallery.com/packages/FSRMDsc/)

## Code of Conduct

This project has adopted [this code of conduct](CODE_OF_CONDUCT.md).

## Releases

For each merge to the branch `master` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

The **FSRMDsc** module contains DSC resources for configuring Windows File Server
Resource Manager.

- **FSRMSettings** configures FSRM settings.
- **FSRMClassification** configures FSRM Classification settings.
- **FSRMClassificationProperty** configures FSRM Classification Property Definitions.
- **FSRMClassificationPropertyValue** configures FSRM Classification Property
  Definition Values. This resource only needs to be used if the Description of a
  Classification Property Definition Value must be set.
- **FSRMClassificationRule** configures FSRM Classification Rules.
- **FSRMFileScreen** configures FSRM File Screen.
- **FSRMFileScreenAction** configures FSRM File Screen Actions for File Screens.
- **FSRMFileScreenTemplate** configures FSRM File Screen Templates.
- **FSRMFileScreenTemplateAction** configures FSRM File Screen Template Actions
  for File Screen Templates.
- **FSRMFileScreenException** configures FSRM File Screen Exceptions.
- **FSRMFileGroup** configures FSRM File Groups.
- **FSRMQuota** configures FSRM Quotas.
- **FSRMQuotaAction** configures FSRM Quota Actions for Quotas.
- **FSRMQuotaTemplate** configures FSRM Quota Templates.
- **FSRMQuotaTemplateAction** configures FSRM Quota Template Actions for Quota Templates.
- **FSRMAutoQuota** configures FSRM Auto Quotas.

**This project is not maintained or supported by Microsoft.**

This project has adopted this [Open Source Code of Conduct](CODE_OF_CONDUCT.md).

## Documentation and Examples

For a full list of resources in FSRMDsc and examples on their use, check out
the [FSRMDsc wiki](https://github.com/dsccommunity/FSRMDsc/wiki).
