function Get-FolderSize {
    <#
        .SYNOPSIS
        Get folder size using Robocopy.exe and displays the output in a PSObject table.

        .DESCRIPTION
        This function uses Robocopy.exe to calculate the size used for the select path.
        You can specify if you want to display files older than a specific date using the MinFileData parameter.
        If you experience that the function Get-FolderSize (Robocopy) takes time to execute you can increase the threads used by Robocopy with the RobocopyThreadCount parameter.

        .EXAMPLE
        Get-FolderSize

        Path       TotalBytes  TotalMBytes TotalGBytes FilesCount DirCount TimeElapsed
        ----       ----------  ----------- ----------- ---------- -------- -----------
        C:\Windows 18512797867 17655,18    17,24       144492     34036    00:00:12.2813478

        This example returns a PSObject with the total folder size for the current location, which in this case in C:\Windows.
        .EXAMPLE
        Get-FolderSize -Path \\contoso.com\NETLOGON

        Path                   TotalBytes TotalMBytes TotalGBytes FilesCount DirCount TimeElapsed
        ----                   ---------- ----------- ----------- ---------- -------- -----------
        \\contoso.com\NETLOGON 1019904    0,97        0,00        1          2        00:00:00.0157300

        This example returns a PSObject with the total folder size for the specified location path \\contoso.com\NETLOGON.
        .EXAMPLE
        Get-FolderSize -Path \\contoso.net\NETLOGON -BytePrecision 4

        Path                   TotalBytes TotalMBytes TotalGBytes FilesCount DirCount TimeElapsed
        ----                   ---------- ----------- ----------- ---------- -------- -----------
        \\contoso.com\NETLOGON 1019904    0,9727      0,0009      1          2        00:00:00.0155598

        This example returns a PSObject with the total folder size, with for decimals, for the specified location path \\contoso.com\NETLOGON.
        .EXAMPLE
        Get-FolderSize -Path C:\Windows -MinFileAgeDate 2019-06-01

        Path       TotalBytes  TotalMBytes TotalGBytes FilesCount DirCount TimeElapsed
        ----       ----------  ----------- ----------- ---------- -------- -----------
        C:\Windows 11448807458 10918,43    10,66       101354     34036    00:00:24.1594950

        This example returns a PSObject with the total folder size for the specified location path C:\Windows and excludes files newer than 2019-06-01.

        .EXAMPLE
        Get-FolderSize -Path C:\Windows -MaxFileAgeDate 2019-06-01

        Path       TotalBytes TotalMBytes TotalGBytes FilesCount DirCount TimeElapsed
        ----       ---------- ----------- ----------- ---------- -------- -----------
        C:\Windows 7063990409 6736,75     6,58        43138      34036    00:00:10.2498128

        This example returns a PSObject with the total folder size for the specified location path C:\Windows and excludes files older than 2019-06-01.

        .EXAMPLE
        Get-FolderSize -Path C:\Windows -MaxFileAgeDate 2019-06-01 | Select-Object -Property *

        Path              : C:\Windows
        TotalBytes        : 7065038985
        TotalMBytes       : 6737,75
        TotalGBytes       : 6,58
        FilesCount        : 43138
        DirCount          : 34036
        BytesFailed       : 0
        DirFailed         : 0
        FileFailed        : 0
        TimeElapsed       : 00:00:10.0465934
        StartedTime       : 2019-09-05 22:28:33
        EndedTime         : 2019-09-05 22:28:43
        DateFilter        : Maximum file age "2019-06-01".
        TotalBytesNoDate  : 18474790494
        TotalMBytesNoDate : 17618,93
        TotalGBytesNoDate : 17,21
        DirCountNoDate    : 34057
        FileCountNoDate   : 144414

        This example returns a PSObject with all available properties extracted from the specified location path C:\Windows and excludes files older than 2019-06-01.

        .LINK
        https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-FolderSize.md
    #>

    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = 'Default',
        PositionalBinding
    )]
    param (
        # Specifies the path to the source directory to measure.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0
        )]
        [PSDefaultValue(Help = 'Current path')]
        [string[]]$Path = ($PWD.Path),

        # Specifies the minimum file age (exclude files newer than N date).
        [Parameter(
            ParameterSetName = 'MinFile',
            Mandatory,
            Position = 1
        )]
        [Alias('MinDate')]
        [datetime]$MinFileAgeDate,

        # Specifies the maximum file age (to exclude files older than N date).
        [Parameter(
            ParameterSetName = 'MaxFile',
            Mandatory,
            Position = 2
        )]
        [Alias('MaxDate')]
        [datetime]$MaxFileAgeDate,

        # Specifies number of fractional digits, and rounds midpoint values to the nearest even number when converting bytes.
        [Parameter(
            Position = 3
        )]
        [int]$BytePrecision = 2,

        # Number of threads used for Robocopy.
        [Parameter(
            Position = 4
        )]
        [ValidateRange(1, 128)]
        [int]$RobocopyThreadCount = 16
    )
    begin {
        try {
            $PreviousErrorActionPreference = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'

            if (-not $IsWindows -and $PSVersionTable.PSEdition -eq 'Core') {
                throw [System.NotSupportedException]::New('Get-FolderSize is only supported on Windows operating systems.')
            }
            if (-not (Get-Command -Name "$env:windir\system32\robocopy.exe" -ErrorAction SilentlyContinue)) {
                throw [System.NotSupportedException]::New("Unable to locate Robocopy.exe in $env:windir\system32. Please verify if Robocopy.exe is available in the specified path.")
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
        finally {
            $ErrorActionPreference = $PreviousErrorActionPreference
        }

        [Collections.ArrayList]$RobocopyArgs = @('/BYTES', '/FP', '/L', "/MT:$RobocopyThreadCount", '/NC', '/NDL', '/NJH', '/R:0', '/S', '/TS', '/W:0', '/XJ')

        $DateFilter = $null
        switch ($PSBoundParameters.Keys) {
            MinFileAgeDate {
                $null = $RobocopyArgs.Add("/MINAGE:$($MinFileAgeDate.ToString('yyyyMMdd'))")
                [string]$DateFilter = ('Minimum file age "{0}".' -f $MinFileAgeDate.ToShortDateString())
            }
            MaxFileAgeDate {
                $null = $RobocopyArgs.Add("/MAXAGE:$($MaxFileAgeDate.ToString('yyyyMMdd'))")
                [string]$DateFilter = ('Maximum file age "{0}".' -f $MaxFileAgeDate.ToShortDateString())
            }
        }
        # Thank you 'Joakim Svendsen' for the regular expression examples and inspiration!
        [regex]$HeaderRegex = '\s+Total\s+Copied\s+Skipped\s+Mismatch\s+FAILED\s+Extras'
        [regex]$DirLineRegex = 'Dirs\s+:\s+(?<DirCount>\d+)\s+(?<DirCopiedCount>\d+)(?:\s+\d+){2}\s+(?<DirsFailed>\d+)\s+\d+'
        [regex]$FileLineRegex = 'Files\s+:\s+(?<FileCount>\d+)\s+(?<FilesCopiedCount>\d+)(?:\s+\d+){2}\s+(?<FilesFailed>\d+)\s+\d+'
        [regex]$BytesLineRegex = 'Bytes\s+:\s+(?<ByteCount>\d+)\s+(?<ByteCopiedCount>\d+)(?:\s+\d+){2}\s+(?<BytesFailed>\d+)\s+\d+'
        [regex]$TimeLineRegex = 'Times\s+:\s+(?<TimeElapsed>\d+:\d+:\d+).+'
        [regex]$EndedLineRegex = 'Ended\s+:\s+(?<EndedTime>.+)'
    }
    process {
        foreach ($InlinePath in $Path) {
            if ($PSCmdlet.ShouldProcess($InlinePath)) {
                try {

                    [datetime]$StartTime = [datetime]::Now
                    [string]$Summary = (& "$env:windir\system32\robocopy.exe" $InlinePath NULL $RobocopyArgs)[-8..-1]
                    [datetime]$EndTime = [datetime]::Now

                    if ($Summary -match "$HeaderRegex\s+$DirLineRegex\s+$FileLineRegex\s+$BytesLineRegex\s+$TimeLineRegex\s+$EndedLineRegex") {
                        [PSCustomObject]@{
                            PSTypeName        = 'Omnicit.Get.FolderSize'
                            Path              = [string]$InlinePath
                            TotalBytes        = [decimal]$Matches['ByteCopiedCount']
                            TotalMBytes       = [decimal]([math]::Round(([decimal]$Matches['ByteCopiedCount'] / 1MB), $BytePrecision))
                            TotalGBytes       = [decimal]([math]::Round(([decimal]$Matches['ByteCopiedCount'] / 1GB), $BytePrecision))
                            FilesCount        = [decimal]$Matches['FilesCopiedCount']
                            DirCount          = [decimal]$Matches['DirCopiedCount']
                            BytesFailed       = [decimal]$Matches['BytesFailed']
                            DirFailed         = [decimal]$Matches['DirFailed']
                            FileFailed        = [decimal]$Matches['FileFailed']
                            TimeElapsed       = [TimeSpan]($EndTime - $StartTime)
                            StartedTime       = [datetime]$StartTime
                            EndedTime         = [datetime]$EndTime
                            DateFilter        = [string]$DateFilter
                            TotalBytesNoDate  = [decimal]$Matches['ByteCount']
                            TotalMBytesNoDate = [decimal]([math]::Round(([decimal]$Matches['ByteCount'] / 1MB), $BytePrecision))
                            TotalGBytesNoDate = [decimal]([math]::Round(([decimal]$Matches['ByteCount'] / 1GB), $BytePrecision))
                            DirCountNoDate    = [decimal]$Matches['DirCount']
                            FileCountNoDate   = [decimal]$Matches['FileCount']
                        }
                    }
                    else {
                        Write-Warning -Message "Unexpected format returned from Robocopy.exe for path '$InlinePath'." -WarningAction Continue
                    }
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }
}
