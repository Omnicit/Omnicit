InModuleScope Omnicit {
    Describe 'Get-Parameter' {
        It '[Get-Parameter -CommandName Get-ChildItem] Should not throw' {
            { Get-Parameter -CommandName Get-ChildItem} | Should not throw
        }
        It '([(Get-Parameter -CommandName Get-ChildItem -ParameterName Path).Aliases -eq "Pa*"])' {
            $Verify = (Get-Parameter -CommandName Get-ChildItem -ParameterName Path).Aliases -eq "Pa*"
            $Verify | Should Be $true
        }
    }
}