class NormalizeString {
    [string]$String
    hidden $Encoding = [Text.Encoding]::GetEncoding('ISO-8859-6')


    NormalizeString() {
        $this.FormatString($this.String)
    }
    NormalizeString([string]$InputObject) {
        $this.FormatString($InputObject)
    }
    NormalizeString([string]$InputObject, [Text.Encoding]$Encoding) {
        $this.Encoding = [Text.Encoding]::GetEncoding($Encoding)
        $this.FormatString($InputObject)
    }
    hidden [string]FormatString ([string]$InputObject) {
        try {
            $StringBuilder = [Text.StringBuilder]::new()
            $Bytes = [Text.Encoding]::Convert([Text.Encoding]::Unicode, $this.Encoding, [Text.Encoding]::Unicode.GetBytes($InputObject))
            [string]$ConvertedString = $this.Encoding.GetString($Bytes)

            foreach ($Char in $ConvertedString.Normalize([Text.NormalizationForm]::FormD).GetEnumerator()) {
                if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($Char) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
                    $null = $StringBuilder.Append($Char)
                }
            }
            return $StringBuilder.ToString()
        }
        catch {
            Write-Verbose -Message ('Unable to convert string - {0}' -f $_.Exception.Message)
            break
        }
    }
    [string] ToString() {
        return $this.String
    }
}