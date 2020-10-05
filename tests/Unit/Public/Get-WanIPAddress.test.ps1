InModuleScope Omnicit {
    Describe 'Get-WanIPAddress' {

        It '[Get-WanIPAddress] Should not throw' {
            { Get-WanIPAddress } | Should not throw
        }
        It '[Get-WanIPAddress] Should BeOfType [ipaddress]' {
            $Verify = [ipaddress](Get-WanIPAddress).IP_address
            $Verify | Should BeOfType [ipaddress]
        }
    }
}