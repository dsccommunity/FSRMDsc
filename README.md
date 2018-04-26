# FSRMDsc

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

This project has adopted this [Open Source Code of Conduct](CODEOFCONDUCT.md).

This module should meet the [PowerShell DSC Resource Kit High Quality Resource
Module Guidelines](https://github.com/PowerShell/DscResources/blob/master/HighQualityModuleGuidelines.md).

## Documentation and Examples

For a full list of resources in FSRMDsc and examples on their use, check out
the [FSRMDsc wiki](https://github.com/PlagueHO/FSRMDsc/wiki).

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/9rjyjap2wl48xels/branch/master?svg=true)](https://ci.appveyor.com/project/PlagueHO/FSRMDsc/branch/master)
[![codecov](https://codecov.io/gh/PlagueHO/FSRMDsc/branch/master/graph/badge.svg)](https://codecov.io/gh/PlagueHO/FSRMDsc/branch/master)

This is the branch containing the latest release - no contributions should be made
directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/9rjyjap2wl48xels/branch/dev?svg=true)](https://ci.appveyor.com/project/PlagueHO/FSRMDsc/branch/dev)
[![codecov](https://codecov.io/gh/PlagueHO/FSRMDsc/branch/dev/graph/badge.svg)](https://codecov.io/gh/PlagueHO/FSRMDsc/branch/dev)

This is the development branch to which contributions should be proposed by contributors
as pull requests. This development branch will periodically be merged to the master
branch, and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).
