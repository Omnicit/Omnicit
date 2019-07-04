---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version: https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertFrom-DistinguishedName.md
schema: 2.0.0
---

# ConvertFrom-DistinguishedName

## SYNOPSIS
Convert a DistinguishedName string to a CanonicalName string.

## SYNTAX

```
ConvertFrom-DistinguishedName [-DistinguishedName] <DistinguishedName[]> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The ConvertFrom-DistinguishedName converts one or more strings in form of a DistinguishedName into CanonicalName strings.
Common usage when working in Exchange and comparing objects in Active Directory.

## EXAMPLES

### EXAMPLE 1
```
ConvertFrom-DistinguishedName -DistinguishedName 'CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com'
```

Contoso.com/Department/Users/Roger Johnsson

This example returns the converted DistinguishedName in form of a CanonicalName.

### EXAMPLE 2
```
ConvertFrom-DistinguishedName -DistinguishedName 'CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com', 'CN=Bill T Admin,OU=Users,OU=Tier1,DC=Contoso,DC=com'
```

Contoso.com/Department/Users/Roger Johnsson
Contoso.com/Tier1/Users/Bill T Admin

This example returns each DistinguishedName converted in form of a CanonicalName.

## PARAMETERS

### -DistinguishedName
Specifies one or more Distinguished Names to be converted to Canonical Names.

```yaml
Type: DistinguishedName[]
Parameter Sets: (All)
Aliases: DN

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

### CanonicalName
## NOTES

## RELATED LINKS

[https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertFrom-DistinguishedName.md](https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertFrom-DistinguishedName.md)

