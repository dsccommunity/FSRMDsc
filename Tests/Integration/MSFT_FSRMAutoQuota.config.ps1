$autoquota = @{
    Path     = $ENV:Temp
    Ensure   = 'Present'
    Disabled = $false
    Template = (Get-FSRMQuotaTemplate | Select-Object -First 1).Name
}

Configuration MSFT_FSRMAutoQuota_Config {
    Import-DscResource -ModuleName FSRMDsc
    node localhost {
       FSRMAutoQuota Integration_Test {
            Path     = $autoquota.Path
            Ensure   = $autoquota.Ensure
            Disabled = $autoquota.Disabled
            Template = $autoquota.Template
        }
    }
}
