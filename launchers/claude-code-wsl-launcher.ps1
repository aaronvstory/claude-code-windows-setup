param(
  [string]$TargetPath
)

$ErrorActionPreference = 'Stop'

# This function converts a Windows path (e.g., C:\Users\Me) to a WSL path (e.g., /mnt/c/Users/Me)
# This is NOT needed for the -d flag, which expects a Windows path.
# We are keeping the WSL path conversion only for display purposes.
function Convert-WindowsPathToWSL([string]$WindowsPath) {
  if (-not $WindowsPath) { return "~" }

  # Handle WSL UNC paths (\\wsl.localhost\Ubuntu\path -> /path)
  if ($WindowsPath -match '^\\\\wsl\.localhost\\([^\\]+)\\(.*)$') {
    $distro = $matches[1]
    $pathPart = $matches[2].Replace('\', '/')
    return "/$pathPart"
  }

  # Handle regular Windows paths (C:\path -> /mnt/c/path)
  $normalized = $WindowsPath.Replace('\', '/')
  if ($normalized -match '^([A-Za-z]):(.*)$') {
    $driveLetter = $matches[1].ToLower()
    $pathPart = $matches[2]
    return "/mnt/$driveLetter$pathPart"
  }
  return $normalized
}

# Determine the correct Windows path to use
$windowsPath = $TargetPath
if (-not $windowsPath -or -not (Test-Path $windowsPath)) {
  $windowsPath = (Get-Location).Path
}

# We still convert to a WSL path just to show the user for clarity.
$wslPath = Convert-WindowsPathToWSL $windowsPath

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   CLAUDE CODE WSL LAUNCHER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host
Write-Host "Target Windows Path: $windowsPath" -ForegroundColor Yellow
Write-Host "Equivalent WSL Path: $wslPath" -ForegroundColor Yellow
Write-Host

try {
  # THE FINAL, CORRECT, AND SIMPLEST METHOD:
  # We use Windows Terminal's own '--startingDirectory' flag.
  # This flag correctly handles the path and starts the default profile's shell in that directory.
  # It expects a Windows path, which simplifies the logic significantly.
  $wt_ArgumentList = @(
    "new-tab",
    "--profile", "Ubuntu",
    "--startingDirectory", $windowsPath # <-- The key change. Use the Windows path directly.
  )

  Start-Process "wt.exe" -ArgumentList $wt_ArgumentList

  Write-Host "✅ Windows Terminal launched!" -ForegroundColor Green
  Write-Host "   The new tab will start in the correct directory." -ForegroundColor Cyan
  Write-Host "   You can now type 'cc' and press Enter." -ForegroundColor Cyan

} catch {
  # If anything fails, keep the window open to show the error.
  Write-Host "❌ FAILED TO LAUNCH WSL" -ForegroundColor Red
  Write-Host $_.Exception.Message -ForegroundColor Red
  Read-Host "Press Enter to exit"
  exit 1
}

# Give the user a moment to read the success message.
Start-Sleep -Seconds 5
