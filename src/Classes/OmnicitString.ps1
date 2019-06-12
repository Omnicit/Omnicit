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
            #Write-Error -Message 'Unable to find a valid DistinguishedName' -Category InvalidData -Exception [System.InvalidCastException] -ErrorAction Stop
            #[Exception]$Exception = [Exception]::new('Unable to find a valid DistinguishedName')
            #$Exception = [System.InvalidCastException]::new('Unable to find a valid DistinguishedName')
            #[Management.Automation.ErrorCategory]$Category = [Management.Automation.ErrorCategory]::InvalidType
            #[Management.Automation.ErrorRecord]$ErrRecord = [Management.Automation.ErrorRecord]::new($Exception, 1, $Category, $null)
            #$PSCmdLet.ThrowTerminatingError($ErrRecord)
            $badObject = 'whatever object caused the issue'
            $actualException = [System.NotSupportedException]::new('I take exception to your use of this function')
            $errorRecord = [System.Management.Automation.ErrorRecord]::new($actualException, 'ExampleException1', [System.Management.Automation.ErrorCategory]::InvalidData, $badObject)
            $PSCmdlet.ThrowTerminatingError($errorRecord)
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