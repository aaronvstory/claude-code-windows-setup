# Run as Administrator
# Removes duplicate ClaudeCodeWSL registry entry

Write-Host "Removing duplicate ClaudeCodeWSL entry from Directory\shell..." -ForegroundColor Yellow
Write-Host

try {
    Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\ClaudeCodeWSL" -Recurse -Force -ErrorAction Stop
    Write-Host "[OK] Successfully removed duplicate entry!" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to remove: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "You may need to run this script as Administrator." -ForegroundColor Yellow
}

Write-Host
Read-Host "Press Enter to close"
