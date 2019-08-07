function Compare-ObjectProperty {
    [CmdletBinding(
        PositionalBinding,
        SupportsShouldProcess
    )]
    [Alias('cop')]
    param(
        [Parameter(
            HelpMessage = 'Enter objects used as a reference for comparison.',
            ValueFromPipeline,
            Mandatory,
            Position = 0
        )]
        [PSObject[]]$ReferenceObject,

        [Parameter(
            HelpMessage = 'Enter the objects that are compared to the reference objects.',
            Mandatory,
            Position = 1
        )]
        [PSObject[]]$DifferenceObject
    )
    $Properties = [Collections.ArrayList]::new()
    $Difference = [Collections.ArrayList]::new()
    $null = $Properties.Add([string]($ReferenceObject | Get-Member -MemberType Properties).Name)
    $null = $Properties.Add([string]($DifferenceObject | Get-Member -MemberType Properties).Name)
    $UniqueProperties = Sort-Object -InputObject $Properties -Unique

    foreach ($Property in $Properties) {
        if ($PSCmdlet.ShouldProcess('COMPARE SOMETHING', $MyInvocation.MyCommand.Name)) {
            $DiffProperty = Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject -Property $Property
            if ($DiffProperty) {
                $diffprops = [PSCustomObject]@{
                PropertyName=$objprop
                RefValue=($diff | ? {$_.SideIndicator -eq '<='} | % $($objprop))
                DiffValue=($diff | ? {$_.SideIndicator -eq '=>'} | % $($objprop))
            }
            }
        }
    }
}
