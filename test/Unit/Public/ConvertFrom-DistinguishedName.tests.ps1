InModuleScope Omnicit {
    Describe 'ConvertFrom-DistinguishedName' {

        It '[ConvertFrom-DistinguishedName][-DistinguishedName "CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com"] Should not throw' {
            { ConvertFrom-DistinguishedName -DistinguishedName 'CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com' } | Should not throw
        }
        It '([ConvertFrom-DistinguishedName][-DistinguishedName "CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com"]) -eq "Contoso.com/Department/Users/Roger Johnsson" Should be true' {
            $Verify = (ConvertFrom-DistinguishedName -DistinguishedName 'CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com').ToString() -eq 'Contoso.com/Department/Users/Roger Johnsson'
            $Verify | Should Be $true
        }
    }
}