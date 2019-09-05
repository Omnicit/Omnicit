function Get-FolderSize {
    <#
        .SYNOPSIS
        Get folder size using Robocopy.exe and displays the output in a PSObject table.

        .DESCRIPTION
        This function uses Robocopy.exe to calculate the size used for the select path.
        You can specify if you want to display files older than a specific date using the MinFileData parameter.
        If you experience that the function Get-FolderSize (Robocopy) takes time to execute you can increase the threads used by Robocopy with the RobocopyThreadCount parameter.


        .EXAMPLE
        'C:\Temp' | Get-FolderSize


        Path               : C:\Temp
        TotalBytes         : 658241
        TotalMBytes        : 1
        TotalGBytes        : 0
        DirCount           : 1
        FileCount          : 15
        DirFailed          : 0
        FileFailed         : 0
        FilesOlderThenDate : 2016-08-30 12:39:57
        TimeElapsed        : 0
        StartedTime        : 2016-08-30 12:39:57
        EndedTime          : 2016-08-30 12:39:57


        .EXAMPLE
        Get-FolderSize -Path \\contoso.net\NETLOGON -BytePrecision 4


        Path               : \\contoso.net\NETLOGON
        TotalBytes         : 872640
        TotalMBytes        : 0,8322
        TotalGBytes        : 0,0008
        DirCount           : 4
        FileCount          : 6
        DirFailed          : 0
        FileFailed         : 0
        FilesOlderThenDate : 2016-08-30 12:43:16
        TimeElapsed        : 0,1443
        StartedTime        : 2016-08-30 12:43:16
        EndedTime          : 2016-08-30 12:43:16

        .EXAMPLE
        Get-FolderSize -Path \\contoso.net\NETLOGON -BytePrecision 4 -MinFileDate 2014-01-01


        Path               : \\contoso.net\NETLOGON
        TotalBytes         : 22147
        TotalMBytes        : 0,0211
        TotalGBytes        : 0,0000
        DirCount           : 4
        FileCount          : 1
        DirFailed          : 0
        FileFailed         : 0
        FilesOlderThenDate : 2014-01-01 00:00:00
        TimeElapsed        : 0,1764
        StartedTime        : 2016-08-30 12:45:08
        EndedTime          : 2016-08-30 12:45:08

        .EXAMPLE
        Get-FolderSize -Path \\contoso.net\NETLOGON -BytePrecision 4 -MinFileDate 2014-01-01 -FullOutput


        Path               : \\contoso.net\NETLOGON
        TotalBytes         : 872640
        TotalMBytes        : 0,8322
        TotalGBytes        : 0,0008
        DateTotalBytes     : 22147
        DateTotalMBytes    : 0,0211
        DateTotalGBytes    : 0,0000
        DirCount           : 4
        DateDirCount       : 4
        FileCount          : 6
        DateFileCount      : 1
        DirFailed          : 0
        FileFailed         : 0
        FilesOlderThenDate : 2014-01-01 00:00:00
        TimeElapsed        : 0,2149
        StartedTime        : 2016-08-30 12:45:42
        EndedTime          : 2016-08-30 12:45:42


        .LINK
        https://github.com/Omnicit/Omnicit/blob/master/docs/en-US/Get-FolderSize.md

    #>

    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = 'Default'
    )]
    param (
        # Specifies the path to the source directory to measure.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$Path = $Pwd.Path,

        # Specifies the minimum file age (exclude files newer than N date).
        [Parameter(
            ParameterSetName = 'MinFile'
        )]
        [Alias('MinDate')]
        [datetime]$MinFileAgeDate = [datetime]::Now,

        # Specifies the maximum file age (to exclude files older than N date).
        [Parameter(
            ParameterSetName = 'MaxFile'
        )]
        [Alias('MaxDate')]
        [datetime]$MaxFileAgeDate = [datetime]::Now,

        # Specifies number of fractional digits, and rounds midpoint values to the nearest even number when converting bytes.
        [int]$BytePrecision = 2,

        # Number of threads used for Robocopy.
        [ValidateRange(1, 128)]
        [int]$RobocopyThreadCount = 16
    )
    begin {
        try {
            $PreviousErrorActionPreference = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'

            if (Get-Variable IsWindows -ErrorAction SilentlyContinue) {
                if (-not $IsWindows) {
                    throw [System.NotSupportedException]::New('Get-FolderSize is only supported on Windows operating systems.')
                }
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

        switch ($PSBoundParameters.Keys) {
            MinFileDate {
                $null = $RobocopyArgs.Add("/MINAGE:$($MinFileAgeDate.ToString('yyyyMMdd'))")
                [string]$DateFilter = ('Minimum file age "{0}"' -f $MinFileAgeDate.ToShortDateString())
            }
            MaxFileDate {
                $null = $RobocopyArgs.Add("/MAXAGE:$($MaxFileAgeDate.ToString('yyyyMMdd'))")
                [string]$DateFilter = ('Maximum file age "{0}"' -f $MaxFileAgeDate.ToShortDateString())
            }
            Default {
                [string]$DateFilter = $null
            }
        }
        Write-Verbose -Message ('Robocopy arguments: {0}' -f $RobocopyArgs)
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
                    [string]$Summary = (& "$env:windir\system32\robocopy.exe" $InlinePath NULL "$RobocopyArgs")[-8..-1]
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
