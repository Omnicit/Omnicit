function Compare-ObjectProperty {
    <#
    .SYNOPSIS
    The Compare-ObjectProperty function compares two sets of objects and it's properties.

    .DESCRIPTION
    The Compare-ObjectProperty function compares two sets of objects and it's properties.
    One set of objects is the "reference set" and the other set is the "difference set."

    The result will indicate if each property from the reference set is equal to each property of the difference set.

    .EXAMPLE
    $Ref = Get-ADUser -Identity 'Roger Johnsson' -Properties *
    $Dif = Get-ADUser -Identity 'John Rogersson' -Properties *
    Compare-ObjectProperty -ReferenceObject $Ref -DifferenceObject $Dif

    This example returns all properties for both the reference object and the difference object with a true respectively false if the properties is equal.
    The original property for both reference object and the difference object is also returned.

    .LINK
        https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Compare-ObjectProperty.md
    #>
    [CmdletBinding(
        PositionalBinding,
        SupportsShouldProcess
    )]
    [Alias('cop')]
    param(
        # Specifies an object used as a reference for comparison.
        [Parameter(
            HelpMessage = 'Enter objects used as a reference for comparison.',
            ValueFromPipeline,
            Mandatory,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [PSObject]$ReferenceObject,
        # Specifies the object that are compared to the reference objects.
        [Parameter(
            HelpMessage = 'Enter the objects that are compared to the reference objects.',
            Mandatory,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [PSObject]$DifferenceObject
    )
    $Properties = [Collections.ArrayList]::new()
    $null = $Properties.AddRange([string[]]($ReferenceObject | Get-Member -MemberType Properties).Name)
    $null = $Properties.AddRange([string[]]($DifferenceObject | Get-Member -MemberType Properties).Name)
    $AllProperties = $Properties | Sort-Object -Unique

    foreach ($Property in $AllProperties) {
        if ($PSCmdlet.ShouldProcess($Property, $MyInvocation.MyCommand.Name)) {
            try {
                $DiffProperty = Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject -Property $Property -ErrorAction Stop
            }
            catch {
                $DiffProperty = $true
            }
            [PSCustomObject]@{
                PSTypeName      = 'Omnicit.Compare.ObjectProperty'
                PropertyName    = $Property
                PropertyMatch   = (-not [bool]$DiffProperty)
                ReferenceValue  = $ReferenceObject."$Property"
                DifferenceValue = $DifferenceObject."$Property"
            }
        }
    }
}
