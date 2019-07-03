function Write-Log {
    <#
        .SYNOPSIS
            Used to create and output information from functions

        .DESCRIPTION
           This function will write to a log file and output the same result to the pipeline.
    #>

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Enter a message.',
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('LogContent')]
        [string]$Message,

        [Alias('LogPath')]
        [string]$Path = "$env:SystemDrive\Logs\PowerShellLog.log",

        [ValidateSet('Error', 'Warning', 'Info')]
        [string]$Level = 'Info',

        [switch]$NoClobber
    )

    begin {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    process {

        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path -Path $Path) -and $NoClobber) {
            Write-Error -Message ('Log file {0} already exists, and you specified NoClobber. Either delete the file or specify a different name.' -f $Path)
            return
        }

        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        elseif (-not (Test-Path -Path $Path)) {
            Write-Verbose -Message ('Creating {0}.' -f $Path)
            $null = New-Item -Path $Path -Force -ItemType File
        }

        # Format Date for our Log File
        $FormattedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                Write-Verbose -Message $Message
                $LevelText = 'ERROR:'
            }
            'Warning' {
                Write-Verbose -Message $Message
                $LevelText = 'WARNING:'
            }
            'Info' {
                Write-Verbose -Message $Message
                $LevelText = 'INFO:'
            }
        }

        # Write log entry to $Path
        ('{0} {1} {2}' -f $FormattedDate, $LevelText, $Message) | Out-File -FilePath $Path -Append
    }
}