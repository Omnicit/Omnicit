---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version: https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertFrom-CanonicalName.md
schema: 2.0.0
---

# ConvertFrom-CanonicalName

## SYNOPSIS
Convert a CanonicalName string to a DistinguishedName string.

## SYNTAX

```
ConvertFrom-CanonicalName [-CanonicalName] <CanonicalName[]> [-OrganizationalUnit] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The ConvertFrom-CanonicalName converts one or more strings in form of a CanonicalName into DistinguishedName strings.
Common usage when working in Exchange and comparing objects in Active Directory.

## EXAMPLES

### EXAMPLE 1
```
ConvertFrom-CanonicalName -CanonicalName 'Contoso.com/Department/Users/Roger Johnsson'
```

CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com

This example returns the converted CanonicalName in form of a DistinguishedName.

### EXAMPLE 2
```
ConvertFrom-CanonicalName -CanonicalName 'Contoso.com/Department/Users' -OrganizationalUnit
```

OU=Users,OU=Department,DC=Contoso,DC=com

This example returns the converted CanonicalName in form of a DistinguishedName.
In this case the last object after slash '/' is an OrganizationalUnit.

### EXAMPLE 3
```
ConvertFrom-CanonicalName -CanonicalName 'Contoso.com/Department/Users/Roger Johnsson', 'Contoso.com/Tier1/Users/Bill T Admin'
```

CN=Roger Johnsson,OU=Users,OU=Department,DC=Contoso,DC=com
CN=Bill T Admin,OU=Users,OU=Tier1,DC=Contoso,DC=com

This example returns each CanonicalName converted in form of a DistinguishedName.

## PARAMETERS

### -CanonicalName
Specifies the CanonicalName string to be converted to a DistinguishedName string.

```yaml
Type: CanonicalName[]
Parameter Sets: (All)
Aliases: CN

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OrganizationalUnit
Specifies that the object is an OrganizationalUnit (OU=) instead of an Person (CN=).
Will automatically be an OrganizationalUnit if the CanonicalName string ends with a slash '/'

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

### DistinguishedName
## NOTES

## RELATED LINKS

[https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertFrom-CanonicalName.md](https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/ConvertFrom-CanonicalName.md)

