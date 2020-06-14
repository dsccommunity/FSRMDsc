Configuration DSC_FSRMAutoQuota_Config {
    Import-DscResource -ModuleName FSRMDsc

    node localhost {
       FSRMAutoQuota Integration_Test {
            Path     = $Node.Path
            Ensure   = $Node.Ensure
            Disabled = $Node.Disabled
            Template = $Node.Template
        }
    }
}
