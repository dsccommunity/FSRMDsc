$autoquota = @{
    Path     = $ENV:Temp
    Ensure   = 'Present'
    Disabled = $false
    Template = (Get-FSRMQuotaTemplate | Select-Object -First 1).Name
}

Configuration MSFT_xFSRMAutoQuota_Config {
    Import-DscResource -ModuleName xFSRM
    node localhost {
       xFSRMAutoQuota Integration_Test {
            Path     = $autoquota.Path
            Ensure   = $autoquota.Ensure
            Disabled = $autoquota.Disabled
            Template = $autoquota.Template
        }
    }
}
