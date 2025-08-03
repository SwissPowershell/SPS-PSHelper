# SPS-PSHelper
 a set of cmdlet that I use frequently

## Overview
This module provides a set of cmdlet that I use frequently. It is a collection of cmdlet that I use in my daily work. I will add cmdlet as I need them.

## Cmdlet
- Write-Log
- New-FunctionToClip
- New-ClassToClip

## Write-Log

### Description

Allow to write a message to the console and to a log file. The log file is created if it does not exist.

If the logfile is not set it will take the default value : '%TEMP%\Write-Log-*GUID*.log'

If the Level is not set it will take the default value : 'Info'

> [!IMPORTANT]
> First call to Write-Log will set **LogLevel** and **LogFile** for the script scope. 

> [!IMPORTANT]
> First call to Write-Log in the script scope will add a HEADER to the log file.

> [!IMPORTANT]
> You don't need to set them for each call. 

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

The path of the log file. The default is '%TEMP%\Write-Log-*GUID*.log'. If LogFile is set will set the LogFile for the script scope.

    Type: String
    Mandatory: False
    Position: 2

**\-LogLevel**

The level of the log file. The default is **'Info'**. The log file will only contain message with a level equal or higher than the LogLevel. Loglevel can be 'Info', 'Debug', 'Warning', 'Error'. if Loglevel is set will set the LogLevel for the script scope.

    Type: String
    Mandatory: False
    Position: 3
### Common Parameters
This cmdlet supports the common parameters: `-Verbose`, `-Debug`, `-ErrorAction`, `-WarningAction`, `-ErrorVariable`, `-OutVariable`, and `-OutBuffer`. For more information, see [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## New-FunctionToClip
### Description
This cmdlet creates a new PowerShell function and copies the code to the clipboard. The function is a template that can be used to create a new function quickly. The function will have a name. The function will also have a parameter for the name of the function. If the `-Simple` switch is used, the function will be created with a simple template without parameters and help message.
### Syntax
```powershell
New-FunctionToClip
    [[-Name] <String>]
    [[-Simple] <Switch>]
    [[-Force] <Switch>]
    [<CommonParameters>]
```
### Example 1: Create a new function and copy the code to the clipboard
```powershell
New-FunctionToClip -Name 'MyNewFunction'
```
### Example 2: Create a new function with a custom name and copy the code to the clipboard
```powershell
New-FunctionToClip -Name 'CustomFunctionName'
```
### Parameters
**\-Name**

The name of the function to create.

    Type: String
    Mandatory: False
    Position: 0

**\-Simple**
If specified, the function will be created with a simple template without parameters and help message.

    Type: Switch
    Mandatory: False
    Position: 1

**\-Force**
If specified, skips the validation of the function name and allows any name to be used.
    Type: Switch
    Mandatory: False
    Position: 2
### Common Parameters
This cmdlet supports the common parameters: `-Verbose`, `-Debug`, `-ErrorAction`, `-WarningAction`, `-ErrorVariable`, `-OutVariable`, and `-OutBuffer`. For more information, see [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).
## New-ClassToClip
### Description
This cmdlet creates a new PowerShell class and copies the code to the clipboard. The class is a template that can be used to create a new class quickly.
### Syntax
```powershell
New-ClassToClip
    [[-Name] <String>]
    [<CommonParameters>]
```
### Example 1: Create a new class and copy the code to the clipboard
```powershell
New-ClassToClip -Name 'MyNewClass'
```
### Example 2: Create a new class with a custom name and copy the code to the clipboard
```powershell
New-ClassToClip -Name 'CustomClassName'
```
### Parameters
**\-Name**
The name of the class to create. It should start with an uppercase letter and contain only alphanumeric characters.
    Type: String
    Mandatory: False
    Position: 0
### Common Parameters
This cmdlet supports the common parameters: `-Verbose`, `-Debug`, `-ErrorAction`, `-WarningAction`, `-ErrorVariable`, `-OutVariable`, and `-OutBuffer`. For more information, see [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

