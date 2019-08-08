InModuleScope Omnicit {
    Describe 'Compare-ObjectProperty' {

        It '[Compare-ObjectProperty][-ReferenceObject "Something"][-DifferenceObject "Else"] Should not throw' {
            { Compare-ObjectProperty -ReferenceObject 'Something' -DifferenceObject 'Else' } | Should not throw
        }
        It '([Compare-ObjectProperty][-ReferenceObject "Something"][-DifferenceObject "Else"]).PropertyMatch Should be false' {
            $Verify = (Compare-ObjectProperty -ReferenceObject 'Something' -DifferenceObject 'Else').PropertyMatch
            $Verify | Should Be $false
        }
    }
}