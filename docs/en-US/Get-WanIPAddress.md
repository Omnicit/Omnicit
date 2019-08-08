---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version: https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-WanIPAddress.md
schema: 2.0.0
---

# Get-WanIPAddress

## SYNOPSIS
The Get-WanIPAddress function retrieves the current external IP address.

## SYNTAX

```
Get-WanIPAddress [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Get-WanIPAddress function retrieves the current external IP address using ifconfig.co as the API provider.

## EXAMPLES

### EXAMPLE 1
```
Get-WanIPAddress
```

IP Address   Country City        Hostname                       ISP
----------   ------- ----        --------                       ---
123.45.67.89 Sweden  Gothenburg  h-123-45.A56.priv.contoso.com  Contso.com

## PARAMETERS

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

[https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-WanIPAddress.md](https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-WanIPAddress.md)

