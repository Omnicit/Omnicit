InModuleScope Omnicit {
    Describe 'ConvertTo-MailNormalization' {

        It '[ConvertTo-MailNormalization][-InputObject "ûüåäöÅÄÖÆÈÉÊËÐÑØçł"] Should not throw' {
            { ConvertTo-MailNormalization -InputObject 'ûüåäöÅÄÖÆÈÉÊËÐÑØçł' } | Should not throw
        }
        It '([ConvertTo-MailNormalization][-InputObject "ûüåäöÅÄÖÆÈÉÊËÐÑØçł"]) -eq "uuaaoAAOAEEEEDNOcl" Should be true' {
            $Verify = (ConvertTo-MailNormalization -InputObject 'ûüåäöÅÄÖÆÈÉÊËÐÑØçł') -eq 'uuaaoAAOAEEEEDNOcl'
            $Verify | Should Be $true
        }
    }
}