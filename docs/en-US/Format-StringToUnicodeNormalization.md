---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version:
schema: 2.0.0
---

# Format-StringToUnicodeNormalization

## SYNOPSIS
Format a string for Unicode Normalization using encoding ISO-8859-8.

## SYNTAX

```
Format-StringToUnicodeNormalization [-InputObject] <String> [-RemoveQuestionMark] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Effectively and fast converts a string to a normalized Unicode string using 'FormD' to remove diacritics (accents).
Basicity converts uncommon letters in a string to a it's equivalence letter \[a-z\] and \[A-Z\].
Integers will remain intact.
'ûüåäöÅÄÖÆÈÉÊËÐÑØßçðł' equals 'uuaaoAAOAEEEEDNO?c?l'

## EXAMPLES

### EXAMPLE 1
```
Format-StringToUnicodeNormalization -InputObject 'ûüåäöÅÄÖÆÈÉÊËÐÑØßçðł'
```

uuaaoAAOAEEEEDNO?c?l

This example returns the converted value with Unicode Normalization using encoding ISO-8859-8.

### EXAMPLE 2
```
Format-StringToUnicodeNormalization -InputObject 'ûüåäöÅÄÖ??ÆÈÉÊ?ËÐÑØßçðł?' -RemoveQuestionMark
```

uuaaoAAO??AEEE?EDNO?c?l?

This example returns the converted value with Unicode Normalization using encoding ISO-8859-8 and removes all questions marks which was a result of chars that were unavailable for conversion.

## PARAMETERS

### -InputObject
Specifies the string to be converted to Unicode Normalization.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -RemoveQuestionMark
Specifies to remove question mark char caused by unknown conversion.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
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

### System.String
## NOTES

## RELATED LINKS
