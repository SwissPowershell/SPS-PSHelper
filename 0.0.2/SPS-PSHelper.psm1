Enum SPSLogLevel {
    NONE = 3
    DEBUG = 1
    VERBOSE = 2
    INFO = 3
    WARN = 4
    WARNING = 4
    ERROR = 5
    CRITIC = 6
    CRITICAL = 6
}
Function Write-Log {
        <#
        .SYNOPSIS
        Writes a log entry to a log file or the console.
        .DESCRIPTION
        This function writes a log entry to a log file or the console. It supports different log levels and can be used to log messages during script execution.
        .PARAMETER Message
        The message to log.
        .PARAMETER Level
        The log level. Default is INFO. Everything below will not be written.
        .PARAMETER LogFile
        The log file location. If not specified, a temporary file will be created.
        .PARAMETER LogLevel
        The log level. Default is INFO. Everything below will not be written.
        .EXAMPLE
        Write-Log -Message 'This is an info message.' -Level 'INFO'
        Logs an info message to the console or log file.
        .EXAMPLE
        Write-Log -Message 'This is a warning message.' -Level 'WARN' -LogFile 'C:\Logs\MyScript.log'
        Logs a warning message to the specified log file.
        .EXAMPLE
        Write-Log -Message 'This is an error message.' -Level 'ERROR'
        Logs an error message to the console or log file.
        #>
        [CmdletBinding()]
        Param(
            [Parameter(
                Position=1,
                Mandatory=$False,
                HelpMessage='The message to log.',
                ValueFromPipeline=$True
            )]
            [String] ${Message} = '',

            [Parameter(
                Position=2,
                Mandatory=$False,
                HelpMessage='The log level.'
            )]
            [SPSLogLevel] ${Level} = [SPSLogLevel]::NONE,
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
            [SPSLogLevel] ${LogLevel} = [SPSLogLevel]::NONE,
            [Switch] ${NoHeader},
            [Switch] ${Silent}
        )
        BEGIN{
        Function New-LogHeader {
            Param(
                [Parameter(
                    Position=1,
                    Mandatory=$True,
                    HelpMessage='The log level. Default is INFO. Everything below will not be written.'
                )]
                [SPSLogLevel] ${LogLevel}
            )
            $OVerbosePreference = $VerbosePreference
            $VerbosePreference = 'SilentlyContinue'
            $Process = Get-Process -Id $PID -Verbose:$False
            $CurrentDate = Get-Date -Format (Get-Culture).DateTimeFormat.ShortDatePattern
            $CurrentTime = "$(Get-Date -Format (Get-Culture).DateTimeFormat.LongTimePattern).$(Get-Date -Format 'fff')"
            $CallStack = @(Get-PSCallStack)
            $Global:TheCallStack = $CallStack
            if (($CallStack.Count -eq 3) -and ($null -eq $CallStack[2].ScriptName -or $CallStack[2].ScriptName -eq '')) {
                $CommandLine = ''
                $ScriptLocation = ''
            }Else{
                $CommandLine = $($($Process.CommandLine) -replace "`"$([Regex]::Escape($($Process.Path)))`" ",'')
                $ScriptLocation = $CallStack[-2].Location
            }
            $Content = @"
**********************
Write-Log ($((Get-Command -Name Write-Log).Module.Version)_$((Get-Command -Name Write-Log).Module.PrivateData.PSData['Prerelease'])) start
Init Log Level: $($LogLevel)
Start-Date: $($CurrentDate)
Start-Time: $($CurrentTime)
UserName: $($Env:UserName)
Machine: $($Env:ComputerName)
Host Application: $($($Process.Path) -Replace '"','')
Command Line: $($CommandLine)
Caller: $($ScriptLocation)
Process ID: $($PID)
PSVersion: $($PSVersionTable.PSVersion)
PSEdition: $($Host.Name)

**********************

"@
            $VerbosePreference = $OVerbosePreference
            Write-Output $Content
        }
        $FirstCall = $False
        # Handle the logfile path
        If ([String]::IsNullOrEmpty($LogFile) -eq  $False) {
            # The logfile has been provided store in '$Script:__SPS_LogFile' for next execution by the same script
            if ($LogFile -ne $Script:__SPS_LogFile) {
                $Script:__SPS_LogFile = $LogFile
                $FirstCall = $True
            }
        }Elseif ($Script:__SPS_LogFile -notlike '') {
            # The logfile has been stored in '$Script:__SPS_LogFile' use it
            $LogFile = $Script:__SPS_LogFile
        }Else {
            # The logfile has not been provided, create a new one and store it in '$Script:__SPS_LogFile' for next execution by the same script
            $Script:__SPS_LogFile = "$($Env:TEMP)\$($MyInvocation.MyCommand)-$([Guid]::NewGuid().Guid).log"
            Write-Warning "Log file not specified, using temporary file: $($Script:__SPS_LogFile)"
            $LogFile = $Script:__SPS_LogFile
        }
        # Handle the log level
        if ($LogLevel -ne [SPSLogLevel]::NONE) {
            # The log level has been provided store in '$Script:__SPS_LogLevel' for next execution by the same script
            $Script:__SPS_LogLevel = $LogLevel
        }Elseif (($Script:__SPS_LogLevel -ne [SPSLogLevel]::NONE) -and ($null -ne $Script:__SPS_LogLevel) -and (-not $Script:__SPS_LogLevel)) {
            # The log level has been stored in '$Script:__SPS_LogLevel' use it
            $LogLevel = [SPSLogLevel] "$($Script:__SPS_LogLevel)"
        }Else {
            # The log level has not been provided, set it to INFO and store it in '$Script:__SPS_LogLevel' for next execution by the same script
            $Script:__SPS_LogLevel = [SPSLogLevel]::INFO
            $LogLevel = [SPSLogLevel]::INFO
        }
        if ((Test-Path -Path $LogFile) -eq $False) {
            $FirstCall = $True
        }
    }
    PROCESS{
        Switch ($Level) {
            {$_ -eq 1} { # Debug level
                if (-not $Silent) { Write-Debug $Message }
                BREAK
            }
            {$_ -eq 2} { # Verbose level
                if (-not $Silent) { Write-Verbose $Message }
                BREAK
            }
            {$_ -eq 3} { # Info level (default) also NONE
                $Level = [SPSLogLevel]::INFO
                if (Get-Command -Name Write-Information) {
                    if (-not $Silent) { Write-Information $Message }
                }Else{
                    if (-not $Silent) { Write-Host $Message }
                }
                BREAK
            }
            {$_ -eq 4} { # Warning level
                $Level = [SPSLogLevel]::WARN
                if (-not $Silent) { Write-Warning $Message }
                BREAK
            }
            {$_ -eq 5} { # Error level
                $Level = [SPSLogLevel]::ERROR
                # if (-not $Silent) { Write-Error $Message}
                BREAK
            }
            {$_ -eq 6} { # Critical level
                $Level = [SPSLogLevel]::CRITIC  
                # if (-not $Silent) { Write-Error $Message }
                BREAK
            }
        }
        # For the first call, create the log file Header
        if (($FirstCall -eq $True) -and ($NoHeader -eq $False)) {
            $Content = New-LogHeader -LogLevel $LogLevel
            Try {
                Add-Content -Path $LogFile -Value $Content -Force
            }Catch{
                Throw "Unexepected error while writing the log file header: $($_.Exception.Message)"
            }
        }
        # Check if the log level is above the LogLevel
        if ($Level -ge $LogLevel) {
            if (($Message -eq '') -and ($FirstCall -eq $True)) {
                # The message is empty and it is the first call, do not write to the log file
                $FirstCall = $False
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
        # Reset the first call flag
        $FirstCall = $False
    }
    END{}
}
Function New-FunctionToClip {
    <#
    .SYNOPSIS
    Creates a new PowerShell function and copies it to the clipboard.
    .DESCRIPTION
    This function creates a new PowerShell function with a specified name and copies the function code to the clipboard. It can be used to quickly create boilerplate code for new functions.
    .PARAMETER Name
    The name of the function to create. It should follow the verb-noun format (e.g., 'Get-Example').
    .PARAMETER Simple
    If specified, creates a simple function without detailed comments and parameters.
    .PARAMETER Force
    If specified, skips the validation of the function name and allows any name to be used.
    .EXAMPLE
    New-FunctionToClip -Name 'Get-Example'
    Creates a new function named 'Get-Example' and copies the code to the clipboard.
    .EXAMPLE
    New-FunctionToClip -Name 'Set-Example' -Simple
    Creates a simple function named 'Set-Example' without detailed comments and parameters, and copies the code to the clipboard.
    .EXAMPLE
    New-FunctionToClip -Name 'New-ExampleFunction' -Force
    Creates a new function named 'New-ExampleFunction' without validating the name format and copies
    the code to the clipboard.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(
            Position=1,
            Mandatory=$false,
            HelpMessage='The name of the function.'
        )]
        [ValidateNotNullOrEmpty()]
        [String] ${Name}='New-ExampleFunction',
        [Switch] ${Simple},
        [Switch] ${Force}
    )
    # Check if the name provided use the verb-noun format
    if ($Name -notmatch '^(?<Verb>[a-z]+)-(?<Noun>[A-Z][a-zA-Z0-9]*)$') {
        Write-Warning "The function name '$Name' does not follow the verb-noun format. It should be in the format 'Verb-Noun'."
        if (-not $Force){
            return
        }
    }Else{
        $Verb = $Matches['Verb']
        if ($Verb -NotIn $(Get-Verb | Select-Object -ExpandProperty Verb)) {
            Write-Warning "The verb '$Verb' is not a valid PowerShell verb. Please use a valid verb."
            if (-not $Force){
                return
            }
        }
    }
    # Check if the name provided already exists in other modules
    $AllModules = Get-Module -ListAvailable
    ForEach ($Module in $AllModules) {
        if ($Module.ExportedCommands.Values.Name -contains $Name) {
            Write-Warning "The function '$Name' already exists in the module '$($Module.Name)'. Please choose a different name."
            if (-not $Force){
                return
            }
        }
    }
    if ($Simple) {
        $Content = @"
Function $Name {
    [CmdletBinding()]
    Param()
    # Function logic goes here
}
"@
    }Else{
        $Content = @"
Function $Name {
    <#
    .SYNOPSIS
    Short description of the function.

    .DESCRIPTION
    Detailed description of the function.

    .PARAMETER Param1
    Description of parameter 1.

    .PARAMETER Param2
    Description of parameter 2.

    .EXAMPLE
    Example usage of the function.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(
            Position=1,
            Mandatory=`$False,
            HelpMessage='Description of parameter 1.'
        )]
        [String] `${Param1} = '',

        [Parameter(
            Position=2,
            Mandatory=`$False,
            HelpMessage='Description of parameter 2.'
        )]
        [String] `${Param2} = ''
    )
    BEGIN{
        Write-Verbose "Starting `$(`$MyInvocation.MyCommand)"
        # Function initialization logic goes here
    }
    PROCESS{
        Write-Verbose "Processing `$(`$MyInvocation.MyCommand)"
        # Function logic goes here
    }
    END{
        Write-Verbose "Ending `$(`$MyInvocation.MyCommand)"
        # Function cleanup logic goes here
    }
}
"@
    }
    Set-Clipboard -Value $Content
    Write-Host "Function '$Name' copied to clipboard."
}
Function New-ClassToClip {
    <#
    .SYNOPSIS
    Creates a new PowerShell class and copies it to the clipboard.
    .DESCRIPTION
    This function creates a new PowerShell class with a specified name and copies the class code to the clipboard. It can be used to quickly create boilerplate code for new classes.
    .PARAMETER Name
    The name of the class to create. It should start with an uppercase letter and contain only
    alphanumeric characters.
    .EXAMPLE
    New-ClassToClip -Name 'MyNewClass'
    Creates a new class named 'MyNewClass' and copies the code to the clipboard.
    .EXAMPLE
    New-ClassToClip -Name 'InvalidClassName123'
    Writes a warning because the class name is not valid (it contains numbers and does not start
    with an uppercase letter).
    #>
    [CmdletBinding()]
    Param(
        [Parameter(
            Position=1,
            Mandatory=$false,
            HelpMessage='The name of the class.'
        )]
        [ValidateNotNullOrEmpty()]
        [String] ${Name}='NewClass'
    )
    # Check if the name provided is valid class name
    if ($Name -notmatch '^[A-Z][a-zA-Z0-9]*$') {
        Write-Warning "The class name '$Name' is not a valid class name. It should contain only alphanumeric characters."
        Return
    }
    $Content = @"
Class $Name {
    [String] `${Property1}
    [String] `${Property2}
    $Name() {
        # Constructor logic goes here
    }
    $Name([String] `${property1}, [String] `${property2}) {
        # Constructor with parameters
        `$this.Property1 = `$property1
        `$this.Property2 = `$property2
    }
    [String] ToString() {
        return `$this.Property1
    }
}
"@
    Set-Clipboard -Value $Content
    Write-Host "Class '$Name' copied to clipboard."
}