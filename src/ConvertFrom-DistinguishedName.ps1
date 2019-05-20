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

                # If the DistinguishedName string contains escaped backslashes from Active Directory or misspelled backslashes this will be taken care of.
                $Esc = $Name.ToCharArray()
                $String = for ($c = 0; $c -lt $Esc.Count; $c ++) {
                    switch ($Esc[$c]) {
                        { $Esc[$c] -eq $s -and $Esc[$c + 1] -eq $s -and $Esc[$c - 1] -eq $s -and $Esc[$c + 2] -ne $s -and $Esc[$c - 2] -ne $s } { $Esc[$c] + '\'; continue }
                        { $Esc[$c] -eq $s -and $Esc[$c + 1] -ne $s -and $Esc[$c - 1] -ne $s } { $Esc[$c] + '\'; continue }
                        Default { $Esc[$c] }
                    }
                }
                $String = ($String -join '').Split(',')

                foreach ($SubString in $String) {
                    $SubString = $SubString.TrimStart()

                    # Replace each DistinguishedName indicator with a corresponding leading or trailing char for CanonicalName.
                    Write-Verbose -Message $SubString.SubString(0, 3)
                    switch ($SubString.SubString(0, 3)) {
                        'CN=' {
                            [string]$CN = '{0}' -f ($SubString -replace 'CN=')
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

                [string]$Canonical = $DC -replace '\.$', '/'
                for ($i = $OU.Count; $i -ge 0; $i --) {
                    [string]$Canonical += $OU[$i]
                }

                if ($CN) {
                    [string]$Canonical += $CN
                }
                [string]$Canonical

                # Remove variables for loop processing
                Remove-Variable -Name Canonical, CN, OU, DC -ErrorAction SilentlyContinue
            }
        }
    }
}