function Get-ClipboardArray {
    <#
        .SYNOPSIS
        Paste an array of objects from the clipboard (CTRL+V)

        .DESCRIPTION
        Paste an array of objects from the clipboard (CTRL+V) to a script variable.
        Default the function will set every object as a string. Using the parameter DataType can specify what every object should be tried to be converted to.
        The order for the data type conversion is [System.DateTime], [System.Int32], [System.Int64], [System.Boolean], [System.String].

        Default an empty string will close the loop from importing any more data.
        To change that behavior a specified [System.String] combination can be used with the -EndChar parameter to include empty lines as valid input data.

        .EXAMPLE
        Get-ClipboardArray

        No.[0]: Some data
        No.[1]: to
        No.[2]: paste
        No.[3]: into
        No.[4]: the function
        No.[5]:

        Empty line will close the loop from importing anything more.
        The input to will be saved to the variable ClipboardArray.
        Each item in the array will be of the data type [System.String].

        .EXAMPLE
        Get-ClipboardArray -DataType Int32

        No.[0]: Some data
        No.[1]: 20170101
        No.[2]: 123
        No.[3]: into
        No.[4]: 876 function
        No.[5]:
        Empty line will close the loop from importing anything more.
        The input to will be saved to the variable ClipboardArray.
        This example will try to convert every object in the pasted array to an System.Int32. If its not possible it will default back to System.String.
        Array object 2 is the only one that will be converted to a System.Int32 datatype.

        .EXAMPLE
        Get-ClipboardArray -DataType All

        No.[0]: Some data
        No.[1]: 2017-01-01
        No.[2]: 2147483647
        No.[3]: 2147483648
        No.[4]: TRUE
        No.[5]:

        Empty line will close the loop from importing anything more.
        The input to will be saved to the variable ClipboardArray.
        This example will try to convert every object in the pasted array to all available data types. If no conversion succeeded it will default back to System.String.
        The order for the data type conversion is [System.DateTime], [System.Int32], [System.Int64], [System.Boolean], [System.String].
        Array object 0 is a String, object 1 is a DateTime, object 2 is a Int32, object 3 is a Int64 and object 4 is a Boolean.

        .EXAMPLE
        Get-ClipboardArray -EndChar '?'

        No.[0]: Some data
        No.[1]: 2017-01-01
        No.[2]: 2147483647
        No.[3]: 2147483648
        No.[4]: TRUE
        No.[5]:
        No.[6]: ?

        The question mark will close the loop from importing anything more.
        The input to will be saved to the variable ClipboardArray.
        This example will not convert any objects in the array, all objects default to System.String.
        The EndChar parameter can be used when the input contains empty rows to not break the loop.

        .EXAMPLE
        Get-ClipboardArray -EndChar '!' -DataType All

        No.[0]: Some data
        No.[1]: 2017-01-01
        No.[2]: 2147483647
        No.[3]: 2147483648
        No.[4]: TRUE
        No.[5]:
        No.[6]: !

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
        This example will try to convert every object in the array to all available data types. If no conversion succeeded it will default back to System.String.
        The order for the data type conversion is [System.DateTime], [System.Int32], [System.Int64], [System.Boolean], [System.String].
        Array object 0 is a String, object 1 is a DateTime, object 2 is a Int32, object 3 is a Int64, object 4 is a Boolean and object 5 is a String.
        The EndChar parameter can be used when the input contains empty rows to not break the loop.

        .LINK
        https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-ClipboardArray.md
    #>
    [CmdletBinding(
        PositionalBinding = $false,
        DefaultParameterSetName = 'Default'
    )]
    [Alias('gca')]
    param (
        <#
            Specifies the TypeAccelerator of the clipboard that each input will be converted to. The acceptable values for this parameter are:
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
        #>
        [Parameter(
            Position = 0
        )]
        [ValidateSet('DateTime', 'Int32', 'Int64', 'Boolean', 'Char', 'Byte', 'Decimal', 'Double',
            'Int16', 'SByte', 'Single', 'UInt16', 'UInt32', 'UInt64', 'String', 'All')]
        [Alias('D')]
        [TypeAccelerators[]]$AsType = 'String',

        <#
            Specifies the a char or a string that will break the input loop.
            Default value is empty string ''
        #>
        [Parameter(
            Position = 1
        )]
        [Alias('E')]
        [AllowEmptyString]
        [string]$BreakString = ''
    )

    try {
        $PSTypeAccelerator = Get-PSTypeAccelerator -ErrorAction Stop
        New-Variable -Name ClipboardArray -Value ([Collections.ArrayList]::new()) -Scope Script -Force -Description 'Variable created from Get-ClipboardArray.'
        [int32]$n = 0
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    do {
        $Input = (Read-Host -Prompt "No.[$($n)]")
        $n++
        if ($Input -ne $BreakString) {
            $null = $script:ClipboardArray.Add([ConvertTypeAccelerator]::new($Input, $AsType, $PSTypeAccelerator))
        }
    }
    until ($Input -eq $BreakString)
    Write-Verbose -Message 'Enter $ClipboardArray to access the pasted array objects'
}