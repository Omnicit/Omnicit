function Get-WanIPAddress {
    <#
    .SYNOPSIS
    The Get-WanIPAddress function retrieves the current external IP address.

    .DESCRIPTION
    The Get-WanIPAddress function retrieves the current external IP address using ifconfig.co as the API provider.

    .EXAMPLE
    Get-WanIPAddress

    IP Address   Country City        Hostname                       ISP
    ----------   ------- ----        --------                       ---
    123.45.67.89 Sweden  Gothenburg  h-123-45.A56.priv.contoso.com  Contso.com

    .LINK
        https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-WanIPAddress.md
    #>
    [Alias('Get-ExternalIP','gwan')]
    [CmdletBinding(
        SupportsShouldProcess
    )]
    param()

    try {
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME)) {
            [Net.ServicePointManager]::SecurityProtocol = 3072, 768, 192 # TLS12, TLS11, TLS
            $Json = Invoke-RestMethod -Method Get -Uri 'https://ifconfig.co/json' -ErrorAction Stop

            [PSCustomObject]@{
                PSTypeName               = 'Omnicit.Get.WanIPAddress'
                IP_address               = $Json.ip
                IP_decimal               = $Json.ip_decimal
                Country                  = $Json.country
                EU_Country               = $Json.country_eu
                ISO_Country              = $Json.country_iso
                City                     = $Json.city
                Hostname                 = $Json.hostname
                Latitude                 = $Json.latitude
                Longitude                = $Json.longitude
                Autonomous_System_Number = $Json.asn
                ISP                      = $Json.asn_org
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}