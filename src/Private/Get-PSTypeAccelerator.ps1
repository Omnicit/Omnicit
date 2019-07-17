function Get-PSTypeAccelerator {
    [CmdletBinding()]
    param()
    [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
}