---
external help file: Omnicit-help.xml
Module Name: Omnicit
online version: https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-ClipboardArray.md
schema: 2.0.0
---

# Get-ClipboardArray

## SYNOPSIS
Paste an array of objects from the clipboard (CTRL+V)

## SYNTAX

```
Get-ClipboardArray [[-BreakString] <String>] [[-AsType] <TypeAccelerators[]>] [<CommonParameters>]
```

## DESCRIPTION
Paste an array of objects from the clipboard (CTRL+V) to the variable $ClipboardArray (global scope).
Using the parameter, AsType, can specify what every object should be tried to be converted to.
If conversion fails every object as a type string.
The order for the data type conversion is:
\[DateTime\], \[Int32\], \[Int64\], \[Boolean\], \[Char\], \[Byte\], \[Decimal\], \[Double\], \[Int16\], \[SByte\], \[Single\], \[UInt16\], \[UInt32\], \[UInt64\], \[String\]

Default an empty string will close the loop from importing any more data, default behavior of Read-Host.
To change that behavior a specified \[System.String\] combination can be used with the -BreakString parameter to include empty lines as valid input data.

## EXAMPLES

### EXAMPLE 1
```
Get-ClipboardArray
```

No.\[0\]: Some data
No.\[1\]: to
No.\[2\]: paste
No.\[3\]: into
No.\[4\]: the function
No.\[5\]:

Empty line will close the loop from importing anything more.
The input to will be saved to the variable ClipboardArray.
Each item in the array will be of the data type \[System.String\].

### EXAMPLE 2
```
Get-ClipboardArray -AsType Int32
```

No.\[0\]: Some data
No.\[1\]: 20170101
No.\[2\]: 123
No.\[3\]: into
No.\[4\]: 876 function
No.\[5\]:

Empty line will close the loop from importing anything more.
The input to will be saved to the variable ClipboardArray.
This example will try to convert every object in the pasted array to an System.Int32.
If its not possible it will default back to System.String.
Array object \[1\] and \[2\] is the only objects that will be converted to a System.Int32 type accelerator.

### EXAMPLE 3
```
Get-ClipboardArray -AsType All
```

No.\[0\]: Some data
No.\[1\]: 2017-01-01
No.\[2\]: 2147483647
No.\[3\]: 2147483648
No.\[4\]: TRUE
No.\[5\]:

Empty line will close the loop from importing anything more.
The input to will be saved to the variable ClipboardArray.
This example will try to convert every object in the pasted array to all available data types.
If no conversion succeeded it will default back to System.String.
The order for the data type conversion is \[System.DateTime\], \[System.Int32\], \[System.Int64\], \[System.Boolean\], \[System.String\].
Array object \[0\] is a String, object \[1\] is a DateTime, object \[2\] is an Int32, object \[3\] is an Int64 and object \[4\] is a Boolean.

### EXAMPLE 4
```
Get-ClipboardArray -BreakString '?'
```

No.\[0\]: Some data
No.\[1\]: 2017-01-01
No.\[2\]: 2147483647
No.\[3\]: 2147483648
No.\[4\]: TRUE
No.\[5\]:
No.\[6\]: ?

The question mark will close the loop from importing anything more.
The input to will be saved to the variable ClipboardArray.
This example will not convert any objects in the array, all objects default to System.String.
The BreakString parameter can be used when the input contains empty rows to not break the loop.

### EXAMPLE 5
```
Get-ClipboardArray -BreakString '?' -AsType All
```

No.\[0\]: Some data
No.\[1\]: 2017-01-01
No.\[2\]: 2147483647
No.\[3\]: 2147483648
No.\[4\]: TRUE
No.\[5\]:
No.\[6\]: ?

$ClipboardArray | foreach {$_.Gettype()}
IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     String                                   System.Object
True     True     DateTime                                 System.ValueType
True     True     Int32                                    System.ValueType
True     True     Int64                                    System.ValueType
True     True     Boolean                                  System.ValueType
True     True     String                                   System.Object

The exclamation mark will close the loop from importing anything more.
The input to will be saved to the variable ClipboardArray.
This example will try to convert every object in the array to all available data types.
If no conversion succeeded it will default back to System.String.
The order for the data type conversion is \[System.DateTime\], \[System.Int32\], \[System.Int64\], \[System.Boolean\], \[System.String\].
Array object \[0\] is a String, object \[1\] is a DateTime, object \[2\] is an Int32, object \[3\] is an Int64, object \[4\] is a Boolean and object \[5\] is a String.
The BreakString parameter can be used when the input contains empty rows to not break the loop.

## PARAMETERS

### -BreakString
Specifies the a single char or a string that will break the input loop.
Default value is empty string ''
Quote and some other special chars ("''\`´""''''"!) is not permitted as input.

```yaml
Type: String
Parameter Sets: (All)
Aliases: B

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsType
Specifies the TypeAccelerator of the clipboard that each input will be converted to.
The acceptable values for this parameter are:
- DateTime
- Int32
- Int64
- Boolean
- Char
- Byte
- Decimal
- Double
- Int16
- SByte
- Single
- UInt16
- UInt32
- UInt64
- String
- All

```yaml
Type: TypeAccelerators[]
Parameter Sets: (All)
Aliases: D
Accepted values: DateTime, Int32, Int64, Boolean, Char, Byte, Decimal, Double, Int16, SByte, Single, UInt16, UInt32, UInt64, String, All

Required: False
Position: 2
Default value: String
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-ClipboardArray.md](https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-ClipboardArray.md)

