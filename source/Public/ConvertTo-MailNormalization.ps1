function ConvertTo-MailNormalization {
    <#
    .SYNOPSIS
    Convert a string for Mail Normalization.

    .DESCRIPTION
    Converts accented, diacritics and most European chars to the corresponding a-z char.
    Effectively and fast converts a string to a normalized mail string using [Text.NormalizationForm]::FormD and [Text.Encoding]::GetEncoding('ISO-8859-8').
    Function created to support legacy email providers that does not support e-mail address internationalization (EAI).
    Integers will remain intact.

    .EXAMPLE
    ConvertTo-MailNormalization -InputObject 'ûüåäöÅÄÖÆÈÉÊËÐÑØçł'
    uuaaoAAOAEEEEDNOcl

    This example returns a string with the converted Mail Normalization value.

    .NOTES
    Credits to Johan Åkerlund for the Convert-DiacriticCharacters function.

    .LINK
        https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertTo-MailNormalization.md
    #>
    [OutputType([System.String])]
    [CmdletBinding(
        SupportsShouldProcess
    )]
    param (
        # Specifies the string to be converted to Mail Normalization.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            HelpMessage = 'Specify a string to be converted to Unicode Normalization.'
        )]
        [AllowEmptyString()]
        [Alias('String')]
        [string]$InputObject
    )
    process {
        foreach ($String in $InputObject) {
            if ($PSCmdlet.ShouldProcess(('{0}' -f $String, $MyInvocation.MyCommand.Name))) {
                try {
                    [NormalizeString]::new($String).ToString()
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }
}