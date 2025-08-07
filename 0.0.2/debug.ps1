$PSD1File = Get-ChildItem -Path "$($PSScriptRoot)\*.psd1" -ErrorAction SilentlyContinue
Import-Module $PSD1File.FullName -Force

# Set the most constrained mode
Set-StrictMode -Version Latest

# Set the error preference
$ErrorActionPreference = 'Stop'

# Set the verbose preference in order to get some insights
# $VerbosePreference = 'Continue'

# Set the stopwatch
$DebugStopWatch = [System.Diagnostics.Stopwatch]::new()
$DebugStopWatch.Start()

# Set the Verbose color as something different than the warning color (yellow)
if (Get-Variable -Name PSStyle -ErrorAction SilentlyContinue) {
    $PSStyle.Formatting.Verbose = $PSStyle.Foreground.BrightCyan
}Else{
    $Host.PrivateData.VerboseForegroundColor = 'Cyan'
}

############################
# Debug your functions here #
############################

# Debug the Write-Log function
$LogFile = "$($Env:TEMP)\SPS-PSHelper-DEBUG-$(New-Guid).log"
# Create the log file and define the log level
Write-Log -Message 'Entering Tests...' # -Level 'DEBUG' # -LogFile $LogFile -LogLevel 'DEBUG'

BREAK
# Should Write a verbose message and a verbose line in the log file
Write-Log 'First line of Test (Verbose)' -Level 'VERBOSE'
# Should Write a debug message and a debug line in the log file
Write-Log -Level 'DEBUG' -Message 'Second line of Test (Debug)'
Write-Log -Level 'INFO' -Message 'Third line of Test (Info)'
Write-Log -Level 'VERBOSE' -Message 'Fourth line of Test (Verbose)'
Write-Log -Level 'DEBUG' -Message 'Fifth line of Test (Debug)'
Write-Log -Level 'VERBOSE' -Message 'Sixth line of Test (Verbose)'

Write-Host "You can find the log file at: $LogFile" -ForegroundColor Cyan

# Debug the New-FunctionToClip function
# Should copy the function to the clipboard
Set-ClipBoard -Value ''
New-FunctionToClip -Name 'Get-TestFunction'
# Showing the clipboard content
$ClipboardContent = Get-Clipboard
"Clipboard content:","" | Write-Host -ForegroundColor Cyan
$ClipboardContent | Write-Host -ForegroundColor Green
"","-- End of Clipboard content --" | Write-Host -ForegroundColor Cyan

# Debug the New-ClassToClip function
Set-ClipBoard -Value ''
New-ClassToClip -Name 'TestClass'
$ClipboardContent = Get-Clipboard
"Clipboard content:","" | Write-Host -ForegroundColor Cyan
$ClipboardContent | Write-Host -ForegroundColor Green
"","-- End of Clipboard content --" | Write-Host -ForegroundColor Cyan

##################################
# End of the Debug show metrics #
##################################
Write-Host '------------------- Ending Debug script -------------------' -ForegroundColor Yellow
$DebugStopWatch.Stop()
$TimeSpentInDebugScript = $DebugStopWatch.Elapsed
$TimeUnits = [ordered]@{TotalDays = "$($TimeSpentInDebugScript.TotalDays) D.";TotalHours = "$($TimeSpentInDebugScript.TotalHours) h.";TotalMinutes = "$($TimeSpentInDebugScript.TotalMinutes) min.";TotalSeconds = "$($TimeSpentInDebugScript.TotalSeconds) s.";TotalMilliseconds = "$($TimeSpentInDebugScript.TotalMilliseconds) ms."}
foreach ($Unit in $TimeUnits.GetEnumerator()) {if ($TimeSpentInDebugScript.$($Unit.Key) -gt 1) {$TimeSpentString = $Unit.Value;break}}
if (-not $TimeSpentString) {$TimeSpentString = "$($TimeSpentInDebugScript.Ticks) Ticks"}
Write-Host 'Ending : ' -ForegroundColor Yellow -NoNewLine
Write-Host $($MyInvocation.MyCommand) -ForegroundColor Magenta -NoNewLine
Write-Host ' - TimeSpent : ' -ForegroundColor Yellow -NoNewLine
Write-Host $TimeSpentString -ForegroundColor Magenta
