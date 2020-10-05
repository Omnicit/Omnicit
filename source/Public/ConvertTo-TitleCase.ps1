function ConvertTo-TitleCase {
    <#
    .SYNOPSIS
    The ConvertTo-TitleCase function converts a specified string to title case.

    .DESCRIPTION
    The ConvertTo-TitleCase function converts a specified string to title case using the Method in (Get-Culture).TextInfo
    All input strings will be converted to lowercase, because uppercase are considered to be acronyms.

    .EXAMPLE
    ConvertTo-TitleCase -InputObject 'roger johnsson'
    Roger Johnsson

    This example returns the string 'Roger Johnsson' which has capitalized the R and J chars.

    .EXAMPLE
    'roger johnsson', 'JOHN ROGERSSON' | ConvertTo-TitleCase
    Roger Johnsson
    John Rogersson

    This example returns the strings 'Roger Johnsson' and 'John Rogersson' which has capitalized the R and J chars.

    .LINK
        https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertTo-TitleCase.md
    #>
    [Alias('ConvertTo-NameTitle')]
    [CmdletBinding(
        PositionalBinding,
        SupportsShouldProcess
    )]
    param (
        # Specifies one or more objects to be convert to title case strings.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            Position = 0
        )]
        [AllowEmptyString()]
        [string[]]$InputObject
    )
    begin {
        $TextInfo = (Get-Culture).TextInfo
    }
    process {
        foreach ($String in $InputObject) {
            if ($PSCmdlet.ShouldProcess($String)) {
                    $TextInfo.ToTitleCase($String.ToLower())
                }
            }
        }
    }
