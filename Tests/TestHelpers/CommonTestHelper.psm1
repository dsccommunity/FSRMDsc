function Get-InvalidArgumentRecord
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorMessage
    )

    $exception = New-Object -TypeName System.InvalidOperationException `
                            -ArgumentList $ErrorMessage
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                              -ArgumentList $exception, $ErrorId, $errorCategory, $null
    return $errorRecord
}

Export-ModuleMember -Function `
    Get-InvalidArgumentRecord
