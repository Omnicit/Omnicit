---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version: https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertTo-MailNormalization.md
schema: 2.0.0
---

# ConvertTo-MailNormalization

## SYNOPSIS
Convert a string for Mail Normalization.

## SYNTAX

```
ConvertTo-MailNormalization [-InputObject] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Converts accented, diacritics and most European chars to the corresponding a-z char.
Effectively and fast converts a string to a normalized mail string using \[Text.NormalizationForm\]::FormD and \[Text.Encoding\]::GetEncoding('ISO-8859-8').
Function created to support legacy email providers that does not support e-mail address internationalization (EAI).
Integers will remain intact.

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-MailNormalization -InputObject 'ûüåäöÅÄÖÆÈÉÊËÐÑØçł'
```

uuaaoAAOAEEEEDNOcl

This example returns a string with the converted Mail Normalization value.

## PARAMETERS

### -InputObject
Specifies the string to be converted to Mail Normalization.

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

[https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertTo-MailNormalization.md](https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertTo-MailNormalization.md)

