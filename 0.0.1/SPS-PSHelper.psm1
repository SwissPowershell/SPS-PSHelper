Function New-LogHeader {
    Param(
        [Parameter(
            Position=1,
            Mandatory=$True,
            HelpMessage='The log level. Default is INFO. Everything below will not be written.'
        )]
        [ValidateSet('DEBUG', 'VERBOSE', 'INFO', 'WARN', 'ERROR', 'CRITIC')]
        [String] ${LogLevel}
    )
    $OVerbosePreference = $VerbosePreference
    $VerbosePreference = 'SilentlyContinue'
    $Process = Get-Process -Id $PID -Verbose:$False
    $CurrentDate = Get-Date -Format (Get-Culture).DateTimeFormat.ShortDatePattern
    $CurrentTime = "$(Get-Date -Format (Get-Culture).DateTimeFormat.LongTimePattern).$(Get-Date -Format 'fff')"
    $Content = @"
**********************
Write-Log start
Init Log Level: $($LogLevel)
Start-Date: $($CurrentDate)
Start-Time: $($CurrentTime)
UserName: $($Env:UserName)
Machine: $($Env:ComputerName)
Host Application: $($($Process.Path) -Replace '"','')
Command Line: $($($Process.CommandLine) -replace "`"$([Regex]::Escape($($Process.Path)))`" ",'')
Process ID: $($PID)
PSVersion: $($PSVersionTable.PSVersion)
PSEdition: $($Host.Name)

**********************

"@
    $VerbosePreference = $OVerbosePreference
    Write-Output $Content
}
Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(
            Position=1,
            Mandatory=$False,
            HelpMessage='The message to log.'
        )]
        [String] ${Message} = '',

        [Parameter(
            Position=2,
            Mandatory=$False,
            HelpMessage='The log level.'
        )]
        [ValidateSet('DEBUG', 'VERBOSE', 'INFO', 'WARN', 'ERROR', 'CRITIC')]
        [String] ${Level} = 'INFO',
        [Parameter(
            Position=3,
            Mandatory=$False,
            HelpMessage='The log file location.'
        )]
        [String] ${LogFile} = '',
        [Parameter(
            Position=4,
            Mandatory=$False,
            HelpMessage='The log level. Default is INFO. Everything below will not be written.'
        )]
        [ValidateSet('DEBUG', 'VERBOSE', 'INFO', 'WARN', 'ERROR', 'CRITIC')]
        [String] ${LogLevel} = ''
    )
    BEGIN{
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        # Uppercase the log level
        $Level = $Level.ToUpper()
        $FirstCall = $False
        # Handle the logfile path
        if ($LogFile -ne '') {
            # The logfile has been provided store in '$Script:__SPS_LogFile' for next execution by the same script
            if ($LogFile -ne $Script:__SPS_LogFile) {
                $Script:__SPS_LogFile = $LogFile
                $FirstCall = $True
            }
        }Elseif ($Script:__SPS_LogFile -notlike '') {
            # The logfile has been stored in '$Script:__SPS_LogFile' use it
            $LogFile = $Script:__SPS_LogFile
        }Else {
            # The logfile has not been provided, create a new one
            $Script:LogFile = "$($Env:TEMP)\$($MyInvocation.MyCommand)-$([Guid]::NewGuid().Guid).log"
            $LogFile = $Script:LogFile
        }

        # Handle the log level
        if ($LogLevel -ne '') {
            # The log level has been provided store in '$Script:__SPS_LogLevel' for next execution by the same script
            $Script:__SPS_LogLevel = $LogLevel
        }Elseif ($Script:__SPS_LogLevel -notlike '') {
            # The log level has been stored in '$Script:__SPS_LogLevel' use it
            $LogLevel = $Script:__SPS_LogLevel
        }Else {
            # The log level has not been provided, set it to INFO
            $Script:__SPS_LogLevel = 'INFO'
            $LogLevel = $Script:__SPS_LogLevel
        }
        if ((Test-Path -Path $LogFile) -eq $False) {
            $FirstCall = $True
        }
    }
    PROCESS{
        Write-Verbose "Processing $($MyInvocation.MyCommand)"
        # Write to the stream
        Switch ($Level) {
            'DEBUG' {
                Write-Debug $Message
            }
            'VERBOSE' {
                Write-Verbose $Message
            }
            'INFO*' {
                if (Get-Command -Name Write-Information) {
                    Write-Information -MessageData $Message
                }Else{
                    Write-Host $Message
                }
            }
            'WARN*' {
                Write-Warning $Message
            }
            'ERROR' {
                Write-Error $Message
            }
            'CRITIC*' {
                Write-Error $Message
            }
        }
        # For the first call, create the log file Header
        if ($FirstCall -eq $True) {
            $Content = New-LogHeader -LogLevel $LogLevel
            Try {
                Add-Content -Path $LogFile -Value $Content -Force
            }Catch{
                Throw "Unexepected error while writing the log file header: $($_.Exception.Message)"
            }
            
        }
        # Check if the log level is above the LogLevel
        $LogLevelIndex = [Array]::IndexOf(@('DEBUG', 'VERBOSE', 'INFO', 'WARN', 'ERROR', 'CRITIC'), $LogLevel)  
        $LevelIndex = [Array]::IndexOf(@('DEBUG', 'VERBOSE', 'INFO', 'WARN', 'ERROR', 'CRITIC'), $Level)
        if ($LevelIndex -ge $LogLevelIndex) {
            if (($Message -eq '') -and ($FirstCall -eq $True)) {
                # The message is empty and it is the first call, do not write to the log file
                Return
            }   
            # The log level is greater or equal than the LogLevel, write to the log file
            # Build the log entry
            $TimeStamp = "$(Get-Date -Format (Get-Culture).DateTimeFormat.LongTimePattern).$(Get-Date -Format 'fff')"
            $Line = "{0,-24}: {1}" -f "$($TimeStamp) - [$($Level)]", $Message
            Try {
                Add-Content -Path $LogFile -Value $Line -Force
            }Catch{
                Throw "Unexepected error while writing the log file line: $($_.Exception.Message)"
            }
        }

    }
    END{}
}