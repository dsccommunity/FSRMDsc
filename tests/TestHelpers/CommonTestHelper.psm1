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
    The Test-FsrmEnvironment function checks if the 'FileServerResourceManager' module
    and 'FS-Resource-Manager' feature are installed on the system.

.PARAMETER
    This function does not take any parameters.

.EXAMPLE
    Test-FsrmEnvironment

    This command checks if the 'FileServerResourceManager' module and 'FS-Resource-Manager' feature are installed on the system.

.OUTPUTS
    System.Boolean. Returns true if both the module and feature are installed, otherwise returns false.

.NOTES
    If the module or feature are not found, a warning message will be displayed advising to install them.
#>
function Test-FsrmEnvironment
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
