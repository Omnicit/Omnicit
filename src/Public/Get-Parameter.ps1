function Get-Parameter {
    <#
    .SYNOPSIS
        Enumerates the parameters of one or more commands
    .DESCRIPTION
        Lists all the parameters of a command, by ParameterSet, including their aliases, type, etc.

        By default, formats the output to tables grouped by command and parameter set
    .EXAMPLE
        Get-Command Select-Xml | Get-Parameter
    .EXAMPLE
        Get-Parameter Select-Xml
    .NOTES
        With many thanks to Joel Bennett, Jason Archer, Shay Levy, Hal Rottenberg, Oisin Grehan
    #>

    [CmdletBinding(
        DefaultParameterSetName = 'ParameterName'
    )]
    param(
        # The name of the command to get parameters for
        [Parameter(
            Position = 1,
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Name')]
        [string[]]$CommandName,

        # The parameter name to filter by (allows Wilcards)
        [Parameter(
            Position = 2,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'FilterNames'
        )]
        [string[]]$ParameterName = '*',

        # The ParameterSet name to filter by (allows wildcards)
        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'FilterSets')]
        [string[]]$SetName = '*',

        # The name of the module which contains the command (this is for scoping)
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]$ModuleName,

        # Skip testing for Provider parameters (will be much faster)
        [switch]$SkipProviderParameters,

        # Forces including the CommonParameters in the output
        [switch]$Force
    )

    begin {
        $PropertySet = @( 'Name',
            @{n = 'Position'; e = { if ($_.Position -lt 0) { 'Named' }else { $_.Position } } },
            'Aliases',
            @{n = 'Short'; e = { $_.Name } },
            @{n = 'Type'; e = { $_.ParameterType.Name } },
            @{n = 'ParameterSet'; e = { $paramset } },
            @{n = 'Command'; e = { $command } },
            @{n = 'Mandatory'; e = { $_.IsMandatory } },
            @{n = 'Provider'; e = { $_.DynamicProvider } },
            @{n = 'ValueFromPipeline'; e = { $_.ValueFromPipeline } },
            @{n = 'ValueFromPipelineByPropertyName'; e = { $_.ValueFromPipelineByPropertyName } }
        )
        function Join-Object {
            Param(
                [Parameter(Position = 0)]
                $First,

                [Parameter(ValueFromPipeline = $true, Position = 1)]
                $Second
            )
            begin {
                [string[]] $p1 = $First | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            }
            process {
                $Output = $First | Select-Object $p1
                foreach ($p in $Second | Get-Member -MemberType Properties | Where-Object { $p1 -notcontains $_.Name } | Select-Object -ExpandProperty Name) {
                    Add-Member -InputObject $Output -MemberType NoteProperty -Name $p -Value $Second.("$p")
                }
                $Output
            }
        }

        function Add-Parameter {
            [CmdletBinding()]
            param (
                [Parameter(
                    Position = 0
                )]
                [Hashtable]$Parameter,

                [Parameter(Position = 1)]
                [Management.Automation.ParameterMetadata[]]$MoreParameter
            )

            foreach ($p in $MoreParameter | Where-Object { !$Parameter.ContainsKey($_.Name) } ) {
                Write-Debug ('INITIALLY: ' + $p.Name)
                $Parameter.($p.Name) = $p | Select-Object *
            }

            [Array]$DynamicParameter = $MoreParameter | Where-Object { $_.IsDynamic }
            if ($DynamicParameter) {
                foreach ($DynamicParam in $DynamicParameter) {
                    if (Get-Member -InputObject $Parameter.($DynamicParam.Name) -Name DynamicProvider) {
                        Write-Debug ('ADD:' + $DynamicParam.Name + ' ' + $Provider.Name)
                        $Parameter.($DynamicParam.Name).DynamicProvider += $Provider.Name
                    }
                    else {
                        Write-Debug ('CREATE:' + $DynamicParam.Name + ' ' + $Provider.Name)
                        $Parameter.($DynamicParam.Name) = $Parameter.($DynamicParam.Name) | Select-Object *, @{ n = 'DynamicProvider'; e = { @($Provider.Name) } }
                    }
                }
            }
        }
    }

    process {
        foreach ($Cmd in $CommandName) {
            if ($ModuleName) {
                $Cmd = "$ModuleName\$Cmd"
            }
            Write-Verbose "Searching for $Cmd"
            $Command = @(Get-Command -Name $Cmd)

            #foreach ($command in $commands) {
            Write-Verbose "Searching for $Command"
            # Resolve aliases (an alias can point to another alias) that's why a while is used and not an if set.
            while ($Command.CommandType -eq 'Alias') {
                $Command = @(Get-Command -Name ($Command.Definition))[0]
            }

            if (-not $Command) {
                continue
            }

            Write-Verbose -Message 'Get-Parameter(s) for {0}\{1}' -f $Command.Source, $Command.Name

            $Parameters = @{ }

            # Detect provider parameters, i.e. Get-ChildItem.
            $NoProviderParameters = -not $SkipProviderParameters
            ## Shortcut: assume only the core commands get Provider dynamic parameters
            if (-not $SkipProviderParameters -and $Command.Source -eq 'Microsoft.PowerShell.Management') {
                ## The best I can do is to validate that the command has a parameter which could accept a string path
                foreach ($param in $Command.Parameters.Values) {
                    if (([String[]], [String] -contains $param.ParameterType) -and ($param.ParameterSets.Values | Where-Object { $_.Position -ge 0 })) {
                        $NoProviderParameters = $false
                        break
                    }
                }
            }

            if ($NoProviderParameters) {
                if ($Command.Parameters) {
                    Add-Parameters $Parameters $Command.Parameters.Values
                }
            }
            else {
                foreach ($Provider in @(Get-PSProvider)) {
                    if ($provider.Drives.Length -gt 0) {
                        $drive = Get-Location -PSProvider $Provider.Name
                    }
                    else {
                        $drive = '{0}\{1}::\' -f $provider.ModuleName, $provider.Name
                    }
                    Write-Verbose ("Get-Command $command -Args $drive | Select-Object -Expand Parameters")

                    try {
                        $MoreParameters = (Get-Command $command -Args $drive).Parameters.Values
                    }
                    catch { }

                    if ($MoreParameters.Length -gt 0) {
                        Add-Parameters $Parameters $MoreParameters
                    }
                }
                # If for some reason none of the drive paths worked, just use the default parameters
                if ($Parameters.Length -eq 0) {
                    if ($Command.Parameters) {
                        Add-Parameters $Parameters $Command.Parameters.Values
                    }
                }
            }

            ## Calculate the shortest distinct parameter name -- do this BEFORE removing the common parameters or else.
            $Aliases = $Parameters.Values | Select-Object -ExpandProperty Aliases  ## Get defined aliases
            $ParameterNames = $Parameters.Keys + $Aliases
            foreach ($p in $($Parameters.Keys)) {
                $short = '^'
                $aliases = @($p) + @($Parameters.$p.Aliases) | Sort-Object { $_.Length }
                $shortest = '^' + @($aliases)[0]

                foreach ($name in $aliases) {
                    $short = '^'
                    foreach ($char in [char[]]$name) {
                        $short += $char
                        $mCount = ($ParameterNames -match $short).Count
                        if ($mCount -eq 1 ) {
                            if ($short.Length -lt $shortest.Length) {
                                $shortest = $short
                            }
                            break
                        }
                    }
                }
                if ($shortest.Length -lt @($aliases)[0].Length + 1) {
                    # Overwrite the Aliases with this new value
                    $Parameters.$p = $Parameters.$p | Add-Member NoteProperty Aliases ($Parameters.$p.Aliases + @("$($shortest.SubString(1))*")) -Force -Passthru
                }
            }

            # Write-Verbose 'Parameters: $($Parameters.Count)`n $($Parameters | ft | out-string)'
            $CommonParameters = [string[]][System.Management.Automation.Cmdlet]::CommonParameters

            foreach ($paramset in @($command.ParameterSets | Select-Object -ExpandProperty 'Name')) {
                $paramset = $paramset | Add-Member -Name IsDefault -MemberType NoteProperty -Value ($paramset -eq $command.DefaultParameterSet) -PassThru
                foreach ($parameter in $Parameters.Keys | Sort-Object) {
                    # Write-Verbose "Parameter: $Parameter"
                    if (!$Force -and ($CommonParameters -contains $Parameter)) { continue }
                    if ($Parameters.$Parameter.ParameterSets.ContainsKey($paramset) -or $Parameters.$Parameter.ParameterSets.ContainsKey('__AllParameterSets')) {
                        if ($Parameters.$Parameter.ParameterSets.ContainsKey($paramset)) {
                            $output = Join-Object $Parameters.$Parameter $Parameters.$Parameter.ParameterSets.$paramSet
                        }
                        else {
                            $output = Join-Object $Parameters.$Parameter $Parameters.$Parameter.ParameterSets.__AllParameterSets
                        }

                        Write-Output $Output | Select-Object $PropertySet | ForEach-Object {
                            $null = $_.PSTypeNames.Insert(0, 'System.Management.Automation.ParameterMetadataEx')
                            # Write-Verbose "$(($_.PSTypeNames.GetEnumerator()) -join ", ")"
                            $_
                        } |
                        Add-Member ScriptMethod ToString { $this.Name } -Force -Passthru |
                        Where-Object { $(foreach ($pn in $ParameterName) { $_ -like $Pn }) -contains $true } |
                        Where-Object { $(foreach ($sn in $SetName) { $_.ParameterSet -like $sn }) -contains $true }

                }
            }
        }
        #}
    }
}
