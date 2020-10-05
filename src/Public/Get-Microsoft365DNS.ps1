function Get-Microsoft365DNS {
    [CmdletBinding()]
    param (
        # Enter one or more domain names to get the result from.
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            Mandatory
        )]
        [string[]]$Domain,
        # Enter the Azure AD tenant name. This is required for DKIM validation. Example: contoso.onmicrosoft.com.
        [Parameter(
            Position = 1,
            Mandatory
        )]
        [ValidatePattern('[^\.]*\.onmicrosoft\.com')]
        [Alias('AzureTenantId')]
        [string]$AzureTenantName,

        # Enter a valid DNS Server to use for all DNS queries. Example: 1.1.1.1, one.one.one.one, 8.8.8.8 or dns.google.
        [string]$DNSQueryServer = '1.1.1.1',

        # Use this switch to login to Azure AD and Exchange Online to get the correct DNS Service records, DKIM Settings and more. Requires the modules AzureAD and ExchangeOnlineManagement.
        [switch]$VerifyAgainstAzure
    )
    begin {
        if ($VerifyAgainstAzure) {
            try {
                Import-Module -Name AzureAD, ExchangeOnlineManagement, DnsClient -ErrorAction Stop
                try {
                    $AzureAD = Get-AzureADCurrentSessionInfo -ErrorAction Stop
                    if ($AzureAD.TenantDomain -ne $AzureTenantName) {
                        throw ('Connected to the wrong Azure Tenant "{0}".' -f $AzureAD.TenantDomain)
                    }
                }
                catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] {
                    $AzureAD = Connect-AzureAD -TenantId $AzureTenantName
                }
                catch {
                    $null = Disconnect-AzureAD -ErrorAction Stop
                    $AzureAD = Connect-AzureAD -TenantId $AzureTenantName -ErrorAction Stop
                }

                try {
                    $null = Get-AcceptedDomain -Identity $AzureTenantName -ErrorAction Stop
                }
                catch {
                    $null = Connect-ExchangeOnline -UserPrincipalName $AzureAD.Account -ErrorAction Stop
                }
            }
            catch {
                $VerifyAgainstAzure = $false
                Write-Warning -Message ('Unable to the verify against Azure. Error: {0}' -f $_.Exception.Message)
            }
        }

        $MXSuffix = '.mail.protection.outlook.com'
        $EXOSPF = 'spf.protection.outlook.com'
        $AutoDiscoverTarget = 'autodiscover.outlook.com'
        $EnterpriseRegistrationTarget = 'enterpriseregistration.windows.net'
        $EnterpriseEnrollmentTarget = 'enterpriseenrollment.manage.microsoft.com'
        $TeamsFederationObj = 'TCP;100;1;5061;sipfed.online.lync.com'.Split(';')
        $TeamsSIPObj = 'TLS;100;1;443;sipdir.online.lync.com'.Split(';')
        $TeamsCNAME = 'sipdir.online.lync.com'
        $TeamsDiscover = 'webdir.online.lync.com'
        $DKIMSuffix = if ($AzureAD.TenantDomain) {
            ('._domainkey.{0}' -f $AzureAD.TenantDomain)
        }
        else {
            ('._domainkey.{0}' -f $AzureTenantName)
        }

        function ConvertFrom-SRVRecord {
            param (
                [Parameter(ValueFromPipeline)]
                [AllowNull()]
                [Microsoft.DnsClient.Commands.DnsRecord_SRV]$Record
            )
            process {
                if ($null -ne $Record) {
                    '{0};{1};{2};{3};{4}' -f $Record.Name, $Record.Priority, $Record.Weight, $Record.Port, $Record.Target
                }
            }
        }
    }
    process {
        foreach ($Dom in $Domain) {
            if ($PSBoundParameters.ContainsKey('VerifyAgainstAzure')) {
                $VerifyAgainstAzure = $true
            }
            if ($VerifyAgainstAzure) {
                try {
                    $AzureADDomain = Get-AzureADDomain -Name $Dom -ErrorAction Stop
                    $DomainServiceConfigurationRecord = Get-AzureADDomainServiceConfigurationRecord -Name $Dom -ErrorAction Stop
                }
                catch {
                    Write-Warning -Message ('Domain "{0}" not added to this Azure tenant "{1}".' -f $Dom, $AzureTenantName)
                    $DomainServiceConfigurationRecord = $null
                    $AzureADDomain = $null
                    $VerifyAgainstAzure = $false
                }
            }
            #region Autodiscover
            $AutodiscoverValid = $false
            $AutodiscoverDomain = ('autodiscover.{0}' -f $Dom)
            $AutodiscoverConfigurationRecord = ($DomainServiceConfigurationRecord.Where( { $_.Label -eq $AutodiscoverDomain -and $_.RecordType -match 'CNAME' })).CanonicalName

            $CurrentAutodiscoverTarget = (Resolve-DnsName -Name $AutodiscoverDomain -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -match 'A|AAAA|CNAME' })
            $CorrectAutodiscoverCNAME = if ($AutodiscoverConfigurationRecord) {
                $AutodiscoverConfigurationRecord
            }
            else {
                $AutoDiscoverTarget
            }

            $CurrentAutodiscover = '{0}={1}' -f $AutodiscoverDomain, $(if ($CurrentAutodiscoverTarget[0].NameHost) {
                    $CurrentAutodiscoverTarget[0].NameHost
                }
                else {
                    $CurrentAutodiscoverTarget[0].IPAddress
                } )
            $CorrectAutodiscover = '{0}={1}' -f $AutodiscoverDomain, $CorrectAutodiscoverCNAME

            if ($CurrentAutodiscover.Count -gt 1) {
                Write-Warning -Message ('More than one Autodiscover CNAME record exist for domain "{0}".' -f $Dom)
            }
            elseif ($CurrentAutodiscover -eq $CorrectAutodiscover) {
                $AutodiscoverValid = $true
            }
            else {
                Write-Verbose -Message ('No Autodiscover CNAME record exist for domain "{0}".' -f $Dom)
            }
            #endregion Autodiscover
            #region MX
            $MXValid = $false
            $MXServiceConfigurationRecord = ($DomainServiceConfigurationRecord.Where( { $_.Label -eq $Dom -and $_.RecordType -eq 'MX' -and $_.SupportedService -eq 'Email' })).MailExchange
            if (($Dom.Split('-')).Count -gt 1 ) {
                Write-Warning -Message ('Domain "{0}" contains hyphens witch is not recommended and will likely be classified with a higher SCL.' -f $Dom)
                Write-Verbose -Message 'When domain contains hyphens the MX Target may contain a random generated name MX token.'
            }
            $MX = (Resolve-DnsName -Name $Dom -Type MX -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -eq 'MX' })
            $CorrectMX = if ($MXServiceConfigurationRecord) {
                $MXServiceConfigurationRecord
            }
            else {
                '{0}{1}' -f $Dom.Replace('.', '-'), $MXSuffix
            }
            if ($MX.Count -gt 1 -and $MX.NameExchange -match $CorrectMX) {
                Write-Warning -Message ('More than one MX record exist for domain "{0}".' -f $Dom)
            }
            elseif ($MX.NameExchange -eq $CorrectMX) {
                $MXValid = $true
            }
            else {
                Write-Verbose -Message ('No Microsoft 365 MX record exist for domain "{0}".' -f $Dom)
            }
            #endregion MX
            #region DKIM
            if ($VerifyAgainstAzure) {
                try {
                    $DKIM = Get-DkimSigningConfig -Identity $Dom -ErrorAction Stop
                }
                catch {
                    $DKIM = $false
                    Write-Warning ('No DKIM Signing Config is configured for domain "{0}". Run "New-DkimSigningConfig -DomainName {0} -Enabled $true"')
                    Write-Verbose -Message ('Get-DkimSigningConfig: {0}' -f $_.Exception.Message)
                }
            }
            $DKIMValid = $false
            $DKIMDomain1 = 'selector1._domainkey.{0}' -f $Dom
            $DKIMDomain2 = 'selector2._domainkey.{0}' -f $Dom

            $CurrentDKIM1Target = (Resolve-DnsName -Name $DKIMDomain1 -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -match 'CNAME' })
            $CurrentDKIM2Target = (Resolve-DnsName -Name $DKIMDomain2 -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -match 'CNAME' })
            $CorrectDKIM1Target = if ($DKIM.Selector1CNAME) {
                $DKIM.Selector1CNAME
            }
            else {
                'selector1-{0}{1}' -f ($Dom.Replace('.', '-')), $DKIMSuffix
            }
            $CorrectDKIM2Target = if ($DKIM.Selector2CNAME) {
                $DKIM.Selector2CNAME
            }
            else {
                'selector2-{0}{1}' -f ($Dom.Replace('.', '-')), $DKIMSuffix
            }

            $CurrentDKIM1 = '{0}={1}' -f $DKIMDomain1, $CurrentDKIM1Target[0].NameHost
            $CurrentDKIM2 = '{0}={1}' -f $DKIMDomain2, $CurrentDKIM2Target[0].NameHost
            $CorrectDKIM1 = '{0}={1}' -f $DKIMDomain1, $CorrectDKIM1Target
            $CorrectDKIM2 = '{0}={1}' -f $DKIMDomain2, $CorrectDKIM2Target

            if ($CurrentDKIM1Target.Count -gt 1 -or $CurrentDKIM2Target.Count -gt 1) {
                Write-Warning -Message ('More than one DKIM CNAME record exist for domain "{0}".' -f $Dom)
            }
            elseif ($CurrentDKIM1 -eq $CorrectDKIM1 -and $CurrentDKIM2 -eq $CorrectDKIM2) {
                $DKIMValid = $true
            }
            else {
                Write-Verbose -Message ('No DKIM CNAME record exist for domain "{0}".' -f $Dom)
            }
            #endregion DKIM
            #region SPF
            $TopSPF = (Resolve-DnsName -Name $Dom -Type TXT -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Strings -like '*v=spf1*' })
            $SPFValid = $false

            $SPFServiceConfigurationRecord = ($DomainServiceConfigurationRecord.Where( { $_.Label -eq $Dom -and $_.RecordType -eq 'TXT' -and $_.SupportedService -eq 'Email' })).Text
            $CorrectSPF = if ($SPFServiceConfigurationRecord) {
                $SPFServiceConfigurationRecord -replace 'v=spf1|include:|-all|\s'
            }
            else {
                $EXOSPF
            }
            if ($TopSPF.Strings -like "*$CorrectSPF*") {
                $SPFValid = $true
                $SPFValue = $TopSPF.Strings
            }
            elseif ($null -eq $TopSPF.Strings) {
                $SPFValue = 'Not set'
            }
            else {
                $NestedSPF = [System.Collections.Generic.List[string]]::new([string[]](($TopSPF.Strings -split '\s').Where( { $_ -like 'include:*' }) -replace 'include:'))
                $Count = 0
                while ($NestedSPF[0].Length -gt 0 -and $SPFValid -eq $false) {
                    $SPFValue = 'v=spf1 include:spf.protection.outlook.com -all'
                    $SPF = (Resolve-DnsName -Name $NestedSPF[$Count] -Type TXT -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Strings -like '*v=spf1*' })
                    if ($SPF.Strings -like "*$CorrectSPF*") {
                        $SPFValid = $true
                        $SPFValue = $SPF.Strings
                    }
                    else {
                        $AddSubSPF = (($SPF.Strings -split '\s').Where( { $_ -like 'include:*' }) -replace 'include:')
                        if ($AddSubSPF[0].Length -gt 0) {
                            $AddSubSPF | ForEach-Object {
                                $null = $NestedSPF.Add($_)
                            }
                        }
                        $null = $NestedSPF.Remove($NestedSPF[$Count])
                    }
                }
            }
            #endregion SPF
            #region DMARC
            $DMARC = (Resolve-DnsName -Name ('_dmarc.{0}' -f $Dom) -Type TXT -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -eq 'TXT' }).Strings
            $DMARCValid = $false
            if ($DMARC -match '^(v\=DMARC1)(?:.*?)(p\=reject|quarantine|none)(.*)') {
                $DMARCValid = $true
            }
            else {
                Write-Verbose -Message ('No valid DMARC Record exist for domain: "{0}".' -f $Dom)
            }
            #endregion DMARC
            #region TeamsSRVFederation
            $TeamsSRVFederationValid = $false
            $TeamsSRVFederationConfigurationRecord = ($DomainServiceConfigurationRecord.Where( { $_.Label -like ('_sipfederationtls._tcp.{0}' -f $Dom) -and $_.RecordType -eq 'SRV' -and $_.SupportedService -eq 'OfficeCommunicationsOnline' }))

            $TeamsSRVFederation = [Microsoft.DnsClient.Commands.DnsRecord_SRV]::new()
            $TeamsSRVFederation.Name = if ($TeamsSRVFederationConfigurationRecord.Label) {
                $TeamsSRVFederationConfigurationRecord.Label
            }
            else {
                ('_sipfederationtls._tcp.{0}' -f $Dom)
            }
            $TeamsSRVFederation.Priority = if ($TeamsSRVFederationConfigurationRecord.Priority) {
                $TeamsSRVFederationConfigurationRecord.Priority
            }
            else {
                $TeamsFederationObj[1]
            }
            $TeamsSRVFederation.Weight = if ($TeamsSRVFederationConfigurationRecord.Weight) {
                $TeamsSRVFederationConfigurationRecord.Weight
            }
            else {
                $TeamsFederationObj[2]
            }
            $TeamsSRVFederation.Port = if ($TeamsSRVFederationConfigurationRecord.Port) {
                $TeamsSRVFederationConfigurationRecord.Port
            }
            else {
                $TeamsFederationObj[3]
            }
            $TeamsSRVFederation.Target = if ($TeamsSRVFederationConfigurationRecord.NameTarget) {
                $TeamsSRVFederationConfigurationRecord.NameTarget
            }
            else {
                $TeamsFederationObj[4]
            }
            $TeamsSRVFederation.Type = 'SRV'

            $CurrentSRVFederation = (Resolve-DnsName -Name ('_sipfederationtls._tcp.{0}' -f $Dom) -Type SRV -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -eq 'SRV' })

            if ($CurrentSRVFederation.Count -gt 1) {
                Write-Warning -Message ('More than one Teams SIP Federation SRV record exist for domain "{0}".' -f $Dom)
            }
            elseif (($CurrentSRVFederation[0] | ConvertFrom-SRVRecord) -eq ($TeamsSRVFederation | ConvertFrom-SRVRecord)) {
                $TeamsSRVFederationValid = $true
            }
            else {
                $CurrentSRVFederation = $null
                Write-Verbose -Message ('Microsoft 365 Teams SIP Federation record does not exist for domain "{0}".' -f $Dom)
            }
            #endregion TeamsSRVFederation
            #region TeamsSRVSip
            $TeamsSRVSIPValid = $false
            $TeamsSRVSIPConfigurationRecord = ($DomainServiceConfigurationRecord.Where( { $_.Label -like ('_sip._tls.{0}' -f $Dom) -and $_.RecordType -eq 'SRV' -and $_.SupportedService -eq 'OfficeCommunicationsOnline' }))

            $TeamsSRVSIP = [Microsoft.DnsClient.Commands.DnsRecord_SRV]::new()
            $TeamsSRVSIP.Name = if ($TeamsSRVSIPConfigurationRecord.Label) {
                $TeamsSRVSIPConfigurationRecord.Label
            }
            else {
                ('_sip._tls.{0}' -f $Dom)
            }
            $TeamsSRVSIP.Priority = if ($TeamsSRVSIPConfigurationRecord.Priority) {
                $TeamsSRVSIPConfigurationRecord.Priority
            }
            else {
                $TeamsSIPObj[1]
            }
            $TeamsSRVSIP.Weight = if ($TeamsSRVSIPConfigurationRecord.Weight) {
                $TeamsSRVSIPConfigurationRecord.Weight
            }
            else {
                $TeamsSIPObj[2]
            }
            $TeamsSRVSIP.Port = if ($TeamsSRVSIPConfigurationRecord.Port) {
                $TeamsSRVSIPConfigurationRecord.Port
            }
            else {
                $TeamsSIPObj[3]
            }
            $TeamsSRVSIP.Target = if ($TeamsSRVSIPConfigurationRecord.NameTarget) {
                $TeamsSRVSIPConfigurationRecord.NameTarget
            }
            else {
                $TeamsSIPObj[4]
            }
            $TeamsSRVSIP.Type = 'SRV'

            $CurrentTeamsSRVSIP = (Resolve-DnsName -Name ('_sip._tls.{0}' -f $Dom) -Type SRV -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -eq 'SRV' })

            if ($CurrentTeamsSRVSIP.Count -gt 1) {
                Write-Warning -Message ('More than one Teams SIP SRV record exist for domain "{0}".' -f $Dom)
            }
            elseif (($CurrentTeamsSRVSIP[0] | ConvertFrom-SRVRecord) -eq ($TeamsSRVSIP | ConvertFrom-SRVRecord)) {
                $TeamsSRVSIPValid = $true
            }
            else {
                $CurrentTeamsSRVSIP = $null
                Write-Verbose -Message ('Microsoft 365 Teams SIP SRV record does not exist for domain "{0}".' -f $Dom)
            }
            #endregion TeamsSRVSip
            #region TeamsSipCNAME
            $TeamsSIPCNAMEValid = $false
            $TeamsSIPCNAME = ('sip.{0}' -f $Dom)
            $TeamsSIPCNAMEConfigurationRecord = ($DomainServiceConfigurationRecord.Where( { $_.Label -eq $TeamsSIPCNAME -and $_.RecordType -eq 'CNAME' -and $_.SupportedService -eq 'OfficeCommunicationsOnline' }))

            $CurrentTeamsSIPCNAME = (Resolve-DnsName -Name $TeamsSIPCNAME -Type CNAME -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -eq 'CNAME' })
            $CorrectTeamsSIPCNAME = if ($TeamsSIPCNAMEConfigurationRecord.CanonicalName) {
                $TeamsSIPCNAMEConfigurationRecord.CanonicalName
            }
            else {
                $TeamsCNAME
            }

            $CurrentTeamsSIP = '{0}={1}' -f $TeamsSIPCNAME, $CurrentTeamsSIPCNAME[0].NameHost
            $CorrectTeamsSIP = '{0}={1}' -f $TeamsSIPCNAME, $CorrectTeamsSIPCNAME

            if ($SIPCNAME.Count -gt 1) {
                Write-Warning -Message ('More than one SIP CNAME record exist for domain "{0}".' -f $Dom)
            }
            elseif ($CurrentTeamsSIP -eq $CorrectTeamsSIP) {
                $TeamsSIPCNAMEValid = $true
            }
            else {
                Write-Verbose -Message ('No SIP CNAME record exist for domain "{0}".' -f $Dom)
            }
            #endregion TeamsSipCNAME
            #region TeamsDiscoverCNAME
            $TeamsDiscoverCNAMEValid = $false
            $TeamsDiscoverCNAME = ('lyncdiscover.{0}' -f $Dom)
            $TeamsDiscoverCNAMEConfigurationRecord = ($DomainServiceConfigurationRecord.Where( { $_.Label -eq $TeamsDiscoverCNAME -and $_.RecordType -eq 'CNAME' -and $_.SupportedService -eq 'OfficeCommunicationsOnline' }))

            $CurrentTeamsDiscoverCNAME = (Resolve-DnsName -Name $TeamsDiscoverCNAME -Type CNAME -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -eq 'CNAME' })
            $CorrectTeamsDiscoverCNAME = if ($TeamsDiscoverCNAMEConfigurationRecord.CanonicalName) {
                $TeamsDiscoverCNAMEConfigurationRecord.CanonicalName
            }
            else {
                $TeamsDiscover
            }

            $CurrentTeamsDiscover = '{0}={1}' -f $TeamsDiscoverCNAME, $CurrentTeamsDiscoverCNAME[0].NameHost
            $CorrectTeamsDiscover = '{0}={1}' -f $TeamsDiscoverCNAME, $CorrectTeamsDiscoverCNAME
            if ($SIPCNAME.Count -gt 1) {
                Write-Warning -Message ('More than one SIP Discover CNAME record exist for domain "{0}".' -f $Dom)
            }
            elseif ($CurrentTeamsDiscover -eq $CorrectTeamsDiscover) {
                $TeamsDiscoverCNAMEValid = $true
            }
            else {
                Write-Verbose -Message ('No SIP Discover CNAME record exist for domain "{0}".' -f $Dom)
            }
            #endregion TeamsDiscoverCNAME
            #region EnterpriseRegistration
            $EnterpriseRegistrationValid = $false
            $EnterpriseRegistrationDomain = ('enterpriseregistration.{0}' -f $Dom)
            $EnterpriseRegistrationConfigurationRecord = ($DomainServiceConfigurationRecord.Where( { $_.Label -eq $EnterpriseRegistrationDomain -and $_.RecordType -eq 'CNAME' -and $_.SupportedService -eq 'Intune' }))

            $CurrentEnterpriseRegistrationCNAME = (Resolve-DnsName -Name $EnterpriseRegistrationDomain -Type CNAME -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -eq 'CNAME' })
            $CorrectEnterpriseRegistrationCNAME = if ($EnterpriseRegistrationConfigurationRecord.CanonicalName) {
                $EnterpriseRegistrationConfigurationRecord.CanonicalName
            }
            else {
                $EnterpriseRegistrationTarget
            }

            $CurrentEnterpriseRegistration = '{0}={1}' -f $EnterpriseRegistrationDomain, $CurrentEnterpriseRegistrationCNAME[0].NameHost
            $CorrectEnterpriseRegistration = '{0}={1}' -f $EnterpriseRegistrationDomain, $CorrectEnterpriseRegistrationCNAME

            if ($CurrentEnterpriseRegistration.Count -gt 1) {
                Write-Warning -Message ('More than one EnterpriseRegistration CNAME record exist for domain "{0}".' -f $Dom)
            }
            elseif ($CurrentEnterpriseRegistration -eq $CorrectEnterpriseRegistration) {
                $EnterpriseRegistrationValid = $true
            }
            else {
                Write-Verbose -Message ('No EnterpriseRegistration CNAME record exist for domain "{0}".' -f $Dom)
            }
            #endregion EnterpriseRegistration
            #region EnterpriseEnrollment
            $EnterpriseEnrollmentValid = $false
            $EnterpriseEnrollmentDomain = ('enterpriseenrollment.{0}' -f $Dom)
            $EnterpriseEnrollmentConfigurationRecord = ($DomainServiceConfigurationRecord.Where( { $_.Label -eq $EnterpriseEnrollmentDomain -and $_.RecordType -eq 'CNAME' -and $_.SupportedService -eq 'Intune' }))

            $CurrentEnterpriseEnrollmentCNAME = (Resolve-DnsName -Name $EnterpriseEnrollmentDomain -Type CNAME -Server $DNSQueryServer -ErrorAction SilentlyContinue).Where( { $_.Type -eq 'CNAME' })
            $CorrectEnterpriseEnrollmentCNAME = if ($EnterpriseEnrollmentConfigurationRecord.CanonicalName) {
                $EnterpriseEnrollmentConfigurationRecord.CanonicalName
            }
            else {
                $EnterpriseEnrollmentTarget
            }

            $CurrentEnterpriseEnrollment = '{0}={1}' -f $EnterpriseEnrollmentDomain, $CurrentEnterpriseEnrollmentCNAME[0].NameHost
            $CorrectEnterpriseEnrollment = '{0}={1}' -f $EnterpriseEnrollmentDomain, $CorrectEnterpriseEnrollmentCNAME

            if ($CurrentEnterpriseEnrollment.Count -gt 1) {
                Write-Warning -Message ('More than one EnterpriseEnrollment CNAME record exist for domain "{0}".' -f $Dom)
            }
            elseif ($CurrentEnterpriseEnrollment -eq $CorrectEnterpriseEnrollment) {
                $EnterpriseEnrollmentValid = $true
            }
            else {
                Write-Verbose -Message ('No EnterpriseEnrollment CNAME record exist for domain "{0}".' -f $Dom)
            }
            #endregion EnterpriseEnrollment
            #region SupportedServices
            if ($VerifyAgainstAzure) {
                $EnabledServices = $AzureADDomain.Where( { $_.Name -eq $Dom }).SupportedServices -join ', '
            }
            elseif ($PSBoundParameters.ContainsKey('VerifyAgainstAzure')) {
                $EnabledServices = 'Domain not added to Microsoft 365'
            }
            else {
                $EnabledServices = 'Only available when verifying against Azure'
            }
            #endregion SupportedServices
            #PSTypeName                    = 'Omnicit.Get.Microsoft365DNS'
            [PSCustomObject]@{
                Domain                        = [string]$Dom
                AddedToAzure                  = [bool]$VerifyAgainstAzure
                EnabledServices               = [string]$EnabledServices
                CurrentAutodiscover           = [string]$CurrentAutodiscover
                M365AutodiscoverCNAME         = [string]$CorrectAutodiscover
                AutodiscoverValid             = [bool]$AutodiscoverValid
                CurrentMX                     = [string]$MX.NameExchange -join ', '
                M365MXRecord                  = [string]$CorrectMX
                MXValid                       = [bool]$MXValid
                CurrentSPF                    = [string]$TopSPF.Strings
                M365SPFRecord                 = [string]$SPFValue
                SPFValid                      = [bool]$SPFValid
                CurrentDMARC                  = [string]$DMARC
                DMARCValid                    = [bool]$DMARCValid
                DKIMValid                     = [bool]$DKIMValid
                CurrentDKIMCNAME1             = [string]$CurrentDKIM1
                CurrentDKIMCNAME2             = [string]$CurrentDKIM2
                M365DKIMCNAME1                = [string]$CorrectDKIM1
                M365DKIMCNAME2                = [string]$CorrectDKIM2
                CurrentTeamsFederation        = [string]($CurrentSRVFederation | ConvertFrom-SRVRecord)
                M365TeamsFederation           = [string]($TeamsSRVFederation | ConvertFrom-SRVRecord)
                TeamsFederationValid          = [bool]$TeamsSRVFederationValid
                CurrentTeamsSIP               = [string]($CurrentTeamsSRVSIP | ConvertFrom-SRVRecord)
                M365TeamsSIP                  = [string]($TeamsSRVSIP | ConvertFrom-SRVRecord)
                TeamsSIPValid                 = [bool]$TeamsSRVSIPValid
                CurrentTeamsSIPCNAME          = [string]$CurrentTeamsSIP
                M365TeamsSIPCNAME             = [string]$CorrectTeamsSIP
                TeamsSIPCNAMEValid            = [bool]$TeamsSIPCNAMEValid
                CurrentTeamsDiscoverCNAME     = [string]$CurrentTeamsDiscover
                M365TeamsDiscoverCNAME        = [string]$CorrectTeamsDiscover
                TeamsDiscoverCNAMEValid       = [bool]$TeamsDiscoverCNAMEValid
                CurrentEnterpriseRegistration = [string]$CurrentEnterpriseRegistration
                M365EnterpriseRegistration    = [string]$CorrectEnterpriseRegistration
                EnterpriseRegistrationValid   = [bool]$EnterpriseRegistrationValid
                CurrentEnterpriseEnrollment   = [string]$CurrentEnterpriseEnrollment
                M365EnterpriseEnrollment      = [string]$CorrectEnterpriseEnrollment
                EnterpriseEnrollmentValid     = [bool]$EnterpriseEnrollmentValid
            }
        }
    }
    end {
    }
}