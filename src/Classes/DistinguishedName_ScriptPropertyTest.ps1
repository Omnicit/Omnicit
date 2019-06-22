class CommonName {
    [ValidatePattern('^CN=[a-z1-9]')]
    [ValidateLength(4, 67)]
    [string]$Value

    CommonName([string]$CommonName) {
        $this.Value = $CommonName
    }

    [string]ToString() {
        return $this.Value
    }
}

class OrganizationalUnit {
    [ValidatePattern('^(?:((?:(?:OU)=[^,]+,?)+))')]
    [ValidateLength(4, 67)]
    [string]$Value

    OrganizationalUnit([string]$OrganizationalUnit) {
        $this.Value = $OrganizationalUnit
    }
    [string]ToString() {
        return $this.Value
    }
}

class Domain {
    [ValidatePattern('^((?:DC=[^,]+,?)+)')]
    [ValidateLength(4, 67)]
    [string]$Value

    Domain([string]$Domain) {
        $this.Value = $Domain
    }
    [string]ToString() {
        return $this.Value
    }
}


class Test {
    hidden [string]$_FullName
    hidden [string]$_CommonName
    hidden [string]$_OrganizationalUnit
    hidden [string]$_Domain
    [string]$DistinguishedName

    Test() {
        $this | Add-Member -Name FullName -MemberType ScriptProperty -Value {
            return [string]$this._FullName
        } -SecondValue {
            param($Value)
            $this._FullName = $Value
            $this._CommonName = 'CN={0}' -f $Value
            try {
                $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
            }
            catch {
                Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
            }
        }
        $this | Add-Member -Name CommonName -MemberType ScriptProperty -Value {
            return [string]$this._CommonName
        } -SecondValue {
            param([CommonName]$Value)
            $this._FullName = ($Value -replace '^CN=')
            $this._CommonName = $Value
            try {
                $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
            }
            catch {
                Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
            }
        }
        $this | Add-Member -Name OrganizationalUnit -MemberType ScriptProperty -Value {
            return [string]$this._OrganizationalUnit
        } -SecondValue {
            param([OrganizationalUnit]$Value)
            $this._OrganizationalUnit = $Value
            try {
                $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
            }
            catch {
                Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
            }
        }
        $this | Add-Member -Name Domain -MemberType ScriptProperty -Value {
            return [string]$this._Domain
        } -SecondValue {
            param([Domain]$Value)
            $this._Domain = $Value
            try {
                $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
            }
            catch {
                Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
            }
        }
    }

    Test([string]$DistinguishedName) {
        if ($DistinguishedName -match '^(?:(?<CN>CN=(?<Name>[^,]*)),)?(?:(?<OU>(?:(?:OU)=[^,]+,?)+),)?(?<Domain>(?:DC=[^,]+,?)+)$') {
            $this._FullName = $Matches['Name']
            $this._CommonName = 'CN={0}' -f $Matches['Name']
            $this._OrganizationalUnit = if ($Matches['OU']) { $Matches['OU'] }
            $this._Domain = $Matches['Domain']
            $this.DistinguishedName = $Matches[0]

            $this | Add-Member -Name FullName -MemberType ScriptProperty -Value {
                return $this._FullName
            } -SecondValue {
                param($Value)
                $this._FullName = $Value
                $this._CommonName = 'CN={0}' -f $Value
                try {
                    $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
                }
                catch {
                    Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
                }
            }
            $this | Add-Member -Name CommonName -MemberType ScriptProperty -Value {
                return [string]$this._CommonName
            } -SecondValue {
                param([CommonName]$Value)
                $this._FullName = ($Value -replace '^CN=')
                $this._CommonName = $Value
                try {
                    $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
                }
                catch {
                    Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
                }
            }
            $this | Add-Member -Name OrganizationalUnit -MemberType ScriptProperty -Value {
                return $this._OrganizationalUnit
            } -SecondValue {
                param([OrganizationalUnit]$Value)
                $this._OrganizationalUnit = $Value
                try {
                    $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
                }
                catch {
                    Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
                }
            }
            $this | Add-Member -Name Domain -MemberType ScriptProperty -Value {
                return $this._Domain
            } -SecondValue {
                param([Domain]$Value)
                $this._Domain = $Value
                try {
                    $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
                }
                catch {
                    Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build the DistinguishedName string'
                }
            }
        }
    }
    Test([string]$CommonName, [string]$OrganizationalUnit, [string]$Domain) {
        try {
            $this.BuildDistinguishedName($CommonName, $OrganizationalUnit, $Domain)
        }
        catch {
            Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build the DistinguishedName string'
            break
        }
        $this._CommonName = $CommonName
        $this._FullName = ($CommonName -replace '^CN=')
        $this._OrganizationalUnit = $OrganizationalUnit
        $this._Domain = $Domain

        $this | Add-Member -Name FullName -MemberType ScriptProperty -Value {
            return [string]$this._FullName
        } -SecondValue {
            param($Value)
            $this._FullName = $Value
            $this._CommonName = 'CN={0}' -f $Value
            try {
                $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
            }
            catch {
                Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
            }
        }
        $this | Add-Member -Name CommonName -MemberType ScriptProperty -Value {
            return [string]$this._CommonName
        } -SecondValue {
            param([CommonName]$Value)
            $this._FullName = ($Value -replace '^CN=')
            $this._CommonName = $Value
            try {
                $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
            }
            catch {
                Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
            }
        }
        $this | Add-Member -Name OrganizationalUnit -MemberType ScriptProperty -Value {
            return [string]$this._OrganizationalUnit
        } -SecondValue {
            param([OrganizationalUnit]$Value)
            $this._OrganizationalUnit = $Value
            try {
                $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
            }
            catch {
                Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
            }
        }
        $this | Add-Member -Name Domain -MemberType ScriptProperty -Value {
            return [string]$this._Domain
        } -SecondValue {
            param([Domain]$Value)
            $this._Domain = $Value
            try {
                $this.BuildDistinguishedName($this._CommonName, $this._OrganizationalUnit, $this._Domain)
            }
            catch {
                Write-Verbose -Message 'Uncompleted CommonName, OrganizationalUnit or Domain to finish build DistinguishedName'
            }
        }
    }
    hidden [void]BuildDistinguishedName([CommonName]$CN, [OrganizationalUnit]$OU, [Domain]$DN) {
        $this.DistinguishedName = '{0},{1},{2}' -f $CN.ToString(), $OU.ToString(), $DN.ToString()
    }

    [string]ToString() {
        return $this.DistinguishedName
    }
}