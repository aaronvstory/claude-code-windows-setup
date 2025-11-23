@echo off
setlocal

:: ================================================
:: Claude Launcher - Mimics Double-Click Behavior
:: ================================================
:: This should work exactly like double-clicking a .bat
:: Opens in Terminal with tabs working correctly
:: ================================================

:: Find PowerShell 7
for /f "delims=" %%I in ('where pwsh.exe 2^>nul') do set "PWSH=%%I"
if not defined PWSH set "PWSH=%ProgramFiles%\PowerShell\7\pwsh.exe"

:: Hand off to PowerShell script
:: No wt.exe wrapper - let Windows Terminal handle it automatically
"%PWSH%" -NoProfile -NoLogo -File "C:\claude\launchers\right-click\claude-code-clean-launcher.ps1" "%~1"
