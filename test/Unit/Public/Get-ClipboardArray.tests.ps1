InModuleScope Omnicit {
    Describe 'Get-ClipboardArray' {
        Mock Get-ClipboardArray {'NoError'}
        It '[Get-ClipboardArray] Should not throw' {
            {Assert-VerifiableMock } | Should not throw
        }
    }
}