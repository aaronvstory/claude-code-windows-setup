@echo off
echo Removing duplicate ClaudeCodeWSL entry from Directory\shell...
echo.

reg delete "HKCR\Directory\shell\ClaudeCodeWSL" /f

if %errorlevel% equ 0 (
    echo [OK] Successfully removed duplicate entry!
) else (
    echo [ERROR] Failed to remove. You may need to run as Administrator.
)

echo.
pause
