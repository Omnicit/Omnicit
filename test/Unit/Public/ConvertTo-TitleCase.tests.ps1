InModuleScope Omnicit {
    Describe 'ConvertTo-TitleCase' {

        It '[ConvertTo-TitleCase][-InputObject "roger johnsson"] Should not throw' {
            { ConvertTo-TitleCase -InputObject 'roger johnsson' } | Should not throw
        }
        It '"roger johnsson", "JOHN ROGERSSON" | [ConvertTo-TitleCase] Should BeExactly "Roger Johnsson","John Rogersson"' {
            $Verify = 'roger johnsson', 'JOHN ROGERSSON' | ConvertTo-TitleCase
            $Verify | Should BeExactly 'Roger Johnsson','John Rogersson'
        }
    }
}