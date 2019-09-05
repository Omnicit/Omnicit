InModuleScope Omnicit {
    Describe 'Get-FolderSize' {

        It '[Get-FolderSize] Should not throw' {
            { Get-FolderSize } | Should not throw
        }
        It '([Get-FolderSize]).Path -eq $PWD.Path' {
            $Verify = (Get-FolderSize).'Path' -eq $PWD.Path
            $Verify | Should Be $true
        }
    }
}