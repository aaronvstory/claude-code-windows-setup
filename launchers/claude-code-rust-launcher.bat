@echo off
setlocal

:: Find PowerShell 7
for /f "delims=" %%I in ('where pwsh.exe 2^>nul') do set "PWSH=%%I"
if not defined PWSH set "PWSH=%ProgramFiles%\PowerShell\7\pwsh.exe"

:: Hand off to PowerShell script (Terminal will host PowerShell, not cmd)
:: Removed -NoExit to fix ERR_STREAM_DESTROYED error
"%PWSH%" -NoProfile -NoLogo -File "C:\claude\launchers\right-click\claude-code-rust-launcher.ps1" "%~1"

:: Capture exit code and pause on error
if errorlevel 1 (
    echo.
    echo ERROR: Launcher exited with code %ERRORLEVEL%
    echo Press any key to close...
    pause >nul
)
