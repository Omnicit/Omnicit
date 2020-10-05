class NormalizeString {
    hidden [Text.Encoding]$Encoding = [Text.Encoding]::GetEncoding('ISO-8859-6')
    hidden [string]$_NormalizedString
    hidden [string]$_String

    NormalizeString() {
        $this | Add-Member -Name String -MemberType ScriptProperty -Value {
            return $this._String
        } -SecondValue {
            param($Value)
            $this._String = $Value
            $this.FormatString()
        }
        $this | Add-Member -Name NormalizedString -MemberType ScriptProperty -Value {
            return $this._NormalizedString
        }
    }
    NormalizeString([string]$Value) {
        $this | Add-Member -Name String -MemberType ScriptProperty -Value {
            return $this._String
        } -SecondValue {
            param($Value)
            $this._String = $Value
            $this.FormatString()
        }
        $this | Add-Member -Name NormalizedString -MemberType ScriptProperty -Value {
            return $this._NormalizedString
        }
        $this.String = $Value
    }
    NormalizeString([string]$Value, [Text.Encoding]$Encoding) {
        $this | Add-Member -Name String -MemberType ScriptProperty -Value {
            return $this._String
        } -SecondValue {
            param($Value)
            $this._String = $Value
            $this.FormatString()
        }
        $this | Add-Member -Name NormalizedString -MemberType ScriptProperty -Value {
            return $this._NormalizedString
        }
        $this.String = $Value
        $this.Encoding = [Text.Encoding]::GetEncoding($Encoding)
    }
    hidden [string]FormatString() {
        try {
            $StringBuilder = [Text.StringBuilder]::new()
            $Bytes = [Text.Encoding]::Convert([Text.Encoding]::Unicode, $this.Encoding, [Text.Encoding]::Unicode.GetBytes($this._String))
            [string]$ConvertedString = $this.Encoding.GetString($Bytes)

            foreach ($Char in $ConvertedString.Normalize([Text.NormalizationForm]::FormD).GetEnumerator()) {
                if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($Char) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
                    $null = $StringBuilder.Append($Char)
                }
            }
            $this._NormalizedString = $StringBuilder.ToString()
            return $this._NormalizedString
        }
        catch {
            Write-Verbose -Message ('Unable to convert string - {0}' -f $_.Exception.Message)
            break
        }
    }
    [string] ToString() {
        return $this.NormalizedString
    }
}