@echo off
echo Checking for Claude Code context menu entries...
echo.

echo === Checking Directory Background Shell ===
reg query "HKCR\Directory\background\shell" | findstr /i "claude"
echo.

echo === Checking Directory Shell ===
reg query "HKCR\Directory\shell" | findstr /i "claude"
echo.

echo === Full Claude Code WSL Entry ===
reg query "HKCR\Directory\background\shell\ClaudeCodeWSL" /s
echo.

pause
