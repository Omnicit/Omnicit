enum TypeAccelerators {
    DateTime
    Int32
    Int64
    Boolean
    Char
    Byte
    Decimal
    Double
    Int16
    SByte
    Single
    UInt16
    UInt32
    UInt64
    String
    All
}

class ConvertTypeAccelerator {
    [Object]$Object
    [Object]$ObjectType

    ConvertTypeAccelerator([string]$Object, [TypeAccelerators[]]$ObjectType, [Object]$PSTypeAccelerators) {
        if ($ObjectType -eq [TypeAccelerators]::All) {
            [TypeAccelerators[]]$Enums = ([enum]::GetNames([TypeAccelerators])).Where( { $_ -ne 'All' } )
        }
        else {
            [TypeAccelerators[]]$Enums = $ObjectType
        }
        foreach ($Enum in $Enums) {
            try {
                $this.Object = [Convert]::"To$($Enum)"($Object)
                if ($Enum -eq 'Boolean') {
                    $Enum = 'bool'
                }
                $this.ObjectType = $PSTypeAccelerators[$Enum.ToString()]
                break
            }
            catch {
                continue
            }
        }
        if ($null -eq $this.Object) {
            $this.Object     = [string]$Object
            $this.ObjectType = $PSTypeAccelerators['String']
        }
    }
}