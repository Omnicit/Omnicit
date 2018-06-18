function Invoke-ModuleUpdate {
    <#
    .SYNOPSIS
    Update one, several or all installed modules if an update is available from a repository location.

    .DESCRIPTION
    Invoke-ModuleUpdate for installed modules that have a repository location, for example from PowerShell Gallery.
    The function, without the Update parameter, returns the current and the latest version available for each installed module with a repository location.
    If there is any existing installed versions for each module that current version number will be displayed under Multiple versions.
    When the Update parameter is issued the function will update the named modules.

    The script is based on the "Check-ModuleUpdate.ps1" from Jeffery Hicks* to check for available updates for installed PowerShell modules.
    *Credit: http://jdhitsolutions.com/blog/powershell/5441/check-for-module-updates/

    .PARAMETER Name
    Specifies names or name patterns of modules that this function gets. Wildcard characters are permitted.

    .PARAMETER Update
    Switch parameter to invoke the 'Update-Module' cmdlet for the targeted modules. The default behavior without this switch is that the function will only list the current and available versions.

    .PARAMETER Force
    Switch parameter forces the update of each specified module, regardless of the current version of the module installed. Using the 'Force' parameter without using 'Update' parameter does not perform anything extra.

    .EXAMPLE
    Invoke-ModuleUpdate

    Name                                             Current Version  Online Version   Multiple Versions
    ----                                             ---------------  --------------   -----------------
    SpeculationControl                               1.0.0            1.0.8            False
    AzureAD                                          2.0.0.131        2.0.1.10         {2.0.0.115}
    AzureADPreview                                   2.0.0.154        2.0.1.11         {2.0.0.137}
    ISESteroids                                      2.7.1.7          2.7.1.7          {2.6.3.30}
    MicrosoftTeams                                   0.9.1            0.9.3            False
    NTFSSecurity                                     4.2.3            4.2.3            False
    Office365Connect                                 1.5.0            1.5.0            False
    ...                                              ...              ...              ...

    This example returns the current and the latest version available for all installed modules that have a repository location.

    .EXAMPLE
    Invoke-ModuleUpdate -Update

    Name                                             Current Version  Online Version   Multiple Versions
    ----                                             ---------------  --------------   -----------------
    SpeculationControl                               1.0.8            1.0.8            {1.0.0}
    AzureAD                                          2.0.1.10         2.0.1.10         {2.0.0.131, 2.0.0.115}
    AzureADPreview                                   2.0.1.11         2.0.1.11         {2.0.0.137, 2.0.0.154}
    ISESteroids                                      2.7.1.7          2.7.1.7          {2.6.3.30}
    MicrosoftTeams                                   0.9.3            0.9.3            {0.9.1}
    NTFSSecurity                                     4.2.3            4.2.3            False
    Office365Connect                                 1.5.0            1.5.0            False
    ...                                              ...              ...              ...

    This example installs the latest version available for all installed modules that have a repository location.

    .EXAMPLE
    Invoke-ModuleUpdate -Name 'AzureAD', 'PSScriptAnalyzer' -Update -Force

    Name                                             Current Version  Online Version   Multiple Versions
    ----                                             ---------------  --------------   -----------------
    AzureAD                                          2.0.1.10         2.0.1.10         {2.0.0.131, 2.0.0.115}
    PSScriptAnalyzer                                 1.17.1           1.17.1           {1.17.0}

    This example will force install the latest version available for the AzureAD and PSScriptAnalyzer modules.

    .NOTES
    Created by:     Philip Haglund
    Organization:   Omnicit AB
    Filename:       Invoke-ModuleUpdate.ps1
    Version:        0.1.0
    Requirements:   Powershell 4.0
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'NoUpdate',
        SupportsShouldProcess = $true,
        HelpUri = 'https://github.com/Omnicit/Omnicit'
    )]
    param (
        # Specifies names or name patterns of modules that this cmdlet gets. Wildcard characters are permitted.
        [Parameter(
            ParameterSetName = 'NoUpdate',
            ValueFromPipeline = $true,
            Position = 0
        )]
        [Parameter(
            ParameterSetName = 'Update',
            ValueFromPipeline = $true,
            Position = 0
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]$Name = '*',

        # Switch parameter to invoke the 'Update-Module' cmdlet for the targeted modules. The default behavior without this switch is that the function will only list the current and available versions.
        [Parameter(
            ParameterSetName = 'Update',
            Position = 1
        )]
        [switch]$Update,

        # Switch parameter forces the update of each specified module, regardless of the current version of the module installed. Using the 'Force' parameter without using 'Update' parameter does not perform anything extra.
        [Parameter(
            ParameterSetName = 'Update',
            Position = 2
        )]
        [switch]$Force
    )

    begin {
        if ((-not $PSBoundParameters.ContainsKey('Update')) -and $PSBoundParameters.ContainsKey('Force')) {
            Write-Verbose -Message 'Using the "Force" parameter without using "Update" parameter does not perform anything extra.'
        }

        try {
            [array]$Modules = (Get-Module -Name $Name -ListAvailable -ErrorAction Stop -Verbose:$false).Where{$null -ne $_.RepositorySourceLocation}

            # Sort the modules using the Length of the 'Name' property (pipeline with PSCustomObject uses the default 8 char length and trims output with dots.)
            # Group all modules to exclude multiple versions.
            [array]$Modules = $Modules | Group-Object -Property Name
            [int]$TotalCount = $Modules.Count

            switch ($Update) {
                $true {
                    [string]$Status = 'Updating module'
                }
                Default {
                    [string]$Status = 'Looking for the latest version for module'
                }
            }
        }
        catch {
            [Exception]$Ex = New-Object -TypeName System.Exception -ArgumentList (' {0} {1}' -f 'Unable to get module information. Error: ', $_.Exception.Message)
            [Management.Automation.ErrorCategory]$Category = [Management.Automation.ErrorCategory]::InvalidResult
            [Management.Automation.ErrorRecord]$ErrRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $Ex, 'ModuleError', $Category, $_.InvocationInfo
            $PSCmdLet.WriteError($ErrRecord)
            break
        }
        <#try {
            Update-FormatData -PrependPath $PSScriptRoot\Invoke-ModuleUpdate.format.ps1xml -ErrorAction Stop
            $FormatData = $true
        }
        catch {
            $FormatData = $false
            Write-Warning -Message ('Unable to Update-FormatData. Error {0}' -f $_.Exception.Message)
            Write-Verbose -Message 'Output format may not be correct displayed.'
        }#>

        try {
            # To speed up the 'Find-Module' cmdlet and not query all existing repositories, save all existing repositories.
            [PSCustomObject]$Repositories = Get-PSRepository -ErrorAction Stop

            if ($PSCmdLet.ParameterSetName -eq 'Update' -and $Repositories.InstallationPolicy -contains 'Untrusted' -and $TotalCount -gt 1) {
                Write-Verbose -Message 'One or more repositories have the InstallationPolicy set to Untrusted.'
                Write-Verbose -Message 'The function will temporary set all repositories to Trusted to avoid continues prompts of "Set-PSRepository" and revert back after finished updating.'
                $RepoChanged = $true
                foreach ($Repository in $Repositories) {
                    Set-PSRepository -Name $Repository.Name -InstallationPolicy Trusted -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Verbose:$false
                }
            }
        }
        catch {
            [Exception]$Ex = New-Object -TypeName System.Exception -ArgumentList (' {0} {1}' -f 'Unable to get repository information. Error: ', $_.Exception.Message)
            [Management.Automation.ErrorCategory]$Category = [Management.Automation.ErrorCategory]::InvalidResult
            [Management.Automation.ErrorRecord]$ErrRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $Ex, 'ModuleError', $Category, $_.InvocationInfo
            $PSCmdLet.WriteError($ErrRecord)
            break
        }

    }
    process {
        foreach ($Group in $Modules) {
            [int]$PercentComplete = ' {0:N0}' -f (($Modules.IndexOf($Group) / $TotalCount) * 100)
            Write-Progress -Activity (' {0} {1}' -f $Status, $Group.Group[0].Name) -Status (' {0}% Complete:' -f $PercentComplete) -PercentComplete $PercentComplete

            if ($PSCmdlet.ShouldProcess((' {0}' -f $Group.Group[0].Name), $MyInvocation.MyCommand.Name)) {
                $MultipleVersions = @()
                switch ($Group.Count) {
                    ( {$PSITem -gt 1}) {
                        [string[]]$MultipleVersions = $Group.Group.Version[1..($Group.Group.Version.Length)]
                        [psmoduleinfo]$Module = (($Group).Group | Sort-Object -Property Version -Descending)[0]
                    }
                    Default {
                        $MultipleVersions = $null
                        [psmoduleinfo]$Module = $Group.Group[0]
                    }
                }
                try {
                    if ($Repository = ($Repositories.Where{[string]$_.SourceLocation -eq [string]$Module.RepositorySourceLocation}).Name) {
                        $FindModule = @{
                            Repository  = $Repository
                            ErrorAction = 'Stop'
                        }
                    }
                    else {
                        $FindModule = @{
                            ErrorAction = 'Stop'
                        }
                    }
                    [PSCustomObject]$Online = Find-Module -Name $Module.Name @FindModule
                }
                catch {
                    Write-Warning -Message ('Unable to find module {0}. Error: {1}' -f $Module.Name, $_.Exception.Message)
                    continue
                }

                [version]$CurrentVersion = $Module.Version
                if ($PSBoundParameters.ContainsKey('Update')) {
                    if ([version]$Online.Version -gt [version]$Module.Version) {
                        try {
                            Update-Module -Name $Module.Name -Force:$PSBoundParameters['Force'] -ErrorAction Stop
                            [version]$CurrentVersion = $Online.Version
                            $MultipleVersions += $Module.Version
                        }
                        catch {
                            Write-Warning -Message ('Unable to update module. Error: {0}' -f $_.Exception.Message)
                            [version]$CurrentVersion = $Module.Version
                        }
                    }
                    else {
                        [version]$CurrentVersion = $Online.Version
                    }
                }

                $PSObject = [PSCustomObject]@{
                    'Name'              = [string]$Module.Name
                    'Current Version'   = $CurrentVersion
                    'Online Version'    = $Online.Version
                    'Multiple Versions' = $MultipleVersions
                }

                #if ($FormatData) {
                    $PSObject.PSObject.TypeNames.Insert(0, 'Omnicit.Invoke.ModuleUpdate')
                #}

                $PSObject
            }
        }
    }
    end {
        try {
            if ($RepoChanged) {
                Write-Verbose -Message 'Reverting back installation policies for repositories.'
                foreach ($Repository in $Repositories) {
                    Set-PSRepository -Name $Repository.Name -InstallationPolicy $Repository.InstallationPolicy -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Verbose:$false
                }
            }
        }
        catch {
            [Exception]$Ex = New-Object -TypeName System.Exception -ArgumentList (' {0} {1}' -f 'Unable to get repository information. Error: ', $_.Exception.Message)
            [Management.Automation.ErrorCategory]$Category = [Management.Automation.ErrorCategory]::InvalidResult
            [Management.Automation.ErrorRecord]$ErrRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $Ex, 'ModuleError', $Category, $_.InvocationInfo
            $PSCmdLet.WriteError($ErrRecord)
            break
        }
    }
}