---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version:
schema: 2.0.0
---

# Invoke-ModuleUpdate

## SYNOPSIS
Update one, several or all installed modules if an update is available from a repository location.

## SYNTAX

### NoUpdate (Default)
```
Invoke-ModuleUpdate [[-Name] <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Update
```
Invoke-ModuleUpdate [[-Name] <String[]>] [-Update] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Invoke-ModuleUpdate for installed modules that have a repository location, for example from PowerShell Gallery.
The function, without the Update parameter, returns the current and the latest version available for each installed module with a repository location.
If there is any existing installed versions for each module that current version number will be displayed under Multiple versions.
When the Update parameter is issued the function will update the named modules.

The script is based on the "Check-ModuleUpdate.ps1" from Jeffery Hicks* to check for available updates for installed PowerShell modules.
*Credit: http://jdhitsolutions.com/blog/powershell/5441/check-for-module-updates/

## EXAMPLES

### EXAMPLE 1
```
Invoke-ModuleUpdate
```

Name                                             Current Version  Online Version   Multiple Versions
----                                             ---------------  --------------   -----------------
SpeculationControl                               1.0.0            1.0.8            False
AzureAD                                          2.0.0.131        2.0.1.10         {2.0.0.115}
AzureADPreview                                   2.0.0.154        2.0.1.11         {2.0.0.137}
ISESteroids                                      2.7.1.7          2.7.1.7          {2.6.3.30}
MicrosoftTeams                                   0.9.1            0.9.3            False
NTFSSecurity                                     4.2.3            4.2.3            False
Office365Connect                                 1.5.0            1.5.0            False
... 
... 
... 
...

This example returns the current and the latest version available for all installed modules that have a repository location.

### EXAMPLE 2
```
Invoke-ModuleUpdate -Update
```

Name                                             Current Version  Online Version   Multiple Versions
----                                             ---------------  --------------   -----------------
SpeculationControl                               1.0.8            1.0.8            {1.0.0}
AzureAD                                          2.0.1.10         2.0.1.10         {2.0.0.131, 2.0.0.115}
AzureADPreview                                   2.0.1.11         2.0.1.11         {2.0.0.137, 2.0.0.154}
ISESteroids                                      2.7.1.7          2.7.1.7          {2.6.3.30}
MicrosoftTeams                                   0.9.3            0.9.3            {0.9.1}
NTFSSecurity                                     4.2.3            4.2.3            False
Office365Connect                                 1.5.0            1.5.0            False
... 
... 
... 
...

This example installs the latest version available for all installed modules that have a repository location.

### EXAMPLE 3
```
Invoke-ModuleUpdate -Name 'AzureAD', 'PSScriptAnalyzer' -Update -Force
```

Name                                             Current Version  Online Version   Multiple Versions
----                                             ---------------  --------------   -----------------
AzureAD                                          2.0.1.10         2.0.1.10         {2.0.0.131, 2.0.0.115}
PSScriptAnalyzer                                 1.17.1           1.17.1           {1.17.0}

This example will force install the latest version available for the AzureAD and PSScriptAnalyzer modules.

## PARAMETERS

### -Name
Specifies names or name patterns of modules that this function gets.
Wildcard characters are permitted.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: True (ByValue)
Accept wildcard characters: True
```

### -Update
Switch parameter to invoke the 'Update-Module' cmdlet for the targeted modules.
The default behavior without this switch is that the function will only list the current and available versions.

```yaml
Type: SwitchParameter
Parameter Sets: Update
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Switch parameter forces the update of each specified module, regardless of the current version of the module installed.
Using the 'Force' parameter without using 'Update' parameter does not perform anything extra.

```yaml
Type: SwitchParameter
Parameter Sets: Update
Aliases:

Required: False
Position: 3
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Created by:     Philip Haglund
Organization:   Omnicit AB
Filename:       Invoke-ModuleUpdate.ps1
Version:        1.0.0
Requirements:   Powershell 4.0

## RELATED LINKS
