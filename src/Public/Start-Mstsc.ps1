function Start-Mstsc {
    <#
    .SYNOPSIS
    The ConvertTo-TitleCase function converts a specified string to title case.

    .DESCRIPTION
    The ConvertTo-TitleCase function converts a specified string to title case using the Method in (Get-Culture).TextInfo
    All input strings will be converted to lowercase, because uppercase are considered to be acronyms.

    .EXAMPLE
    ConvertTo-TitleCase -InputObject 'roger johnsson'
    Roger Johnsson

    This example returns the string 'Roger Johnsson' which has capitalized the R and J chars.

    .EXAMPLE
    'roger johnsson', 'JOHN ROGERSSON' | ConvertTo-TitleCase
    Roger Johnsson
    John Rogersson

    This example returns the strings 'Roger Johnsson' and 'John Rogersson' which has capitalized the R and J chars.

    .LINK
        https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Start-Mstsc.md
    #>
    [Alias('remote')]
    [CmdletBinding(
        SupportsShouldProcess,
        PositionalBinding,
        DefaultParameterSetName = 'Default'
    )]
    param(
        # Specifies the remote PC to which you want to connect.
        [Parameter(
            Position = 1,
            HelpMessage = 'Enter a Computer name',
            Mandatory
        )]
        [string]$ComputerName,

        # Connects you to the console session for administering a remote PC.
        [Parameter(
            Position = 2
        )]
        [Alias('Console')]
        [switch]$Admin,

        # Specifies the port of the remote PC to which you want to connect. Default value is 3389.
        [Parameter(
            Position = 3
        )]
        [ValidateRange(1, 65535)]
        [ValidateNotNullOrEmpty()]
        [int]$Port = 3389,

        # Specifies the width of the Remote Desktop window.
        [Parameter(
            Position = 4,
            ParameterSetName = 'FixedSize',
            Mandatory
        )]
        [Alias('w')]
        [int]$Width,

        # Specifies the height of the Remote Desktop window.
        [Parameter(
            Position = 5,
            ParameterSetName = 'FixedSize',
            Mandatory
        )]
        [Alias('h')]
        [int]$Height,

        <#
        Matches the remote desktop width and height with the local virtual desktop, spanning across multiple monitors, if necessary.
        To span across monitors, the monitors must be arranged to form a rectangle.
        #>
        [Parameter(
            Position = 6,
            ParameterSetName = 'Span'
        )]
        [switch]$Span,

        # Configures the Remote Desktop Services session monitor layout to be identical to the current client-side configuration.
        [Parameter(
            Position = 7,
            ParameterSetName = 'Multimon'
        )]
        [Alias('multimon')]
        [switch]$MultiMonitor,

        # Prompts you for your credentials when you connect to the remote PC.
        [Parameter(
            Position = 8
        )]
        [switch]$Prompt,

        # Runs Remote Desktop in public mode.
        [Parameter(
            Position = 9
        )]
        [switch]$Public,

        <#
        Connects you to the remote PC in Restricted Administration mode.
        In this mode, credentials won't be sent to the remote PC, which can protect you if you connect to a PC that has been compromised.
        However, connections made from the remote PC might not be authenticated by other PCs, which might impact application functionality and compatibility.
        This parameter implies the admin parameter.
        #>
        [Parameter(
            Position = 10
        )]
        [switch]$RestrictedAdmin,

        <#
        Connects your device to a remote device using Remote Guard.
        Remote Guard prevents credentials from being sent to the remote PC, which can help protect your credentials if you connect to a remote PC that has been compromised.
        Unlike Restricted Administration mode, Remote Guard also supports connections made from the remote PC by redirecting all requests back to your device.
        #>
        [Parameter(
            Position = 11
        )]
        [switch]$RemoteGuard

    )
    begin {
        if (Get-Variable IsWindows -ErrorAction SilentlyContinue) {
            if (-not $IsWindows) {
                throw [System.NotSupportedException]::New('Start-Mstsc is only supported on Windows operating systems.')
            }
        }
        else {
            Write-Verbose -Message 'Running Start-Mstsc as Windows PowerShell.'
        }
    }
    process {
        $RDTable = @{
            'ComputerName'    = ('/v:{0}:{1}' -f $ComputerName, $Port)
            'Admin'           = '/admin'
            'Width'           = ('/w:{0}' -f $Width)
            'Height'          = ('/h:{0}' -f $Height)
            'Span'            = '/span'
            'MultiMonitor'    = '/multimon'
            'Prompt'          = '/prompt'
            'Public'          = '/Public'
            'RestrictedAdmin' = '/restrictedAdmin'
            'RemoteGuard'     = '/remoteGuard'
        }

        [Text.StringBuilder]$RDString = [Text.StringBuilder]::new()
        $null = $RDString.Append("$env:windir\system32\mstsc.exe /f ")
        foreach ($Key in $PSBoundParameters.Keys) {
            $null = $RDString.Append($RDTable[$Key])
            $null = $RDString.Append(' ')
        }

        if ($PSCmdlet.ShouldProcess($ComputerName)) {
            try {
                & ($RDString.ToString().Trim())
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
}
