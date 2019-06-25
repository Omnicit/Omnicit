class CanonicalName {
    hidden [string]$_FullName
    hidden [string]$_OrganizationalUnit
    hidden [string]$_Domain
    [string]$CanonicalName

    CanonicalName() {
        $this | Add-Member -Name FullName -MemberType ScriptProperty -Value {
            return $this._FullName
        } -SecondValue {
            param($Value)
            $this._FullName = $Value
            try {
                $this.BuildCanonicalName($this._Domain, $this._OrganizationalUnit, $this._FullName)
            }
            catch {
                Write-Verbose -Message 'Uncompleted FullName, OrganizationalUnit or Domain to finish build CanonicalName'
            }
        }
        $this | Add-Member -Name OrganizationalUnit -MemberType ScriptProperty -Value {
            return $this._OrganizationalUnit
        } -SecondValue {
            param($Value)
            $this._OrganizationalUnit = $Value
            try {
                $this.BuildCanonicalName($this._Domain, $this._OrganizationalUnit, $this._FullName)
            }
            catch {
                Write-Verbose -Message 'Uncompleted FullName, OrganizationalUnit or Domain to finish build CanonicalName'
            }
        }
        $this | Add-Member -Name Domain -MemberType ScriptProperty -Value {
            return $this._Domain
        } -SecondValue {
            param($Value)
            $this._Domain = $Value
            try {
                $this.BuildCanonicalName($this._Domain, $this._OrganizationalUnit, $this._FullName)
            }
            catch {
                Write-Verbose -Message 'Uncompleted FullName, OrganizationalUnit or Domain to finish build CanonicalName'
            }
        }
    }
    CanonicalName($CanonicalName) {
        if ($CanonicalName -match '^(?:(?!\/))(?:(?<Domain>[^\/]+)\/)?(?:(?<Path>.+(?=\/)+)\/)?(?:(?<Name>.+))?$') {
            $this._FullName = if ($Matches['Domain'] -eq [string]::Empty) { $null } else { $Matches['Name'] }
            $this._OrganizationalUnit = if ($Matches['Path']) { $Matches['Path'] }
            $this._Domain = if ($Matches['Domain']) { $Matches['Domain'] } else { $Matches['Name'] }
            $this.CanonicalName = $Matches[0]

            $this | Add-Member -Name FullName -MemberType ScriptProperty -Value {
                return $this._FullName
            } -SecondValue {
                param($Value)
                $this._FullName = $Value
                try {
                    $this.BuildCanonicalName($this._Domain, $this._OrganizationalUnit, $this._FullName)
                }
                catch {
                    Write-Verbose -Message 'Uncompleted FullName, OrganizationalUnit or Domain to finish build CanonicalName'
                }
            }
            $this | Add-Member -Name OrganizationalUnit -MemberType ScriptProperty -Value {
                return $this._OrganizationalUnit
            } -SecondValue {
                param($Value)
                $this._OrganizationalUnit = $Value
                try {
                    $this.BuildCanonicalName($this._Domain, $this._OrganizationalUnit, $this._FullName)
                }
                catch {
                    Write-Verbose -Message 'Uncompleted FullName, OrganizationalUnit or Domain to finish build CanonicalName'
                }
            }
            $this | Add-Member -Name Domain -MemberType ScriptProperty -Value {
                return $this._Domain
            } -SecondValue {
                param($Value)
                $this._Domain = $Value
                try {
                    $this.BuildCanonicalName($this._Domain, $this._OrganizationalUnit, $this._FullName)
                }
                catch {
                    Write-Verbose -Message 'Uncompleted FullName, OrganizationalUnit or Domain to finish build CanonicalName'
                }
            }
        }
        else {
            Write-Verbose -Message 'String does not contain a valid CanonicalName.'
            break
        }
    }

    hidden [void]BuildCanonicalName([string]$CN, [string]$OU, [string]$DN) {
        [string]$Slash = '/'
        if ($OU -eq [string]::Empty) {
            $Slash = $null
        }
        $this.CanonicalName = '{0}/{1}{2}{3}' -f $CN, $OU, $Slash, $DN
    }

    [string] ConvertToDistinguishedName () {
        if ($null -eq $this.CanonicalName) {
            Write-Verbose -Message 'No CanonicalName was defined.'
            break
        }
        [Text.StringBuilder]$DistinguishedName = [Text.StringBuilder]::new()
        [string[]]$String = $this.CanonicalName.Split('/')

        if ($this._FullName -ne [string]::Empty) {
            $null = $DistinguishedName.Append('CN={0}' -f ($String[$String.Count - 1]))
        }

        for ($i = $String.Count - 2; $i -ge 1; $i--) {
            $null = $DistinguishedName.Append(',OU={0}' -f ($String[$i]))
        }

        foreach ($Top in ($String[0].Split('.'))) {
            $null = $DistinguishedName.Append(',DC={0}' -f ($Top))
        }

        return $DistinguishedName.ToString().Trim(',')
    }
    [string]ToString() {
        return $this.CanonicalName
    }
}