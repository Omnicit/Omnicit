function ConvertFrom-DistinguishedName {
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
    #>
    [OutputType([System.String])]
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Input a valid DistinguishedName. Example: "CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com"'
        )]
        [ValidateNotNullorEmpty()]
        [Alias('DN')]
        [string[]]$DistinguishedName
    )
    process {
        foreach ($Name in $DistinguishedName) {
            if ($PSCmdlet.ShouldProcess(('{0}' -f $Name, $MyInvocation.MyCommand.Name))) {

                #$OU = @()
                # Divide string into an array and replace '\,' with '~'
                $String = $Name.Replace('\,', '~').Split(',')

                foreach ($SubString in $String) {
                    # Remove leading white spaces
                    $SubString = $SubString.TrimStart()

                    # Replace each DistinguishedName indicator with a corresponding leading or trailing char for CanonicalName.
                    switch -Regex ($SubString.SubString(0, 3)) {
                        'CN=' {
                            [string]$CN = '/{0}' -f ($SubString -replace 'CN=')
                            continue
                        }
                        'OU=' {
                            [string[]]$OU += , '{0}/' -f ($SubString -replace 'OU=')
                            continue
                        }
                        'DC=' {
                            $DC += '{0}.' -f ($SubString -replace 'DC=')
                            continue
                        }
                    }
                }

                [string]$Canonical = $DC.TrimEnd('.')
                for ($i = $OU.Count; $i -ge 0; $i --) {
                    [string]$Canonical += $OU[$i]
                }

                if ($CN) {
                    [string]$Canonical += $CN.ToString().Replace('~', ',')
                }
                [string]$Canonical

                # Remove
                Remove-Variable -Name Canonical, CN, OU, DC -ErrorAction SilentlyContinue
            }
        }
    }
}
