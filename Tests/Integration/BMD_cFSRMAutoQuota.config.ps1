$autoquota = @{
    Path     = $ENV:Temp
    Ensure   = 'Present'
    Disabled = $false
    Template = (Get-FSRMQuotaTemplate | Select-Object -First 1).Name
}

Configuration BMD_cFSRMAutoQuota_Config {
    Import-DscResource -ModuleName cFSRM
    node localhost {
       cFSRMAutoQuota Integration_Test {
            Path     = $autoquota.Path
            Ensure   = $autoquota.Ensure
            Disabled = $autoquota.Disabled
            Template = $autoquota.Template
        }
    }
}
