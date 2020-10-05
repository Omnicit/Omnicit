InModuleScope Omnicit {
    Describe 'Invoke-ModuleUpdate' {

        It '[Invoke-ModuleUpdate][-Name "Pester"] Should not throw' {
            { Invoke-ModuleUpdate -Name 'Pester' } | Should not throw
        }
        It '(([Invoke-ModuleUpdate][-Name "Pester"])."Current Version" -gt [version]4.8.0 Should be true' {
            $Verify = (Invoke-ModuleUpdate -Name Pester).'Current Version' -gt [version]4.8.0
            $Verify | Should Be $true
        }
    }
}