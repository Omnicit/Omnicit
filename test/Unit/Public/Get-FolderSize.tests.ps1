InModuleScope Omnicit {
    Describe 'Get-FolderSize' {
        if (-not $IsWindows -and $PSVersionTable.PSEdition -eq 'Core') {
            Mock Get-FolderSize -MockWith { 'NoError' }
            It '[Get-FolderSize] Should not throw' {
                { Assert-VerifiableMock } | Should not throw
            }
        }
        else {
            It '[Get-FolderSize] Should not throw' {
                { Get-FolderSize } | Should not throw
            }
            It '([Get-FolderSize]).Path -eq $PWD.Path' {
                $Verify = (Get-FolderSize).'Path' -eq $PWD.Path
                $Verify | Should Be $true
            }
        }
    }
}