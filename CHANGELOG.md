# Change log for FSRMDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- FSRMDsc
  - Automatically publish documentation to GitHub Wiki - Fixes [Issue #41](https://github.com/dsccommunity/FSRMDsc/issues/41).

## [2.5.0] - 2020-06-20

### Changed

- Transferred ownership to DSCCommunity.org - Fixes [Issue #33](https://github.com/dsccommunity/FSRMDsc/issues/33).
- Added .gitattributes file to fix bug publishing examples - Fixes [Issue #23](https://github.com/PlagueHO/FSRMDsc/issues/23).
- Combined all `FSRMDsc.ResourceHelper` module functions into
  `FSRMDsc.Common` module and renamed to `FSRMDsc.CommonHelper`
  module.
- Opted into Common Tests 'Common Tests - Validate Localization' -
  fixes [Issue #82](https://github.com/PowerShell/FSRMDsc/issues/27).
- Minor style fixes to ensure new PSSA rules pass.
- Fix minor style issues in statement case.
- Fix minor style issues in hashtable layout.
- Updated to use the common module _DscResource.Common_ - Fixes [Issue #36](https://github.com/dsccommunity/FSRMDsc/issues/36).
- BREAKING CHANGE: Changed resource prefix from MSFT to DSC.
- Updated to use continuous delivery pattern using Azure DevOps - Fixes
  [Issue #35](https://github.com/dsccommunity/FSRMDsc/issues/35).
- Updated build badges in README.MD.

## [2.4.1] - 2017-12-04

### Changed

- Enabled PSSA rule violations to fail build - Fixes [Issue #12](https://github.com/PlagueHO/FSRMDsc/issues/12).
- Added Open Code of Conduct.
- Added .VSCode settings for applying DSC PSSA rules - fixes [Issue #20](https://github.com/PlagueHO/FSRMDsc/issues/20).
- Refactored module folder structure to move resource
  to root folder of repository and remove test harness - Fixes [Issue #19](https://github.com/PlagueHO/FSRMDsc/issues/19).
- Converted Examples to support format for publishing to PowerShell
  Gallery.
- Opted into common tests:
  - Common Tests - Validate Example Files To Be Published
  - Common Tests - Validate Markdown Links
  - Common Tests - Relative Path Length
  - Common Tests - Relative Path Length
- Update to new format LICENSE.

## [2.4.0] - 2017-12-04

### Changed

- Converted tests to meet Pester V4 standards.
- Added restart to AppVeyor install step so that FSRM components
  are available for testing.
- Clean up unit tests and ensure Verbose is enabled on all.
- Convert AppVeyor build image to Windows Server 2016.
- FSRMFileScreenAction:
  - Fix bug comparing ReportTypes array in Test-TargetResource.
  - Fix blank verbose message in Get-TargetResource.
- FSRMFileScreenTemplateAction:
  - Fix bug comparing ReportTypes array in Test-TargetResource.
  - Fix blank verbose message in Get-TargetResource.
- FSRMQuotaAction:
  - Fix bug comparing ReportTypes array in Test-TargetResource.
  - Fix blank verbose message in Get-TargetResource.
- FSRMQuotaTemplateAction:
  - Fix bug comparing ReportTypes array in Test-TargetResource.
  - Fix blank verbose message in Get-TargetResource.

## [2.3.0] - 2017-09-20

### Changed

- Unit and Integration test headers updated to v1.1.0
- Converted AppVeyor.yml to pull Pester from PSGallery instead of Chocolatey.
- Changed AppVeyor.yml to use default image.
- Converted to HQRM.
- Changed parameter format in Readme.md to meet new standards.
- Moved all localization strings into separate localization files.
- Added CommonResourceHelper.psm1 module from PSDscResources.
- Update parameter format to meet HQRM guidelines.
- DSR_FSRMSettings: Converted to standard single instance pattern.
- Removed Invoke-Expression from integration tests.
- Added standard function help header to all resource functions.
- Added description to all example files.
- Updated all integration tests to use v1.1.1 template format.
- Fix bug with FSRMSettings when parameter being assigned it 0 or blank.

## [2.0.1] - 2015-12-10

### Changed

- Integration tests included for all resources.
- DSR_xFSRMFileScreenAction: Fix to Get-TargetResource.
- DSR_xFSRMQuotaAction: Fix to Get-TargetResource.
- DSR_xFSRMQuotaActionTemplate: Fix to Get-TargetResource.

## [2.0.0] - 2015-06-01

### Changed

- Combined all FSRM Resources into this module.

## [1.0.0] - 2015-01-01

### Changed

- Initial release
