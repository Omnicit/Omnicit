function Start-Mstsc {
    <#
    .SYNOPSIS
    Start a Mstsc process using predefined arguments from parameters.

    .DESCRIPTION
    The Start-Mstsc function starts a mstsc.exe process with arguments defined from the parameters.
    Built in check to validate that the current system is Windows.
    Shadow parameters are not yet implemented.
    Default port is defined as 3389.

    .EXAMPLE
    Start-Mstsc -ComputerName Server01
    Starts mstsc.exe with the arguments /v:Server01:3389

    Connects to Server01 using the default RDP port 3389.
    .EXAMPLE
    Start-Mstsc -ComputerName Server01 -Admin
    Starts mstsc.exe with the arguments /v:Server01:3389 /admin

    Connects to the console on Server01 using the default RDP port 3389.
    .EXAMPLE
    Start-Mstsc -ComputerName Server01 -Admin -Port 9876
    Starts mstsc.exe with the arguments /v:Server01:9876 /admin

    Connects to the console on Server01 using port 9876.
    .EXAMPLE
    Start-Mstsc -ComputerName Server01 -Admin -Port 9876 -FullScreen
    Starts mstsc.exe with the arguments /v:Server01:9876 /admin /f

    Connects to the console on Server01 using port 9876 with full-screen.
    .EXAMPLE
    Start-Mstsc -ComputerName Server01 -Admin -Port 9876 -FullScreen -Prompt
    Starts mstsc.exe with the arguments /v:Server01:9876 /admin /f /prompt

    Connects to the console on Server01 using port 9876 with full-screen and prompt for credentials.
    .EXAMPLE
    Start-Mstsc -ComputerName Server01 -Admin -Port 9876 -FullScreen -Prompt -Public
    Starts mstsc.exe with the arguments /v:Server01:9876 /admin /f /prompt /public

    Connects to the console on Server01 using port 9876 with full-screen, prompt for credentials and run RDP in public mode.
    .EXAMPLE
    Start-Mstsc -ComputerName Server01 -RestrictedAdmin
    Starts mstsc.exe with the arguments /v:Server01:3389 /restrictedAdmin

    Connects to Server01 using the default RDP port 3389 with Restricted Admin.
    .EXAMPLE
    Start-Mstsc -ComputerName Server01 -RemoteGuard
    Starts mstsc.exe with the arguments /v:Server01:3389 /remoteGuard

    Connects to Server01 using the default RDP port 3389 with Remote Guard.
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
        # Specifies the remote PC or Server to which you want to connect.
        [Parameter(
            Position = 1,
            HelpMessage = 'Specify the remote PC or Server to which you want to connect',
            Mandatory
        )]
        [Alias('Server', 'IPAddress', 'Target', 'Node', 'Client')]
        [string[]]$ComputerName,

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

        # Starts Remote Desktop in full-screen mode.
        [Parameter(
            ParameterSetName = 'FullScreen'
        )]
        [switch]$FullScreen,

        # Specifies the width of the Remote Desktop window.
        [Parameter(
            ParameterSetName = 'FixedSize',
            Mandatory
        )]
        [Alias('w')]
        [ValidateRange(1, 10000)]
        [int]$Width,

        # Specifies the height of the Remote Desktop window.
        [Parameter(
            ParameterSetName = 'FixedSize',
            Mandatory
        )]
        [Alias('h')]
        [ValidateRange(1, 10000)]
        [int]$Height,

        <#
        Matches the remote desktop width and height with the local virtual desktop, spanning across multiple monitors, if necessary.
        To span across monitors, the monitors must be arranged to form a rectangle.
        #>
        [Parameter(
            ParameterSetName = 'Span'
        )]
        [switch]$Span,

        # Configures the Remote Desktop Services session monitor layout to be identical to the current client-side configuration.
        [Parameter(
            ParameterSetName = 'MultiMonitor'
        )]
        [Alias('multimon')]
        [switch]$MultiMonitor,

        # Prompts you for your credentials when you connect to the remote PC.
        [switch]$Prompt,

        # Runs Remote Desktop in public mode.
        [switch]$Public,

        <#
        Connects you to the remote PC in Restricted Administration mode.
        In this mode, credentials won't be sent to the remote PC, which can protect you if you connect to a PC that has been compromised.
        However, connections made from the remote PC might not be authenticated by other PCs, which might impact application functionality and compatibility.
        This parameter implies the admin parameter.
        #>
        [Parameter(
            ParameterSetName = 'RestrictedAdmin'
        )]
        [switch]$RestrictedAdmin,

        <#
        Connects your device to a remote device using Remote Guard.
        Remote Guard prevents credentials from being sent to the remote PC, which can help protect your credentials if you connect to a remote PC that has been compromised.
        Unlike Restricted Administration mode, Remote Guard also supports connections made from the remote PC by redirecting all requests back to your device.
        #>
        [Parameter(
            ParameterSetName = 'RemoteGuard'
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
        $RDTable = @{
            'Admin'           = '/admin'
            'Width'           = ('/w:{0}' -f $Width)
            'Height'          = ('/h:{0}' -f $Height)
            'FullScreen'      = '/f'
            'Span'            = '/span'
            'MultiMonitor'    = '/multimon'
            'Prompt'          = '/prompt'
            'Public'          = '/public'
            'RestrictedAdmin' = '/restrictedAdmin'
            'RemoteGuard'     = '/remoteGuard'
        }
    }
    process {
        foreach ($Computer in $ComputerName) {
            try {
                $RDTable.Add('ComputerName', ('/v:{0}:{1}' -f $Computer, $Port))
                [Text.StringBuilder]$RDString = [Text.StringBuilder]::new()

                foreach ($Key in $PSBoundParameters.Keys) {
                    if ($RDTable[$Key]) {
                        $null = $RDString.Append($RDTable[$Key])
                        $null = $RDString.Append(' ')
                    }
                }
                $RDTable.Remove('ComputerName')
                $RDArgument = $RDString.ToString().Trim()
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
            if ($PSCmdlet.ShouldProcess($RDArgument)) {
                try {
                    Write-Verbose -Message ('Starting mstsc with the following arguments: {0}' -f ($RDArgument))
                    Start-Process -FilePath "$env:windir\system32\mstsc.exe" -ArgumentList ($RDArgument)
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }
}