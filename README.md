# SPS-PSHelper
 a set of cmdlet that I use frequently

## Overview
This module provides a set of cmdlet that I use frequently. It is a collection of cmdlet that I use in my daily work. I will add cmdlet as I need them.

## Cmdlet
- Write-Log

## Write-Log

### Description

Allow to write a message to the console and to a log file. The log file is created if it does not exist.

If the logfile is not set it will take the default value : '%TEMP%\Write-Log-*GUID*.log'

If the Level is not set it will take the default value : 'Info'

> [!IMPORTANT]
> First call to Write-Log will set **LogLevel** and **LogFile** for the script scope. You don't need to set them for each call. 

### Syntax
```powershell
Write-Log 
    [[-Message] <String>] 
    [[-Level] <String>] 
    [[-LogFile] <String>]
    [[-LogLevel] <String>]
    [<CommonParameters>]
```
### Example 1: Init the log file and the log level and Write a message to the console and the logfile, then write a second message to the log file.

```powershell
Write-Log -Message 'This is a test message' -Level "Info" -LogFile "C:\Temp\test.log" -LogLevel "Info"
Write-Log -Message 'This is a second test message'
```
### Example 2: Init the log file 'C:\Temp\test.log' and the log level 'Info' and Write a message to the console and the logfile, then write a second debug message that should not be written to the file.

```powershell
Write-Log -Message 'This is a test message' -Level "Info" -LogFile "C:\Temp\test.log" -LogLevel "Info"
Write-Log -Message 'This is a second test message that will not be written' -Level "Debug"
```
### Parameters
**\-Message**

The message to write to the console and the log file.

    Type: String
    Mandatory: False
    Position: 0

**\-Level**

The level of the message. The default is 'Info'

    Type: String
    Mandatory: False
    Position: 1

**\-LogFile**

The path of the log file. The default is '%TEMP%\Write-Log-*GUID*.log'

    Type: String
    Mandatory: False
    Position: 2

**\-LogLevel**

The level of the log file. The default is 'Info'

    Type: String
    Mandatory: False
    Position: 3