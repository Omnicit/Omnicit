InModuleScope Omnicit {
    Describe 'ConvertFrom-CanonicalName' {

        It '[ConvertFrom-CanonicalName][-CanonicalName "Contoso.com/Department/Users/Roger Johnsson"] Should not throw' {
            { ConvertFrom-CanonicalName -CanonicalName 'Contoso.com/Department/Users/Roger Johnsson' } | Should not throw
        }
        It '([ConvertFrom-CanonicalName][-CanonicalName "Contoso.com/Department/Users/Roger Johnsson"]) -eq "CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com" Should be true' {
            $Verify = (ConvertFrom-CanonicalName -CanonicalName 'Contoso.com/Department/Users/Roger Johnsson').ToString() -eq 'CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com'
            $Verify | Should Be $true
        }
    }
}