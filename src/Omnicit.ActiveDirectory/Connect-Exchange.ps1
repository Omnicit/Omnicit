# Todo:
# 1. Add help!
# 2. Add parameter to connect to specific server.

function Connect-Exchange {
    [OutputType([System.String], [System.Boolean])]
    [CmdletBinding()]
    param ()

    $Session = Get-PSSession | Where-Object -FilterScript {
        $_.ConfigurationName -like 'Microsoft.Exchange'
    }
    $ExCmdlet = Get-Command 'Enable-Mailbox' -ErrorAction SilentlyContinue

    if ($ExCmdlet) {
        $Session.ComputerName
        return
    }

    $ConfigNC = ([ADSI]'LDAP://RootDse').configurationNamingContext
    $Search = New-Object -TypeName DirectoryServices.DirectorySearcher -ArgumentList ([ADSI]"LDAP://$ConfigNC")
    $Objectclass = 'objectClass=msExchExchangeServer'
    $Objectclass2 = '!(objectClass=msExchExchangeTransportServer)'
    $Version = 'versionNumber>=1937801568'

    $Search.Filter = "(&($Objectclass)($Version)($Objectclass2))"
    $Search.PageSize = 1000
    $null = $Search.PropertiesToLoad.Add('name')
    $null = $Search.PropertiesToLoad.Add('msexchcurrentserverroles')
    $null = $Search.PropertiesToLoad.Add('networkaddress')
    $null = $Search.PropertiesToLoad.Add('serialNumber')

    $ExchangeServers = $Search.FindAll()
    

    $ExRoles = @"
        Number,RoleName
        2,MBX
        4,CAS
        6,CAS-MBX
        16,UMR
        18,UMR-MBX
        20,UMR-CAS
        22,UMR-CAS-MBX
        32,HUB
        36,HUB-CAS
        38,HUB-MBX-CAS
        48,HUB-UMR
        54,HUB-UMR-CAS-MBX
        64,EDGE
        16385,CAS
        16439,HUB-UMR-CAS-MBX
"@ | ConvertFrom-Csv
    
    $ExInformation = @()

    foreach ($Prop in $ExchangeServers) {
        $P = [pscustomobject]$Prop.Properties

        $Fqdn = ($P.networkaddress -match 'ncacn_ip_tcp' -replace '.*:')[0]
        $Role = $P.msexchcurrentserverroles[0]
        $ExInformation += [pscustomobject]@{
            Name    = $P.name[0]
            FQDN    = $Fqdn
            Role    = $Role
            Roles   = ($ExRoles | Where-Object -FilterScript {
                    $_.Number -eq $Role
                }).RoleName
            Version = $P.serialnumber[0]
        }            
    }
    
    $ConnectServer = $ExInformation | Where-Object -FilterScript {
        $_.Roles -match 'CAS'
    }

    

    if ($null -ne $Session) {
        if ($null -eq $ExCmdlet) {
            Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking) -Global -DisableNameChecking
            if ($null -eq $ExCmdlet) {
                $false
            }
            else {
                $Session.ComputerName
            }
        }
    }
    else {
        if ($ConnectServer.Length -gt 1) {
            $ConnectServer = $ConnectServer | Sort-Object -Property Role -Descending
            try {
                $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$($ConnectServer[0].fqdn)/PowerShell/" -Authentication Kerberos -ErrorAction Stop
                if ($PSBoundParameters.ContainsKey('Verbose')) {
                    $ConnectServer[0] | Select-Object -Property FQDN, Roles, Version
                }
            }
            catch {
                $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$($ConnectServer[1].fqdn)/PowerShell/" -Authentication Kerberos
                if ($PSBoundParameters.ContainsKey('Verbose')) {
                    $ConnectServer[1] | Select-Object -Property FQDN, Roles, Version
                }
            }
        }
        else {
            $testcon = Test-Connection -ComputerName ($ConnectServer.fqdn) -Count 1 -ErrorAction SilentlyContinue

            if ($null -ne $testcon) {
                Write-Verbose -Message "Connecting to $($ConnectServer.fqdn)"
                try {
                    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$($ConnectServer.fqdn)/PowerShell/" -Authentication Kerberos
                    if ($PSBoundParameters.ContainsKey('Verbose')) {
                        $ConnectServer | Select-Object -Property FQDN, Roles, Version
                    }
                }
                catch {
                    continue
                }
            }
            else {
                Write-Verbose "Unable to connect to Exchange Server $($ConnectServer.fqdn)"
            }
        }
        $Session = Get-PSSession | Where-Object -FilterScript {
            $_.ConfigurationName -like 'Microsoft.Exchange'
        }

        Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking) -Global -DisableNameChecking
        $ExCmdlet = Get-Command 'Enable-Mailbox' -ErrorAction SilentlyContinue

        if ($null -eq $ExCmdlet) {
            Write-Output 'Loading Exchange PSSession again...'
            Start-Sleep -Seconds 3
            Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking) -Global -DisableNameChecking
            if ($null -eq $ExCmdlet) {
                $false
            }
            else {
                $Session.ComputerName
            }
        }
        else {
            $Session.ComputerName
        }   
    }
}
