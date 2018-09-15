function ConvertFrom-CanonicalName {
    <#
    .SYNOPSIS
    Convert a CanonicalName string to a DistinguishedName string.

    .DESCRIPTION
    The ConvertFrom-CanonicalName converts one or more strings in form of a CanonicalName into DistinguishedName strings.
    Common usage when working in Exchange and comparing objects in Active Directory.

    .PARAMETER CanonicalName
    Specifies the CanonicalName string to be converted to a DistinguishedName string.

    .PARAMETER OrganizationalUnit
    Specifies that the object is an OrganizationalUnit (OU=) instead of an Person (CN=).

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

    .NOTES
    Created by:     Philip Haglund
    Organization:   Omnicit AB
    Filename:       ConvertFrom-CanonicalName.ps1
    Version:        1.0.0
    Requirements:   Powershell 4.0
    #>
    [OutputType([System.String])]
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
        [ValidateNotNullorEmpty()]
        [string[]]$CanonicalName,

        #Specifies that the object is an OrganizationalUnit (OU=) instead of an Person (CN=).
        [switch]$OrganizationalUnit
    )
    process {
        foreach ($Name in $CanonicalName) {
            if ($PSCmdlet.ShouldProcess(('{0}' -f $Name, $MyInvocation.MyCommand.Name))) {
                # Remove trailing or leading slashes.
                if ($Name -match '\/$' -or $Name -match '^\/') {
                    [string]$Name = $Name.Trim('/')
                }

                # CanonicalName is only the part of a domain.
                if ($Name -notmatch '\/') {
                    [bool]$Domain = $true
                }
                # Divide string into an array and replace
                $String = $Name.Split('/')

                # Create the first part of the string.
                if ($PSBoundParameters.ContainsKey('OrganizationalUnit')) {
                    [string]$DistinguishedName = ('OU={0}' -f ($String[$String.Count - 1]))
                }
                elseif ($Domain) {
                    [string]$DistinguishedName = ''
                }
                else {
                    [string]$DistinguishedName = ('CN={0}' -f ($String[$String.Count - 1]))
                }

                # Build string based on the array $String
                for ($i = $String.Count - 2; $i -ge 1; $i--) {
                    [string]$DistinguishedName += (',OU={0}' -f ($String[$i]))
                }

                # Add domain (DC=) to the DistinguishedName String.
                foreach ($Top in ($String[0].Split('.'))) {
                    [string]$DistinguishedName += (',DC={0}' -f ($Top))
                }

                # Remove leading and trailing commas.
                if ($Domain) {
                    [string]$DistinguishedName = $DistinguishedName.Trim(',')
                }

                [string]$DistinguishedName
            }
        }
    }
}