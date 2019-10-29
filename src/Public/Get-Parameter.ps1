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
        <#$PropertySet = @( 'Name',
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
        )#>
        function Join-ParameterObject {
            param(
                [PSObject]$ParameterMetadata,

                [object]$ParameterSetData
            )

            # Sort ParameterMetadata and $ParameterSetData objects alphabetical and remove duplicate properties.
            [string[]]$SortedParameterMetadata = ($ParameterMetadata | Get-Member -MemberType Properties | Sort-Object -Property Name).Name
            foreach ($ParameterSetDataProperty in ($ParameterSetData | Get-Member -MemberType Properties | Where-Object { $SortedParameterMetadata -notcontains $_.Name }).Name) {
                $ParameterMetadata | Add-Member -MemberType NoteProperty -Name $ParameterSetDataProperty -Value $ParameterSetData.$ParameterSetDataProperty
            }

            [PSCustomObject]@{
                PSTypeName                      = 'Omnicit.Get.Parameter'
                Name                            = $ParameterMetadata.Name
                Position                        = if ($ParameterMetadata.Position -lt 0) { 'Named' } else { $ParameterMetadata.Position }
                Aliases                         = $ParameterMetadata.Aliases
                Short                           = $ParameterMetadata.Name
                Type                            = $ParameterMetadata.ParameterType.Name
                ParameterSet                    = $ParamSet
                Command                         = $Command
                Mandatory                       = $ParameterMetadata.IsMandatory
                Provider                        = $ParameterMetadata.DynamicProvider
                ValueFromPipeline               = $ParameterMetadata.ValueFromPipeline
                ValueFromPipelineByPropertyName = $ParameterMetadata.ValueFromPipelineByPropertyName
            }
        }

        function Add-Parameter {
            [CmdletBinding()]
            param (
                # Parameter used to provide the Hashtable to the pipeline for the $Parameters variable.
                [Hashtable]$OutputParameter,

                # The actual parameters from the $Command
                [Management.Automation.ParameterMetadata[]]$InputParameter
            )

            foreach ($Parameter in $InputParameter | Where-Object { !$OutputParameter.ContainsKey($_.Name) } ) {
                Write-Debug ('INITIALLY: ' + $Parameter.Name)
                $OutputParameter.($Parameter.Name) = $Parameter | Select-Object -Property '*'
            }

            [Array]$DynamicParameter = $InputParameter | Where-Object { $_.IsDynamic }
            if ($DynamicParameter) {
                foreach ($DynamicParam in $DynamicParameter) {
                    if (Get-Member -InputObject $OutputParameter.($DynamicParam.Name) -Name DynamicProvider) {
                        Write-Debug ('ADD:' + $DynamicParam.Name + ' ' + $Provider.Name)
                        $OutputParameter.($DynamicParam.Name).DynamicProvider += $Provider.Name
                    }
                    else {
                        Write-Debug ('CREATE:' + $DynamicParam.Name + ' ' + $Provider.Name)
                        $OutputParameter.($DynamicParam.Name) = $OutputParameter.($DynamicParam.Name) | Select-Object -Property '*', @{ n = 'DynamicProvider'; e = { @($Provider.Name) } }
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
            try {
                $Command = @(Get-Command -Name $Cmd -ErrorAction Stop)
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
            #foreach ($command in $commands) {
            #Write-Verbose "Searching for $Command"
            # Resolve aliases (an alias can point to another alias) that's why a while is used and not an if set.
            while ($Command.CommandType -eq 'Alias') {
                try {
                    $Command = @(Get-Command -Name ($Command.Definition) -ErrorAction Stop)[0]
                }
                catch {
                    continue
                }
            }

            if ($null -eq $Command) {
                Write-Warning -Message ('No command with name "{0}" found' -f $Command.Name)
                continue
            }

            Write-Verbose -Message ('Get-Parameter(s) for {0}\ {1}' -f $Command.Source, $Command.Name)

            $Parameters = @{ }

            # Detect provider parameters, i.e. Get-ChildItem.
            $NoProviderParameters = -not $SkipProviderParameters
            # Assume only the core commands have dynamic provider parameters.
            if (-not $SkipProviderParameters -and $Command.Source -eq 'Microsoft.PowerShell.Management') {
                # Only validate commands that has a parameter which could accept a string path.
                foreach ($Param in $Command.Parameters.Values) {
                    if (([String[]], [String] -contains $Param.ParameterType) -and ($Param.ParameterSets.Values | Where-Object { $_.Position -ge 0 })) {
                        $NoProviderParameters = $false
                        break
                    }
                }
            }

            if ($NoProviderParameters) {
                if ($Command.Parameters) {
                    Add-Parameter -OutputParameter $Parameters -InputParameter $Command.Parameters.Values
                }
            }
            else {
                foreach ($Provider in @(Get-PSProvider)) {
                    if ($Provider.Drives.Length -gt 0) {
                        $Drive = Get-Location -PSProvider $Provider.Name
                    }
                    else {
                        $Drive = '{0}\ {1}::\' -f $Provider.ModuleName, $Provider.Name
                    }
                    Write-Verbose ("Get-Command $Command -Args $Drive | Select-Object -Expand Parameters")

                    try {
                        $MoreParameters = (Get-Command $Command -Args $Drive -ErrorAction Stop).Parameters.Values
                    }
                    catch {
                        Write-Verbose -Message ('No provider parameters was found for "{0}" and PSProvider "{1}"' -f $Command, $Provider.Name)
                    }

                    if ($MoreParameters.Length -gt 0) {
                        Add-Parameter -OutputParameter $Parameters -InputParameter $MoreParameters
                    }
                }

                # If for some reason none of the drive paths worked, just use the default parameters
                if ($Parameters.Length -eq 0) {
                    if ($Command.Parameters) {
                        Add-Parameter -OutputParameter $Parameters -InputParameter $Command.Parameters.Values
                    }
                }
            }

            # Calculate the shortest distinct parameter name (alias) - Do this BEFORE removing the common parameters or anything else.
            $Aliases = $Parameters.Values | Select-Object -ExpandProperty Aliases  ## Get defined aliases
            $ParameterNames = $Parameters.Keys + $Aliases
            foreach ($ParameterNameKey in $($Parameters.Keys)) {
                $Aliases = @($ParameterNameKey) + @($Parameters.$ParameterNameKey.Aliases) | Sort-Object { $_.Length }
                $Shortest = '^{0}' -f @($Aliases)[0]

                foreach ($Alias in $Aliases) {
                    $Short = '^'
                    foreach ($Char in [char[]]$Alias) {
                        $Short += $Char
                        $MinimumCharCount = ($ParameterNames -match $Short).Count
                        if ($MinimumCharCount -eq 1 ) {
                            if ($Short.Length -lt $Shortest.Length) {
                                $Shortest = $Short
                            }
                            break
                        }
                    }
                }
                if ($Shortest.Length -lt @($Aliases)[0].Length + 1) {
                    # Overwrite the Aliases with this new value
                    $Parameters.$ParameterNameKey = $Parameters.$ParameterNameKey | Add-Member NoteProperty Aliases ($Parameters.$ParameterNameKey.Aliases + @("$($Shortest.SubString(1))*")) -Force -Passthru
                }
            }

            # Write-Verbose 'Parameters: $($Parameters.Count)`n $($Parameters | Format-Table | Out-String)'
            $CommonParameters = [string[]][System.Management.Automation.Cmdlet]::CommonParameters

            foreach ($ParamSet in @($Command.ParameterSets.Name)) {
                $ParamSet = $ParamSet | Add-Member -Name IsDefault -MemberType NoteProperty -Value ($ParamSet -eq $Command.DefaultParameterSet) -PassThru
                foreach ($Parameter in $Parameters.Keys | Sort-Object) {

                    # Write-Verbose "Parameter: $Parameter"
                    if (-not $Force -and ($CommonParameters -contains $Parameter)) {
                        continue
                    }
                    if ($Parameters.$Parameter.ParameterSets.ContainsKey($ParamSet) -or $Parameters.$Parameter.ParameterSets.ContainsKey('__AllParameterSets')) {
                        if ($Parameters.$Parameter.ParameterSets.ContainsKey($ParamSet)) {
                            $Output = Join-ParameterObject -ParameterMetadata $Parameters.$Parameter -ParameterSetData $Parameters.$Parameter.ParameterSets.$ParamSet
                        }
                        else {
                            $Output = Join-ParameterObject -ParameterMetadata $Parameters.$Parameter -ParameterSetData $Parameters.$Parameter.ParameterSets.__AllParameterSets
                        }

                        #Write-Output $Output | Select-Object $PropertySet | ForEach-Object {
                        #$null = $_.PSTypeNames.Insert(0, 'System.Management.Automation.ParameterMetadataEx')
                        # Write-Verbose "$(($_.PSTypeNames.GetEnumerator()) -join ", ")"
                        #$_
                        #} |
                        #Add-Member ScriptMethod ToString { $this.Name } -Force -Passthru |
                        $Output |
                            Where-Object { $(foreach ($pn in $ParameterName) { $_ -like $Pn }) -contains $true } |
                            Where-Object { $(foreach ($sn in $SetName) { $_.ParameterSet -like $sn }) -contains $true }

                    }
                }
            }
        }
    }
}
