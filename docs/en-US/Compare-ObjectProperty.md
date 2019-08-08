---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version: https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Compare-ObjectProperty.md
schema: 2.0.0
---

# Compare-ObjectProperty

## SYNOPSIS
The Compare-ObjectProperty function compares two sets of objects and it's properties.

## SYNTAX

```
Compare-ObjectProperty [-ReferenceObject] <PSObject> [-DifferenceObject] <PSObject> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Compare-ObjectProperty function compares two sets of objects and it's properties.
One set of objects is the "reference set" and the other set is the "difference set."

The result will indicate if each property from the reference set is equal to each property of the difference set.

## EXAMPLES

### EXAMPLE 1
```
$Ref = Get-ADUser -Identity 'Roger Johnsson' -Properties *
```

$Dif = Get-ADUser -Identity 'John Rogersson' -Properties *
Compare-ObjectProperty -ReferenceObject $Ref -DifferenceObject $Dif

This example returns all properties for both the reference object and the difference object with a true respectively false if the properties is equal.
The original property for both reference object and the difference object is also returned.

## PARAMETERS

### -ReferenceObject
Specifies an object used as a reference for comparison.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -DifferenceObject
Specifies the object that are compared to the reference objects.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
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

## NOTES

## RELATED LINKS

[https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Compare-ObjectProperty.md](https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Compare-ObjectProperty.md)

