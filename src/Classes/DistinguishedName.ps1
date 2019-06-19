class DistinguishedName {
    [string]$FullName
    [string]$CommonName
    [string]$OrganizationalUnit
    [string]$Domain
    [string]$DistinguishedName

    DistinguishedName($DistinguishedName) {
        if ($DistinguishedName -match '^(?:(?<CN>CN=(?<Name>[^,]*)),)?(?:(?<OU>(?:(?:OU)=[^,]+,?)+),)?(?<Domain>(?:DC=[^,]+,?)+)$') {
            $this.DistinguishedName = $Matches[0]
            $this.FullName = $Matches['Name']
            $this.CommonName = $Matches['CN']
            $this.OrganizationalUnit = if ($Matches['OU']) { $Matches['OU'] }
            $this.Domain = $Matches['Domain']
        }
    }

    [string] ConvertToCanonicalName () {
        [string]$CN = $null
        [Text.StringBuilder]$DC = ''
        [Object]$OU = [System.Collections.Generic.List[String]]::new()
        [Text.StringBuilder]$Canonical = ''
        [string[]]$String = ($this.DistinguishedName) -split '(?<!\\),(?!\,)'
        foreach ($SubString in $String) {
            $SubString = $SubString.TrimStart()

            # Replace each DistinguishedName indicator with a corresponding leading or trailing char for CanonicalName.
            switch ($SubString.SubString(0, 3)) {
                'CN=' {
                    [string]$CN = '{0}' -f ($SubString -replace 'CN=')
                    continue
                }
                'OU=' {
                    [Object]$OU.Add('{0}/' -f ($SubString -replace 'OU='))
                    continue
                }
                'DC=' {
                    $DC.Append('{0}.' -f ($SubString -replace 'DC='))
                    continue
                }
            }
        }

        [System.Array]::Reverse($OU)
        [Text.StringBuilder]$Canonical.Append([string]($DC -replace '\.$', '/'))
        [Text.StringBuilder]$Canonical.Append(-join $OU)
        [Text.StringBuilder]$Canonical.Append($CN)

        return $Canonical.ToString().TrimEnd('/')
    }
}