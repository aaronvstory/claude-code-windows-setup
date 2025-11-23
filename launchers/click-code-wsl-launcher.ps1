param([string]$TargetPath = "")

# Get target path
$WindowsPath = if ($TargetPath -and (Test-Path $TargetPath)) {
    $TargetPath
} else {
    Get-Location
}

# Convert Windows path to WSL format
$normalized = $WindowsPath.Replace("\", "/")
if ($normalized -match "^([A-Za-z]):(.*)") {
    $drive = $matches[1].ToLower()
    $path = $matches[2]
    $WSLPath = "/mnt/$drive$path"
} else {
    $WSLPath = $normalized
}

Write-Host "Opening Claude Code in WSL..." -ForegroundColor Green
Write-Host "Path: $WindowsPath → $WSLPath" -ForegroundColor Gray

# Create a temporary WSL command that handles quotes properly
$cmd = "cd '$WSLPath' && bash -l -c 'command -v cc >/dev/null 2>&1 && cc . || code .'"

# Call WSL directly (no Windows Terminal layer)
Start-Process wsl.exe -ArgumentList "bash", "-l", "-c", $cmd -NoNewWindow

Write-Host "✓ Claude Code launched in WSL" -ForegroundColor Green
