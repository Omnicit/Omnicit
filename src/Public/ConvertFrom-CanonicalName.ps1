function ConvertFrom-CanonicalName {
    <#
    .SYNOPSIS
    Convert a CanonicalName string to a DistinguishedName string.

    .DESCRIPTION
    The ConvertFrom-CanonicalName converts one or more strings in form of a CanonicalName into DistinguishedName strings.
    Common usage when working in Exchange and comparing objects in Active Directory.

    .EXAMPLE
    ConvertFrom-CanonicalName -CanonicalName 'Contoso.com/Department/Users/Roger Johnsson'
    CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com

    This example returns the converted CanonicalName in form of a DistinguishedName.

    .EXAMPLE
    ConvertFrom-CanonicalName -CanonicalName 'Contoso.com/Department/Users' -OrganizationalUnit
    OU=Users,OU=Department,DC=Contoso,DC=com

    This example returns the converted CanonicalName in form of a DistinguishedName. In this case the last object after slash '/' is an OrganizationalUnit.

    .EXAMPLE
    ConvertFrom-CanonicalName -CanonicalName 'Contoso.com/Department/Users/Roger Johnsson', 'Contoso.com/Tier1/Users/Bill T Admin'
    CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com
    CN=Bill T Admin,OU=Users,OU=Tier1,DC=Contoso,DC=com

    This example returns each CanonicalName converted in form of a DistinguishedName.

    .Link
        https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertFrom-CanonicalName.md
    #>
    [OutputType([DistinguishedName])]
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        # Specifies the CanonicalName string to be converted to a DistinguishedName string.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Input a valid CanonicalName. Example: "Contoso.com/Department/Users/Roger Johnsson"'
        )]
        [ValidateNotNullOrEmpty()]
        [CanonicalName[]]$CanonicalName,

        # Specifies that the object is an OrganizationalUnit (OU=) instead of an Person (CN=).
        # Will automatically be an OrganizationalUnit if the CanonicalName string ends with a '/'
        [switch]$OrganizationalUnit
    )
    process {
        foreach ($Name in $CanonicalName) {
            if ($PSCmdlet.ShouldProcess(('{0}' -f $Name, $MyInvocation.MyCommand.Name))) {
                if ($PSBoundParameters.ContainsKey('OrganizationalUnit') -and $Name.CanonicalName -notmatch '\/$') {
                    $Name.OrganizationalUnit = '{0}/{0}' -f $Name.OrganizationalUnit, $Name.FullName
                    $Name.FullName = $null
                }
                [DistinguishedName]$Name.ConvertToDistinguishedName()
            }
        }
    }
}