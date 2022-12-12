::
:: This script will first create a backup of the original or the current hosts
:: file and save it in a file named "hosts.skel".
::
:: If the "hosts.skel" file exists, the new hosts file with the customized unified
:: hosts will be copied to the proper path. Next, the DNS cache will be refreshed.
::
:: THIS BAT FILE MUST BE LAUNCHED WITH ADMINISTRATOR PRIVILEGES
:: Admin privileges script based on https://stackoverflow.com/a/10052222
::

@echo off
setlocal
title Update Hosts

set "calcs_executable=%SYSTEMROOT%\SysWOW64\cacls.exe"
set "calcs_file=%SYSTEMROOT%\system32\config\system"

:: Check if we are an administrator. If not, exit immediately.
:: BatchGotAdmin
:: Check for permissions
if "%PROCESSOR_ARCHITECTURE%" equ "amd64" (
    >nul 2>&1 "%calcs_executable%" "%calcs_file%"
) else (
    >nul 2>&1 "%calcs_executable%" "%calcs_file%"
)

:: If the error flag set, we do not have admin rights.
if %ERRORLEVEL% neq 0 (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\getadmin.vbs"
set params= %*
echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%TEMP%\getadmin.vbs"

wscript.exe "%TEMP%\getadmin.vbs"
del "%TEMP%\getadmin.vbs"
exit /b

:gotAdmin
cd /d "%~dp0"

:BackupHosts
:: Backup the default hosts file
if not exist "%WINDIR%\System32\drivers\etc\hosts.skel" (
    copy /v "%WINDIR%\System32\drivers\etc\hosts" "%WINDIR%\System32\drivers\etc\hosts.skel"
)

:UpdateHosts
:: Update hosts file
py updateHostsFile.py --auto --minimise %*

:: Copy over the new hosts file in-place
copy /y /v hosts "%WINDIR%\System32\drivers\etc\"

:: Flush the DNS cache
ipconfig /flushdns

:: Summary note
pause
