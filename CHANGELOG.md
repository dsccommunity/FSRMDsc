# Versions

## 2.4.0.0

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

## 2.3.0.0

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

## 2.0.1.0

- Integration tests included for all resources.
- DSR_xFSRMFileScreenAction: Fix to Get-TargetResource.
- DSR_xFSRMQuotaAction: Fix to Get-TargetResource.
- DSR_xFSRMQuotaActionTemplate: Fix to Get-TargetResource.

## 2.0.0.0

- Combined all FSRM Resources into this module.

## 1.0.0.0

- Initial release
