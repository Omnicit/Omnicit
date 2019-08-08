---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version: https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertTo-TitleCase.md
schema: 2.0.0
---

# ConvertTo-TitleCase

## SYNOPSIS
The ConvertTo-TitleCase function converts a specified string to title case.

## SYNTAX

```
ConvertTo-TitleCase [-InputObject] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The ConvertTo-TitleCase function converts a specified string to title case using the Method in (Get-Culture).TextInfo
All input strings will be converted to lowercase, because uppercase are considered to be acronyms.

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-TitleCase -InputObject 'roger johnsson'
```

Roger Johnsson

This example returns the string 'Roger Johnsson' which has capitalized the R and J chars.

### EXAMPLE 2
```
'roger johnsson', 'JOHN ROGERSSON' | ConvertTo-TitleCase
```

Roger Johnsson
John Rogersson

This example returns the strings 'Roger Johnsson' and 'John Rogersson' which has capitalized the R and J chars.

## PARAMETERS

### -InputObject
Specifies one or more objects to be convert to title case strings.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertTo-TitleCase.md](https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertTo-TitleCase.md)

