data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingSettingsMessage=Getting FSRM Settings "{0}".
SettingSettingsMessage=Setting FSRM Settings "{0}".
SettingsUpdatedMessage=FSRM Settings "{0}" Updated.
TestingSettingsMessage=Testing FSRM Settings "{0}".
SettingsNeedsUpdateMessage=FSRM Settings "{0}" {1} is different. Change required.
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Id
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingSettingsMessage) `
            -f $Id
        ) -join '' )

    $Settings = Get-FSRMSetting

    $returnValue = @{
        Id = $Id
        SmtpServer = $Settings.SmtpServer
        AdminEmailAddress = $Settings.AdminEmailAddress
        FromEmailAddress = $Settings.FromEmailAddress
        CommandNotificationLimit = $Settings.CommandNotificationLimit
        EmailNotificationLimit = $Settings.EmailNotificationLimit
        EventNotificationLimit = $Settings.EventNotificationLimit
    }

    return $returnValue
} # Get-TargetResource

Function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String] $Id,

        [System.String] $SmtpServer,

        [System.String] $AdminEmailAddress,

        [System.String] $FromEmailAddress,

        [System.Uint32] $CommandNotificationLimit,

        [System.Uint32] $EmailNotificationLimit,

        [System.Uint32] $EventNotificationLimit
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingSettingsMessage) `
            -f $Id
        ) -join '' )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Id')

    # Set the existing Settings with a splat
    Set-FSRMSetting @PSBoundParameters

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingsUpdatedMessage) `
            -f $Id
        ) -join '' )

} # Set-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Id,

        [System.String] $SmtpServer,

        [System.String] $AdminEmailAddress,

        [System.String] $FromEmailAddress,

        [System.Uint32] $CommandNotificationLimit,

        [System.Uint32] $EmailNotificationLimit,

        [System.Uint32] $EventNotificationLimit
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingSettingsMessage) `
            -f $Id
        ) -join '' )

    # Lookup the existing Settings
    $Settings = Get-FSRMSetting

    # The Settings exists already - check the parameters
    if (($SmtpServer) -and ($Settings.SmtpServer -ne $SmtpServer))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SettingsNeedsUpdateMessage) `
                -f $Id,'SmtpServer'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($AdminEmailAddress) `
        -and ($Settings.AdminEmailAddress -ne $AdminEmailAddress))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SettingsNeedsUpdateMessage) `
                -f $Id,'AdminEmailAddress'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($FromEmailAddress) `
        -and ($Settings.FromEmailAddress -ne $FromEmailAddress))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SettingsNeedsUpdateMessage) `
                -f $Id,'FromEmailAddress'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($CommandNotificationLimit) `
        -and ($Settings.CommandNotificationLimit -ne $CommandNotificationLimit))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SettingsNeedsUpdateMessage) `
                -f $Id,'CommandNotificationLimit'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($EmailNotificationLimit) `
        -and ($Settings.EmailNotificationLimit -ne $EmailNotificationLimit))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EmailNotificationLimit) `
                -f $Id,'FromEmailAddress'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    if (($EventNotificationLimit) `
        -and ($Settings.EventNotificationLimit -ne $EventNotificationLimit))
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.SettingsNeedsUpdateMessage) `
                -f $Id,'EventNotificationLimit'
            ) -join '' )
        $desiredConfigurationMatch = $false
    }

    return $desiredConfigurationMatch
} # Test-TargetResource

Export-ModuleMember -Function *-TargetResource
