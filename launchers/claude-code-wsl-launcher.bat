@echo off
setlocal

:: 1. Find PowerShell 7 (pwsh.exe)
for /f "delims=" %%I in ('where pwsh.exe 2^>nul') do set "PWSH=%%I"
if not defined PWSH set "PWSH=%ProgramFiles%\PowerShell\7\pwsh.exe"

:: 2. Check if PowerShell was found, using corrected syntax for the 'echo' command.
if not exist "%PWSH%" (
    echo ERROR: PowerShell 7 ^(pwsh.exe^) could not be found.
    echo Please install it or correct the path in this script.
    pause
    exit /b 1
)

:: 3. Hand off to the PowerShell script.
"%PWSH%" -NoProfile -NoLogo -ExecutionPolicy Bypass -File "C:\claude\launchers\right-click\claude-code-wsl-launcher.ps1" "%~1"
