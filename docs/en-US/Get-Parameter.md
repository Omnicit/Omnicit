---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version: https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-FolderSize.md
schema: 2.0.0
---

# Get-Parameter

## SYNOPSIS
Enumerates the parameters of one or more commands

## SYNTAX

### ParameterName (Default)
```
Get-Parameter [-CommandName] <String[]> [-ModuleName <String>] [-SkipProviderParameters] [-Force]
 [<CommonParameters>]
```

### FilterNames
```
Get-Parameter [-CommandName] <String[]> [[-ParameterName] <String[]>] [-ModuleName <String>]
 [-SkipProviderParameters] [-Force] [<CommonParameters>]
```

### FilterSets
```
Get-Parameter [-CommandName] <String[]> [-SetName <String[]>] [-ModuleName <String>] [-SkipProviderParameters]
 [-Force] [<CommonParameters>]
```

## DESCRIPTION
Lists all the parameters of a command, by ParameterSet, including their aliases, type, position, mandatory, etc.

By default, formats the output to tables grouped by command and parameter set.

## EXAMPLES

### EXAMPLE 1
```
Get-Parameter -CommandName Select-XML
```

Command: Microsoft.PowerShell.Utility/Select-Xml
    Set: Xml *

Name                   Aliases      Position Mandatory Pipeline ByName Provider        Type
----                   -------      -------- --------- -------- ------ --------        ----
Namespace              {Na*}        Named    False     False    False  All             Hashtable
Xml                    {Node, Xm*}  1        True      True     True   All             XmlNode\[\]
XPath                  {XP*}        0        True      False    False  All             String


    Command: Microsoft.PowerShell.Utility/Select-Xml
    Set: Path

Name                   Aliases      Position Mandatory Pipeline ByName Provider        Type
----                   -------      -------- --------- -------- ------ --------        ----
Namespace              {Na*}        Named    False     False    False  All             Hashtable
Path                   {Pa*}        1        True      False    True   All             String\[\]
XPath                  {XP*}        0        True      False    False  All             String
...

This example returns a PSObject which displays the parameters sorted by the Parameter Sets for the cmdlet Select-XML.

### EXAMPLE 2
```
Get-Command Select-Xml | Get-Parameter
```

Command: Microsoft.PowerShell.Utility/Select-Xml
    Set: Xml *

Name                   Aliases      Position Mandatory Pipeline ByName Provider        Type
----                   -------      -------- --------- -------- ------ --------        ----
Namespace              {Na*}        Named    False     False    False  All             Hashtable
Xml                    {Node, Xm*}  1        True      True     True   All             XmlNode\[\]
XPath                  {XP*}        0        True      False    False  All             String


    Command: Microsoft.PowerShell.Utility/Select-Xml
    Set: Path

Name                   Aliases      Position Mandatory Pipeline ByName Provider        Type
----                   -------      -------- --------- -------- ------ --------        ----
Namespace              {Na*}        Named    False     False    False  All             Hashtable
Path                   {Pa*}        1        True      False    True   All             String\[\]
XPath                  {XP*}        0        True      False    False  All             String
...

This example returns a PSObject which displays the parameters sorted by the Parameter Sets for the cmdlet Select-XML.

### EXAMPLE 3
```
Get-Parameter -CommandName Select-Xml -SetName Path
```

Command: Microsoft.PowerShell.Utility/Select-Xml
    Set: Path


Name                   Aliases      Position Mandatory Pipeline ByName Provider        Type
----                   -------      -------- --------- -------- ------ --------        ----
Namespace              {Na*}        Named    False     False    False  All             Hashtable
Path                   {Pa*}        1        True      False    True   All             String\[\]
XPath                  {XP*}        0        True      False    False  All             String

This example returns a PSObject which displays the parameters filtered by the Parameter Set 'Path' for the cmdlet Select-XML.

## PARAMETERS

### -CommandName
The name of the command to get parameters for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Name

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ParameterName
The parameter name to filter by (allows Wilcards).

```yaml
Type: String[]
Parameter Sets: FilterNames
Aliases:

Required: False
Position: 3
Default value: *
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SetName
The ParameterSet name to filter by (allows wildcards).

```yaml
Type: String[]
Parameter Sets: FilterSets
Aliases:

Required: False
Position: Named
Default value: *
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ModuleName
The name of the module which contains the command (this is for scoping).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SkipProviderParameters
Skip testing for Provider parameters (will be much faster)

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

### -Force
Forces including the CommonParameters in the output

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
With many thanks to Joel Bennett, Jason Archer, Shay Levy, Hal Rottenberg, Oisin Grehan

## RELATED LINKS
