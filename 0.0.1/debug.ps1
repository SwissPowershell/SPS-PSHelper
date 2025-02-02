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
# Test your functions here #
############################

Write-Log 'Toto 1' -Level 'DEBUG' -LogFile "c:\Temp\MyLog.log" -LogLevel 'INFO'
Write-Log 'Toto 2' -Level 'VERBOSE'
Write-Log 'Toto 3' -Level 'Info'
Write-Log 'Toto 4' -Level 'VERBOSE'
Write-Log 'Toto 5' -Level 'DEBUG'
Write-Log 'Toto 6' -Level 'VERBOSE'

# git add --all;Git commit -a -am 'Initial Commit';Git push

##################################
# End of the tests show metrics #
##################################
Write-Host '------------------- Ending script -------------------' -ForegroundColor Yellow
$DebugStopWatch.Stop()
$TimeSpentInDebugScript = $DebugStopWatch.Elapsed
$TimeUnits = [ordered]@{TotalDays = "$($TimeSpentInDebugScript.TotalDays) D.";TotalHours = "$($TimeSpentInDebugScript.TotalHours) h.";TotalMinutes = "$($TimeSpentInDebugScript.TotalMinutes) min.";TotalSeconds = "$($TimeSpentInDebugScript.TotalSeconds) s.";TotalMilliseconds = "$($TimeSpentInDebugScript.TotalMilliseconds) ms."}
foreach ($Unit in $TimeUnits.GetEnumerator()) {if ($TimeSpentInDebugScript.$($Unit.Key) -gt 1) {$TimeSpentString = $Unit.Value;break}}
if (-not $TimeSpentString) {$TimeSpentString = "$($TimeSpentInDebugScript.Ticks) Ticks"}
Write-Host 'Ending : ' -ForegroundColor Yellow -NoNewLine
Write-Host $($MyInvocation.MyCommand) -ForegroundColor Magenta -NoNewLine
Write-Host ' - TimeSpent : ' -ForegroundColor Yellow -NoNewLine
Write-Host $TimeSpentString -ForegroundColor Magenta
