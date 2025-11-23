param(
  [string]$TargetPath
)

# -------------------------------
# Claude Code Rust Launcher (PowerShell)
# Native Rust Binary - Simplified Setup
# -------------------------------

# Use 'Continue' to show errors but keep running
# This prevents the window from closing on errors
$ErrorActionPreference = 'Continue'

function Write-Header($title) {
  Write-Host ('=' * 63)
  Write-Host ("   {0}" -f $title)
  Write-Host ('=' * 63)
  Write-Host
}

function Get-EnvFromRegistry([string]$Name) {
  try {
    $item = Get-ItemProperty -Path 'HKCU:\Environment' -ErrorAction Stop
    return ($item.$Name)
  }
  catch { return $null }
}

# Check if path is a WSL UNC path and redirect to WSL launcher if so
if ($TargetPath -and $TargetPath -match '^\\\\wsl') {
  Write-Host "WSL UNC path detected: $TargetPath"
  Write-Host "Redirecting to WSL launcher..."
  Write-Host

  # Hand off to WSL launcher
  $wslLauncher = Join-Path $PSScriptRoot "claude-code-wsl-launcher.ps1"
  if (Test-Path $wslLauncher) {
    & $wslLauncher $TargetPath
    exit $LASTEXITCODE
  }
  else {
    Write-Host "[ERROR] WSL launcher not found at: $wslLauncher"
    Write-Host "        Please use the WSL launcher for WSL paths"
    exit 1
  }
}

# Honor folder target (Explorer passes %V → BAT → this script as $TargetPath)
if ($TargetPath -and (Test-Path $TargetPath)) {
  Set-Location -Path $TargetPath
}

Write-Header "CLAUDE CODE LAUNCHER (RUST NATIVE - RESUME MODE)"

# Display launcher information
Write-Host "[LAUNCHER INFO]"
Write-Host ("  Batch File:  {0}\claude-code-rust-launcher-r.bat" -f $PSScriptRoot)
Write-Host ("  Script File: {0}\claude-code-rust-launcher-r.ps1" -f $PSScriptRoot)
Write-Host

# Environment setup (PowerShell style)
Write-Host "[ENVIRONMENT SETUP]"
$env:CLAUDE_CODE_WINDOWS = "true"

# Optional tokens (load from registry if not in env)
foreach ($k in @('GITHUB_TOKEN', 'BRAVE_API_KEY', 'EXA_API_KEY', 'PERPLEXITY_API_KEY')) {
  if (-not (Test-Path "env:$k")) {
    $val = Get-EnvFromRegistry $k
    if ($val) { Set-Item "env:$k" -Value $val }
  }
}

# Aliases / extras
if ($env:GITHUB_TOKEN) { $env:GITHUB_PERSONAL_ACCESS_TOKEN = $env:GITHUB_TOKEN }
$env:SUPABASE_ACCESS_TOKEN = $env:SUPABASE_ACCESS_TOKEN ?? 'YOUR_SUPABASE_TOKEN_HERE'
$env:PERPLEXITY_MODEL = $env:PERPLEXITY_MODEL ?? 'sonar'
$env:ALLOWED_DIRECTORIES = $env:ALLOWED_DIRECTORIES ?? 'C:\,F:\,G:\,H:\'
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUNBUFFERED = "1"

Write-Host "  Version: Rust Native (v2.0.34+)"
Write-Host "  Permissions: Bypass enabled"
Write-Host

# Locate Rust binary
$rustClaude = "C:\Users\d0nbx\.local\bin\claude.exe"
if (-not (Test-Path $rustClaude)) {
  Write-Host
  Write-Host ('=' * 63) -ForegroundColor Red
  Write-Host "   ERROR: Rust claude.exe NOT FOUND" -ForegroundColor Red
  Write-Host ('=' * 63) -ForegroundColor Red
  Write-Host
  Write-Host "Expected location: $rustClaude" -ForegroundColor Yellow
  Write-Host
  Write-Host "To install the Rust version:" -ForegroundColor Cyan
  Write-Host "  claude install" -ForegroundColor White
  Write-Host
  Write-Host "Window will remain open for debugging. Press Ctrl+C to close." -ForegroundColor Yellow
  Write-Host
  # Don't exit - let window stay open
  while ($true) { Start-Sleep -Seconds 60 }
}

Write-Host
Write-Host "[DIRECTORY INFO]"
Write-Host ("  Windows Path: {0}" -f (Get-Location))
Write-Host

# Launch loop with relaunch option
$continueRunning = $true
while ($continueRunning) {
  Write-Host "[LAUNCHING CLAUDE CODE (RUST - RESUME)]"
  Write-Host ("  Executable: {0}" -f $rustClaude)
  Write-Host ("  Arguments:  --dangerously-skip-permissions -r")
  Write-Host ("  Time:       {0}" -f (Get-Date))
  Write-Host ('=' * 63)

  # Run in current tab with error handling
  try {
    # Note: ERR_STREAM_DESTROYED errors during initialization are non-fatal
    # They're caused by Node.js stream initialization race conditions
    # Claude Code will launch successfully despite these errors
    & $rustClaude --dangerously-skip-permissions -r
    $exitCode = $LASTEXITCODE

    Write-Host
    Write-Host ('=' * 63)
    Write-Host "   CLAUDE CODE SESSION ENDED (RUST - RESUME)"
    Write-Host ('=' * 63)
    Write-Host ("  Exit Time: {0}" -f (Get-Date))
    Write-Host
  }
  catch {
    Write-Host
    Write-Host ('=' * 63) -ForegroundColor Red
    Write-Host "   ERROR OCCURRED" -ForegroundColor Red
    Write-Host ('=' * 63) -ForegroundColor Red
    Write-Host
    Write-Host "Error Message: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "Error Type: $($_.Exception.GetType().FullName)" -ForegroundColor Yellow
    if ($_.ScriptStackTrace) {
      Write-Host
      Write-Host "Stack Trace:" -ForegroundColor Yellow
      Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    }
    Write-Host
    $exitCode = 1
  }

  # Relaunch menu
  Write-Host
  Write-Host ('=' * 63) -ForegroundColor Cyan
  Write-Host "   RELAUNCH OPTIONS" -ForegroundColor Cyan
  Write-Host ('=' * 63) -ForegroundColor Cyan
  Write-Host
  Write-Host "  [R] Relaunch Claude Code (Rust resume mode)" -ForegroundColor Green
  Write-Host "  [X] Exit and close window" -ForegroundColor Yellow
  Write-Host
  Write-Host -NoNewline "  Your choice (R/X): " -ForegroundColor Cyan

  $choice = Read-Host

  if ($choice -match '^[Xx]$') {
    $continueRunning = $false
    Write-Host
    Write-Host "Exiting..." -ForegroundColor Yellow
  } elseif ($choice -match '^[Rr]$') {
    Write-Host
    Write-Host "Relaunching Claude Code..." -ForegroundColor Green
    Write-Host
    Write-Host ('=' * 63)
    Write-Host
  } else {
    # Default to relaunch if invalid input
    Write-Host
    Write-Host "Invalid choice. Relaunching..." -ForegroundColor Yellow
    Write-Host
    Write-Host ('=' * 63)
    Write-Host
  }
}

# Exit properly with code
exit $exitCode
