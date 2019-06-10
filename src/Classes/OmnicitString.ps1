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
            throw ('Unable to find a valid DistinguishedName')
        }
    }

    [string] ConvertToCanonicalName () {
        [string]$CN = $null
        [string]$DC = $null
        [string]$OU = $null
        [Text.StringBuilder]$Canonical = ''
        $String = ($this.DistinguishedName) -split '(?<!\\),(?!\,)'

        foreach ($SubString in $String) {
            $SubString = $SubString.TrimStart()

            # Replace each DistinguishedName indicator with a corresponding leading or trailing char for CanonicalName.
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

        $Canonical.Append($DC -replace '\.$', '/')
        for ($i = $OU.Count; $i -ge 0; $i --) {
            $Canonical.Append($OU[$i])
        }

        if ($CN) {
            $Canonical.Append($CN)
        }
        return [string]$Canonical
    }
}