---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version: https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Start-Mstsc.md
schema: 2.0.0
---

# Start-Mstsc

## SYNOPSIS
Start a Mstsc process using predefined arguments from parameters.

## SYNTAX

### Default (Default)
```
Start-Mstsc [-ComputerName] <String[]> [-Admin] [[-Port] <Int32>] [-Prompt] [-Public] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### FullScreen
```
Start-Mstsc [-ComputerName] <String[]> [-Admin] [[-Port] <Int32>] [-FullScreen] [-Prompt] [-Public] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### FixedSize
```
Start-Mstsc [-ComputerName] <String[]> [-Admin] [[-Port] <Int32>] -Width <Int32> -Height <Int32> [-Prompt]
 [-Public] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Span
```
Start-Mstsc [-ComputerName] <String[]> [-Admin] [[-Port] <Int32>] [-Span] [-Prompt] [-Public] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### MultiMonitor
```
Start-Mstsc [-ComputerName] <String[]> [-Admin] [[-Port] <Int32>] [-MultiMonitor] [-Prompt] [-Public] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### RestrictedAdmin
```
Start-Mstsc [-ComputerName] <String[]> [-Admin] [[-Port] <Int32>] [-Prompt] [-Public] [-RestrictedAdmin]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### RemoteGuard
```
Start-Mstsc [-ComputerName] <String[]> [-Admin] [[-Port] <Int32>] [-Prompt] [-Public] [-RemoteGuard] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Start-Mstsc function starts a mstsc.exe process with arguments defined from the parameters.
Built in check to validate that the current system is Windows.
Shadow parameters are not yet implemented.
Default port is defined as 3389.

## EXAMPLES

### EXAMPLE 1
```
Start-Mstsc -ComputerName Server01
```

Starts mstsc.exe with the arguments /v:Server01:3389

Connects to Server01 using the default RDP port 3389.

### EXAMPLE 2
```
Start-Mstsc -ComputerName Server01 -Admin
```

Starts mstsc.exe with the arguments /v:Server01:3389 /admin

Connects to the console on Server01 using the default RDP port 3389.

### EXAMPLE 3
```
Start-Mstsc -ComputerName Server01 -Admin -Port 9876
```

Starts mstsc.exe with the arguments /v:Server01:9876 /admin

Connects to the console on Server01 using port 9876.

### EXAMPLE 4
```
Start-Mstsc -ComputerName Server01 -Admin -Port 9876 -FullScreen
```

Starts mstsc.exe with the arguments /v:Server01:9876 /admin /f

Connects to the console on Server01 using port 9876 with full-screen.

### EXAMPLE 5
```
Start-Mstsc -ComputerName Server01 -Admin -Port 9876 -FullScreen -Prompt
```

Starts mstsc.exe with the arguments /v:Server01:9876 /admin /f /prompt

Connects to the console on Server01 using port 9876 with full-screen and prompt for credentials.

### EXAMPLE 6
```
Start-Mstsc -ComputerName Server01 -Admin -Port 9876 -FullScreen -Prompt -Public
```

Starts mstsc.exe with the arguments /v:Server01:9876 /admin /f /prompt /public

Connects to the console on Server01 using port 9876 with full-screen, prompt for credentials and run RDP in public mode.

### EXAMPLE 7
```
Start-Mstsc -ComputerName Server01 -RestrictedAdmin
```

Starts mstsc.exe with the arguments /v:Server01:3389 /restrictedAdmin

Connects to Server01 using the default RDP port 3389 with Restricted Admin.

### EXAMPLE 8
```
Start-Mstsc -ComputerName Server01 -RemoteGuard
```

Starts mstsc.exe with the arguments /v:Server01:3389 /remoteGuard

Connects to Server01 using the default RDP port 3389 with Remote Guard.

## PARAMETERS

### -ComputerName
Specifies the remote PC or Server to which you want to connect.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Server, IPAddress, Target, Node, Client

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Admin
Connects you to the console session for administering a remote PC.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Console

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Port
Specifies the port of the remote PC to which you want to connect.
Default value is 3389.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 3389
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullScreen
Starts Remote Desktop in full-screen mode.

```yaml
Type: SwitchParameter
Parameter Sets: FullScreen
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Width
Specifies the width of the Remote Desktop window.

```yaml
Type: Int32
Parameter Sets: FixedSize
Aliases: w

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Height
Specifies the height of the Remote Desktop window.

```yaml
Type: Int32
Parameter Sets: FixedSize
Aliases: h

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Span
Matches the remote desktop width and height with the local virtual desktop, spanning across multiple monitors, if necessary.
To span across monitors, the monitors must be arranged to form a rectangle.

```yaml
Type: SwitchParameter
Parameter Sets: Span
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MultiMonitor
Configures the Remote Desktop Services session monitor layout to be identical to the current client-side configuration.

```yaml
Type: SwitchParameter
Parameter Sets: MultiMonitor
Aliases: multimon

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prompt
Prompts you for your credentials when you connect to the remote PC.

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

### -Public
Runs Remote Desktop in public mode.

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

### -RestrictedAdmin
Connects you to the remote PC in Restricted Administration mode.
In this mode, credentials won't be sent to the remote PC, which can protect you if you connect to a PC that has been compromised.
However, connections made from the remote PC might not be authenticated by other PCs, which might impact application functionality and compatibility.
This parameter implies the admin parameter.

```yaml
Type: SwitchParameter
Parameter Sets: RestrictedAdmin
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoteGuard
Connects your device to a remote device using Remote Guard.
Remote Guard prevents credentials from being sent to the remote PC, which can help protect your credentials if you connect to a remote PC that has been compromised.
Unlike Restricted Administration mode, Remote Guard also supports connections made from the remote PC by redirecting all requests back to your device.

```yaml
Type: SwitchParameter
Parameter Sets: RemoteGuard
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

## NOTES

## RELATED LINKS

[https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Start-Mstsc.md](https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Start-Mstsc.md)

