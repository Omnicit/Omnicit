function ConvertTo-MailNormalization {
    <#
    .SYNOPSIS
    Convert a string for Mail Normalization.

    .DESCRIPTION
    Converts accented, diacritics and most European chars to the corresponding a-z char.
    Effectively and fast converts a string to a normalized mail string using [Text.NormalizationForm]::FormD and [Text.Encoding]::GetEncoding('ISO-8859-8')
    Integers will remain intact.

    .EXAMPLE
    ConvertTo-MailNormalization -InputObject 'ûüåäöÅÄÖÆÈÉÊËÐÑØßçðł'
    uuaaoAAOAEEEEDNO?c?l

    This example returns a string with the converted Mail Normalization value.

    .EXAMPLE
    ConvertTo-MailNormalization -InputObject 'ûüåäöÅÄÖ??ÆÈÉÊ?ËÐÑØßçðł?' -RemoveQuestionMark
    uuaaoAAO??AEEE?EDNO?c?l?

    This example returns a string with the converted Mail Normalization value and removes all questions marks which was a result of chars that were unavailable for conversion.

    .LINK
        https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertTo-MailNormalization.md
    #>
    [OutputType([System.String])]
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        # Specifies the string to be converted to Mail Normalization.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'Specify a string to be converted to Unicode Normalization.'
        )]
        [AllowEmptyString()]
        [string]$InputObject,

        # This example returns a string with the converted Mail Normalization value.
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
            $PSCmdlet.ThrowTerminatingError($_)
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
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
}