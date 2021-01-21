@{
    # Version number of this module.
    moduleVersion        = '0.0.1'

    # ID used to uniquely identify this module
    GUID                 = '5cda5979-ede4-4b49-9f77-2daa6f80eef2'

    # Author of this module
    Author               = 'DSC Community'

    # Company or vendor of this module
    CompanyName          = 'DSC Community'

    # Copyright statement for this module
    Copyright            = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'DSC Resources for File Server Resource Manager configuration.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '4.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion           = '4.0'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @()

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @()

    # DSC resources to export from this module
    DscResourcesToExport  = @(
        'FSRMSettings'
        'FSRMClassification'
        'FSRMClassificationProperty'
        'FSRMClassificationPropertyValue'
        'FSRMClassificationRule'
        'FSRMFileScreen'
        'FSRMFileScreenAction'
        'FSRMFileScreenTemplate'
        'FSRMFileScreenTemplateAction'
        'FSRMFileScreenException'
        'FSRMFileGroup'
        'FSRMQuota'
        'FSRMQuotaAction'
        'FSRMQuotaTemplate'
        'FSRMQuotaTemplateAction'
        'FSRMAutoQuota'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResource', 'FSRM', 'FileServerResourceManager')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/FSRMDsc/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/FSRMDsc'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = ''
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
