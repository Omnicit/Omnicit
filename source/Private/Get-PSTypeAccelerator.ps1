function Get-PSTypeAccelerator {
    [CmdletBinding()]
    param()
    try {
        [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}