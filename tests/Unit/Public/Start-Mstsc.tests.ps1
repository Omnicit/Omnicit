InModuleScope Omnicit {
    Describe 'Start-Mstsc' {
        if (-not $IsWindows -and $PSVersionTable.PSEdition -eq 'Core') {
            Mock Start-Mstsc -MockWith { 'NoError' }
            It '[Start-Mstsc][-ComputerName $Env:ComputerName] Should not throw' {
                { Assert-VerifiableMock } | Should not throw
            }
        }
        else {
            It '[Start-Mstsc][-ComputerName $Env:ComputerName] Should not throw' {
                { Start-Mstsc -ComputerName $env:COMPUTERNAME} | Should not throw
            }
        }
    }
}