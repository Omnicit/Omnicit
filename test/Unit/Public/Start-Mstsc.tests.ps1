InModuleScope Omnicit {
    Describe 'Start-Mstsc' {
        Mock Start-Mstsc -MockWith { 'NoError' }
        It '[Start-Mstsc][-ComputerName $Env:ComputerName] Should not throw' {
            { Assert-VerifiableMock } | Should not throw
        }
    }
}