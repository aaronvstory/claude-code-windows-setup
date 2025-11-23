@echo off
setlocal

:: ================================================
:: Claude Launcher - Windows Terminal Fix
:: ================================================
:: Launches in existing Terminal window (no new window!)
:: Uses: wt.exe -w 0 to target existing window
:: ================================================

:: Find PowerShell 7 first (like original launcher)
for /f "delims=" %%I in ('where pwsh.exe 2^>nul') do set "PWSH=%%I"
if not defined PWSH set "PWSH=%ProgramFiles%\PowerShell\7\pwsh.exe"

:: Check if pwsh exists
if not exist "%PWSH%" (
    echo ERROR: PowerShell 7 not found!
    pause
    exit /b 1
)

:: Launch in existing Terminal window (window ID 0)
wt.exe -w 0 "%PWSH%" -NoProfile -NoLogo -File "C:\claude\launchers\right-click\claude-code-clean-launcher.ps1" "%~1"
