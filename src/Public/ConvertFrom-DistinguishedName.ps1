function ConvertFrom-DistinguishedName {
    <#
    .SYNOPSIS
    Convert a DistinguishedName string to a CanonicalName string.

    .DESCRIPTION
    The ConvertFrom-DistinguishedName converts one or more strings in form of a DistinguishedName into CanonicalName strings.
    Common usage when working in Exchange and comparing objects in Active Directory.

    .PARAMETER DistinguishedName
    Specifies the DistinguishedName string to be converted to a CanonicalName string.

    .EXAMPLE
    ConvertFrom-DistinguishedName -DistinguishedName 'CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com'
    Contoso.com/Department/Users/Roger Johnsson

    This example returns the converted DistinguishedName in form of a CanonicalName.

    .EXAMPLE
    ConvertFrom-DistinguishedName -DistinguishedName 'CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com', 'CN=Bill T Admin,OU=Users,OU=Tier1,DC=Contoso,DC=com'
    Contoso.com/Department/Users/Roger Johnsson
    Contoso.com/Tier1/Users/Bill T Admin


    This example returns each DistinguishedName converted in form of a CanonicalName.
    #>
    [OutputType([System.String])]
    [CmdletBinding(
        SupportsShouldProcess
    )]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            HelpMessage = 'Input a valid DistinguishedName. Example: "CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com"'
        )]
        [ValidateNotNullorEmpty()]
        [Alias('DN')]
        [DistinguishedName[]]$DistinguishedName
    )
    process {
        foreach ($Name in $DistinguishedName) {
            if ($PSCmdlet.ShouldProcess(('{0}' -f $Name, $MyInvocation.MyCommand.Name))) {
                $Name.ConvertToCanonicalName()
            }
        }
    }
}