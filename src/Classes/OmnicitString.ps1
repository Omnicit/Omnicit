class OmnicitString {
    hidden [string]$String

    OmnicitString() {
        $this.String.OmnicitString
    }
    OmnicitString($String) {
        $this.String.OmnicitString = $String
    }

    [string]ToString () {
        return $this.String
    }
}

class DistinguishedName : OmnicitString {
    [string]$CommonName
    [string]$OrganizationalUnit
    [string]$Domain
    [string]$DistinguishedName
    hidden [string]$CNCommonName

    DistinguishedName($DistinguishedName) {
        if ($DistinguishedName -match '^(?:(?<CN>CN=(?<Name>[^,]*)),)?(?:(?<OU>(?:(?:CN|OU)=[^,]+,?)+),)?(?<Domain>(?:DC=[^,]+,?)+)$') {
            $this.DistinguishedName = $Matches[0]
            $this.CommonName = $Matches['Name']
            $this.CNCommonName = $Matches['CN']
            $this.OrganizationalUnit = $Matches['OU']
            $this.Domain = $Matches['Domain']
        }
        else {
            Throw ('Unable to find a valid DistinguishedName')
        }
    }

    static ConvertToCanonicalName ([string]$DN) {
        $CN = $null
        $DC = $null
        $OU = $null
        $String = ($DN).Split(',')

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
    }
}