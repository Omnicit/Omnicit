---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version: https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-FolderSize.md
schema: 2.0.0
---

# Get-FolderSize

## SYNOPSIS
Get folder size using Robocopy.exe and displays the output in a PSObject table.

## SYNTAX

### Default (Default)
```
Get-FolderSize [[-Path] <String[]>] [[-BytePrecision] <Int32>] [[-RobocopyThreadCount] <Int32>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### MinFile
```
Get-FolderSize [[-Path] <String[]>] [-MinFileAgeDate] <DateTime> [[-BytePrecision] <Int32>]
 [[-RobocopyThreadCount] <Int32>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### MaxFile
```
Get-FolderSize [[-Path] <String[]>] [-MaxFileAgeDate] <DateTime> [[-BytePrecision] <Int32>]
 [[-RobocopyThreadCount] <Int32>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function uses Robocopy.exe to calculate the size used for the select path.
You can specify if you want to display files older than a specific date using the MinFileData parameter.
If you experience that the function Get-FolderSize (Robocopy) takes time to execute you can increase the threads used by Robocopy with the RobocopyThreadCount parameter.

## EXAMPLES

### EXAMPLE 1
```
Get-FolderSize
```

Path       TotalBytes  TotalMBytes TotalGBytes FilesCount DirCount TimeElapsed
----       ----------  ----------- ----------- ---------- -------- -----------
C:\Windows 18512797867 17655,18    17,24       144492     34036    00:00:12.2813478

This example returns a PSObject with the total folder size for the current location, which in this case in C:\Windows.

### EXAMPLE 2
```
Get-FolderSize -Path \\contoso.com\NETLOGON
```

Path                   TotalBytes TotalMBytes TotalGBytes FilesCount DirCount TimeElapsed
----                   ---------- ----------- ----------- ---------- -------- -----------
\\\\contoso.com\NETLOGON 1019904    0,97        0,00        1          2        00:00:00.0157300

This example returns a PSObject with the total folder size for the specified location path \\\\contoso.com\NETLOGON.

### EXAMPLE 3
```
Get-FolderSize -Path \\contoso.net\NETLOGON -BytePrecision 4
```

Path                   TotalBytes TotalMBytes TotalGBytes FilesCount DirCount TimeElapsed
----                   ---------- ----------- ----------- ---------- -------- -----------
\\\\contoso.com\NETLOGON 1019904    0,9727      0,0009      1          2        00:00:00.0155598

This example returns a PSObject with the total folder size, with for decimals, for the specified location path \\\\contoso.com\NETLOGON.

### EXAMPLE 4
```
Get-FolderSize -Path C:\Windows -MinFileAgeDate 2019-06-01
```

Path       TotalBytes  TotalMBytes TotalGBytes FilesCount DirCount TimeElapsed
----       ----------  ----------- ----------- ---------- -------- -----------
C:\Windows 11448807458 10918,43    10,66       101354     34036    00:00:24.1594950

This example returns a PSObject with the total folder size for the specified location path C:\Windows and excludes files newer than 2019-06-01.

### EXAMPLE 5
```
Get-FolderSize -Path C:\Windows -MaxFileAgeDate 2019-06-01
```

Path       TotalBytes TotalMBytes TotalGBytes FilesCount DirCount TimeElapsed
----       ---------- ----------- ----------- ---------- -------- -----------
C:\Windows 7063990409 6736,75     6,58        43138      34036    00:00:10.2498128

This example returns a PSObject with the total folder size for the specified location path C:\Windows and excludes files older than 2019-06-01.

### EXAMPLE 6
```
Get-FolderSize -Path C:\Windows -MaxFileAgeDate 2019-06-01 | Select-Object -Property *
```

Path              : C:\Windows
TotalBytes        : 7065038985
TotalMBytes       : 6737,75
TotalGBytes       : 6,58
FilesCount        : 43138
DirCount          : 34036
BytesFailed       : 0
DirFailed         : 0
FileFailed        : 0
TimeElapsed       : 00:00:10.0465934
StartedTime       : 2019-09-05 22:28:33
EndedTime         : 2019-09-05 22:28:43
DateFilter        : Maximum file age "2019-06-01".
TotalBytesNoDate  : 18474790494
TotalMBytesNoDate : 17618,93
TotalGBytesNoDate : 17,21
DirCountNoDate    : 34057
FileCountNoDate   : 144414

This example returns a PSObject with all available properties extracted from the specified location path C:\Windows and excludes files older than 2019-06-01.

## PARAMETERS

### -Path
Specifies the path to the source directory to measure.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Current path
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -MinFileAgeDate
Specifies the minimum file age (exclude files newer than N date).

```yaml
Type: DateTime
Parameter Sets: MinFile
Aliases: MinDate

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxFileAgeDate
Specifies the maximum file age (to exclude files older than N date).

```yaml
Type: DateTime
Parameter Sets: MaxFile
Aliases: MaxDate

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BytePrecision
Specifies number of fractional digits, and rounds midpoint values to the nearest even number when converting bytes.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 2
Accept pipeline input: False
Accept wildcard characters: False
```

### -RobocopyThreadCount
Number of threads used for Robocopy.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 16
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

[https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-FolderSize.md](https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-FolderSize.md)

