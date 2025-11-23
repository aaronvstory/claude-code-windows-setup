@echo off
setlocal

:: ================================================
:: Claude Launcher - Windows Terminal Fix (Alternative)
:: ================================================
:: Uses -w _quake instead of -w 0
:: Sometimes works better depending on Terminal config
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

:: Launch using _quake window mode
wt.exe -w _quake "%PWSH%" -NoProfile -NoLogo -File "C:\claude\launchers\right-click\claude-code-clean-launcher.ps1" "%~1"
