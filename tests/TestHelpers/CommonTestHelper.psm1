function Get-InvalidArgumentRecord
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Message,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ArgumentName
    )

    $argumentException = New-Object `
        -TypeName 'ArgumentException' `
        -ArgumentList @( $Message,$ArgumentName )
    $newObjectParams = @{
        TypeName = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @( $argumentException, $ArgumentName, 'InvalidArgument', $null )
    }
    return New-Object @newObjectParams
}

<#
.SYNOPSIS
    Tests the FSRM environment is ready for integration testing.

.DESCRIPTION
    The Test-FsrmEnvironment function checks various aspects of the FSRM environment
    to ensure it is ready for integration testing.

.PARAMETER
    This function does not take any parameters.

.OUTPUTS
    System.Boolean. Returns true if the FSRM environment is ready for integration testing.

.NOTES
    This function is used for diagnosing FRSM testing issues and not recommended for running as part
    of the continuous integration pipeline.
#>
function Test-FsrmEnvironmentForIntegrationTest
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    Write-Verbose -Message 'Checking FileServerResourceManager module is available.'
    $fsrmModule = Get-Module -Name 'FileServerResourceManager' -ListAvailable

    if (-not $fsrmModule)
    {
        Write-Warning -Message 'FileServerResourceManager module not found. Please install the FileServerResourceManager module.'
        return $false
    }

    Write-Verbose -Message 'Importing FileServerResourceManager module.'
    Import-Module -Name 'FileServerResourceManager'

    Write-Verbose -Message 'Checking FS-Resource-Manager feature is installed.'
    $fsrmFeature = Get-WindowsFeature -Name 'FS-Resource-Manager'

    if (-not $fsrmFeature)
    {
        Write-Warning -Message 'FS-Resource-Manager feature not found. Please install the FS-Resource-Manager feature.'
        return $false
    }

    #
    Write-Verbose -Message 'Stopping "File Server Storage Reports Manager" service.'
    Stop-Service -Name 'SrmReports'
    Write-Verbose -Message 'Stopping "File Server Resource Manager" service.'
    Stop-Service -Name 'SrmSvc'
    Write-Verbose -Message 'Starting "File Server Storage Reports Manager" service.'
    Start-Service -Name 'SrmSvc'
    Write-Verbose -Message 'Starting "File Server Resource Manager" service.'
    Start-Service -Name 'SrmReports'

    $fsrmService = Get-Service -Name 'SrmSvc'

    if ($fsrmService.Status -ne 'Running')
    {
        Write-Warning -Message 'FSRM Service is not running. Please start the FSRM Service.'
        return $false
    }

    Write-Verbose -Message 'Getting FSRM settings.'
    $fsrmSettings = Get-FsrmSetting

    if (-not $fsrmSettings)
    {
        Write-Warning -Message 'FSRM settings could not be retrieved.'
        return $false
    }

    return $true
}

Export-ModuleMember -Function Get-InvalidArgumentRecord, Test-FsrmEnvironment
