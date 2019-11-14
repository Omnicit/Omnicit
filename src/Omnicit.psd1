﻿#
# Module manifest for module 'Omnicit'
#
# Generated by: Omnicit
#
# Generated on: 2018-06-18
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'Omnicit.psm1'

    # Version number of this module.
    ModuleVersion        = '0.1.4'

    # Supported PSEditions
    CompatiblePSEditions = 'Desktop', 'Core'

    # ID used to uniquely identify this module
    GUID                 = 'ac164fd4-5867-4b95-a13a-67efcff66f12'

    # Author of this module
    Author               = 'Omnicit'

    # Company or vendor of this module
    CompanyName          = 'Omnicit AB'

    # Copyright statement for this module
    Copyright            = '(c) 2018 Omnicit AB. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'Omnicit PowerShell Toolbox - OPT'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess     = @('Omnicit.format.ps1xml')

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @()

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @('ClipboardArray')

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @('gca', 'cop', 'Get-ExternalIP', 'gwan', 'remote')

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('PSEdition_Desktop', 'PSEdition_Core', 'Toolbox', 'Office365', 'ActiveDirectory', 'String', 'Data', 'Credential')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/Omnicit/Omnicit/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/Omnicit/Omnicit'

            # A URL to an icon representing this module.
            IconUri      = 'https://raw.githubusercontent.com/Omnicit/Omnicit/master/Omnicit_Icon.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/Omnicit/Omnicit/blob/master/ReleaseNotes.md'

            # Indicates this is a pre-release/testing version of the module.
            # PreRelease = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI          = 'https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Omnicit.md'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}