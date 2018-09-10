function Format-StringToUnicodeNormalization {
    <#
    .SYNOPSIS
    Format a string for Unicode Normalization using encoding ISO-8859-8.

    .DESCRIPTION
    Effectively and fast converts a string to a normalized Unicode string using 'FormD' to remove diacritics (accents).
    Basicity converts uncommon letters in a string to a it's equivalence letter [a-z] and [A-Z]. Integers will remain intact.
    'ûüåäöÅÄÖÆÈÉÊËÐÑØßçðł' equals 'uuaaoAAOAEEEEDNO?c?l'

    .PARAMETER InputObject
    Specifies the string to be converted to Unicode Normalization.

    .PARAMETER RemoveQuestionMark
    Specifies to remove question mark char caused by unknown conversion.

    .EXAMPLE
    Format-StringToUnicodeNormalization -InputObject 'ûüåäöÅÄÖÆÈÉÊËÐÑØßçðł'
    uuaaoAAOAEEEEDNO?c?l

    This example returns the converted value with Unicode Normalization using encoding ISO-8859-8.

    .EXAMPLE
    Format-StringToUnicodeNormalization -InputObject 'ûüåäöÅÄÖ??ÆÈÉÊ?ËÐÑØßçðł?' -RemoveQuestionMark
    uuaaoAAO??AEEE?EDNO?c?l?

    This example returns the converted value with Unicode Normalization using encoding ISO-8859-8 and removes all questions marks which was a result of chars that were unavailable for conversion.

    .NOTES
    Created by:     Philip Haglund
    Organization:   Omnicit AB
    Filename:       Format-StringToUnicodeNormalization.ps1
    Version:        1.0.0
    Requirements:   Powershell 4.0
    #>
    [OutputType([System.String])]
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        # Specifies the string to be converted to Unicode Normalization.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Specify a string to be converted to Unicode Normalization.'
        )]
        [AllowEmptyString()]
        [string]$InputObject,

        # Specifies to remove question mark char caused by unknown conversion.
        [switch]$RemoveQuestionMark

    )
    begin {
        $Encoding = [Text.Encoding]::GetEncoding('ISO-8859-8')
        $StringBuilder = [Text.StringBuilder]::new()

        if ($PSBoundParameters.ContainsKey('RemoveQuestionMark')) {
            $Id = [guid]::NewGuid()
            $InputObject = $InputObject -replace '\?', $Id.Guid
        }
        try {
            $Bytes = [Text.Encoding]::Convert([Text.Encoding]::Unicode, $Encoding, [Text.Encoding]::Unicode.GetBytes($InputObject))
            $String = $Encoding.GetString($Bytes)
        }
        catch {
            [Exception]$Ex = New-Object -TypeName System.Exception -ArgumentList (' {0} {1}' -f 'Unable to convert byte value to a string. Error: ', $_.Exception.Message)
            [Management.Automation.ErrorCategory]$Category = [Management.Automation.ErrorCategory]::InvalidResult
            [Management.Automation.ErrorRecord]$ErrRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $Ex, 'StringError', $Category, $_.InvocationInfo
            $PSCmdLet.WriteError($ErrRecord)
            break
        }
    }
    process {
        if ($PSCmdlet.ShouldProcess(('{0}' -f $String, $MyInvocation.MyCommand.Name))) {
            try {
                foreach ($Char in $String.Normalize([Text.NormalizationForm]::FormD).GetEnumerator()) {
                    if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($Char) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
                        $null = $StringBuilder.Append($Char)
                    }
                }
                if ($PSBoundParameters.ContainsKey('RemoveQuestionMark')) {
                    $StringBuilder.ToString() -replace '\?', '' -replace $Id.Guid, '?'
                }
                else {
                    $StringBuilder.ToString()
                }
            }
            catch {
                [Exception]$Ex = New-Object -TypeName System.Exception -ArgumentList (' {0} {1}' -f 'Unable to format string to unicode. Error: ', $_.Exception.Message)
                [Management.Automation.ErrorCategory]$Category = [Management.Automation.ErrorCategory]::InvalidResult
                [Management.Automation.ErrorRecord]$ErrRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $Ex, 'StringError', $Category, $_.InvocationInfo
                $PSCmdLet.WriteError($ErrRecord)
                break
            }
        }
    }
}