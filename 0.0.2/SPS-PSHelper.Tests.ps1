#Requires -Module Pester

# Import the module
Import-Module "$PSScriptRoot\SPS-PSHelper.psm1"

Describe 'Write-Log' {
    It 'Writes an info message to the log file' {
        $TempLogFile = Join-Path -Path $env:TEMP -ChildPath "WriteLogTest-$(New-Guid).log"
        Write-Log -Message 'Test info message' -Level 'INFO' -LogFile $TempLogFile
        $Content = Get-Content -Path $TempLogFile
        ($Content | Where-Object { $_ -match '\[INFO\]' }).Count | Should -BeGreaterThan 0
        Remove-Item -Path $TempLogFile -Force
    }

    It 'Does not write below the log level' {
        $TempLogFile = Join-Path -Path $env:TEMP -ChildPath "WriteLogTest-$(New-Guid).log"
        Write-Log -Message 'Test debug message' -Level 'DEBUG' -LogFile $TempLogFile -LogLevel 'INFO'
        $Content = Get-Content -Path $TempLogFile
        ($Content | Where-Object { $_ -match '\[DEBUG\]' }).Count | Should -BeLessOrEqual 0
        Remove-Item -Path $TempLogFile -Force
    }
    It 'Writes a warning message to the log file' {
        $TempLogFile = Join-Path -Path $env:TEMP -ChildPath "WriteLogTest-$(New-Guid).log"
        Write-Log -Message 'Test warning message' -Level 'WARN' -LogFile $TempLogFile
        $Content = Get-Content -Path $TempLogFile
        ($Content | Where-Object { $_ -match '\[WARN\]' }).Count | Should -BeGreaterThan 0
        Remove-Item -Path $TempLogFile -Force
    }

    It 'Writes an error message to the log file' {
        $TempLogFile = Join-Path -Path $env:TEMP -ChildPath "WriteLogTest-$(New-Guid).log"
        Write-Log -Message 'Test error message' -Level 'ERROR' -LogFile $TempLogFile
        $Content = Get-Content -Path $TempLogFile
        ($Content | Where-Object { $_ -match '\[ERROR\]' }).Count | Should -BeGreaterThan 0
        Remove-Item -Path $TempLogFile -Force
    }

    It 'Creates a log file header on first call' {
        $TempLogFile = Join-Path -Path $env:TEMP -ChildPath "WriteLogTest-$(New-Guid).log"
        Write-Log -Message 'Header test' -Level 'INFO' -LogFile $TempLogFile
        $Content = Get-Content -Path $TempLogFile
        ($Content | Where-Object { $_ -match '\[INFO\]' }).Count | Should -BeGreaterThan 0
        Remove-Item -Path $TempLogFile -Force
    }

    It 'Does not write empty message if first call' {
        $TempLogFile = Join-Path -Path $env:TEMP -ChildPath "WriteLogTest-$(New-Guid).log"
        Write-Log -Message '' -Level 'INFO' -LogFile $TempLogFile
        $Content = Get-Content -Path $TempLogFile
        ($Content | Where-Object { $_ -ne '' }).Count | Should -BeGreaterThan 0
        Remove-Item -Path $TempLogFile -Force
    }

    It 'Throws when log file path is invalid' {
        { Write-Log -Message 'Test' -Level 'INFO' -LogFile 'Z:\Invalid\Path\log.txt' -ErrorAction Stop } | Should -Throw
    }
}


Describe 'New-FunctionToClip' {
    It 'Copies a simple function to clipboard' {
        Set-ClipBoard -Value ''
        New-FunctionToClip -Name 'Get-TestFunction' -Simple
        $Clipboard = Get-Clipboard
        ($Clipboard | Where-Object { $_ -match '^Function Get-TestFunction' }).Count | Should -BeGreaterThan 0
    }

    It 'Warns on invalid function name' {
        $WarningMessages = $null
        New-FunctionToClip -Name 'Invalid-FunctionName' -WarningVariable WarningMessages
        $WarningMessages[0].Message -eq "The verb 'Invalid' is not a valid PowerShell verb. Please use a valid verb." | Should -Be $true
    }

    It 'Allows invalid name with Force' {
        Set-ClipBoard -Value ''
        New-FunctionToClip -Name 'InvalidName' -Force
        $Clipboard = Get-Clipboard
        ($Clipboard | Where-Object { $_ -match '^Function InvalidName' }).Count | Should -BeGreaterThan 0
    }
}

Describe 'New-ClassToClip' {
    It 'Copies a class to clipboard' {
        Set-ClipBoard -Value ''
        New-ClassToClip -Name 'TestClass'
        $Clipboard = Get-Clipboard
        ($Clipboard | Where-Object { $_ -match '^Class TestClass' }).Count | Should -BeGreaterThan 0
    }

    It 'Warns on invalid class name' {
        $WarningMessages = $null
        New-ClassToClip -Name 'invalid-Class' -WarningVariable WarningMessages
        $WarningMessages[0].Message -eq "The class name 'invalid-Class' is not a valid class name. It should contain only alphanumeric characters." | Should -Be $true
    }
}