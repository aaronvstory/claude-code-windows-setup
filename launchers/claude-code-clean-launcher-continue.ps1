param(
  [string]$TargetPath
)

# -------------------------------
# Claude Code Resume Launcher (PowerShell)
# -------------------------------

# Use 'Continue' to show errors but keep running
$ErrorActionPreference = 'Continue'

function Write-Header($title) {
  Write-Host ('=' * 63)
  Write-Host ("   {0}" -f $title)
  Write-Host ('=' * 63)
  Write-Host
}

function Add-GitToPath {
  # ONLY use Program Files Git - Scoop Git bash is BROKEN
  # Scoop's bash.exe has hardcoded incorrect path references
  # When bash runs commands, it looks in ../bin/ instead of current directory
  # This causes "cannot execute: required file not found" errors for cygpath, which, etc.
  # Solution: Exclude Scoop Git from PATH entirely
  $candidates = @(
    "C:\Program Files\Git\usr\bin",
    "C:\Program Files\Git\bin"
    # Scoop Git paths REMOVED - bash is broken
  )
  foreach ($p in $candidates) {
    if (Test-Path $p) {
      if (-not ($env:PATH -split ';' | Where-Object { $_ -ieq $p })) {
        $env:PATH = $p + ';' + $env:PATH
      }
    }
  }
}

function Get-EnvFromRegistry([string]$Name) {
  try {
    $item = Get-ItemProperty -Path 'HKCU:\Environment' -ErrorAction Stop
    return ($item.$Name)
  }
  catch { return $null }
}

function Ensure-McpModuleJunction {
  $src = Join-Path $env:APPDATA 'npm\node_modules\@anthropic-ai\claude-code'
  $dst = Join-Path $HOME '.mcp-modules\node_modules\@anthropic-ai\claude-code'

  if (-not (Test-Path $src)) { return }

  $dstParent = Split-Path $dst -Parent
  if (-not (Test-Path $dstParent)) {
    New-Item -ItemType Directory -Path $dstParent | Out-Null
  }

  if (-not (Test-Path $dst)) {
    try {
      # Use a junction to avoid admin privileges for symlinks
      New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
      Write-Host "  Fixed: MCP module path linked (junction)"
    }
    catch {
      Write-Host "  Note: Couldn't create junction (non-fatal): $($_.Exception.Message)"
    }
  }
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

Write-Header "CLAUDE CODE RESUME LAUNCHER (PATCH-1 ENHANCED)"

# Display launcher information
Write-Host "[LAUNCHER INFO]"
Write-Host ("  Batch File:  {0}\claude-code-clean-launcher-continue.bat" -f $PSScriptRoot)
Write-Host ("  Script File: {0}\claude-code-clean-launcher-continue.ps1" -f $PSScriptRoot)
Write-Host

# Environment setup (PowerShell style)
Write-Host "[ENVIRONMENT SETUP]"
$env:CLAUDE_FLOW_WINDOWS_TRANSLATION = "true"
$env:CLAUDE_FLOW_USE_POWERSHELL = "true"
$env:CLAUDE_FLOW_HOOKS_ENABLED = "true"
$env:CLAUDE_CODE_WINDOWS = "true"

$env:MSYS_NO_PATHCONV = "1"
$env:MSYS2_ARG_CONV_EXCL = "*"
$env:MSYS2_PATH_TYPE = "inherit"
$env:CYGWIN = "nodosfilewarning"
$env:MSYS_PATH_CONVERT_DISABLE = "1"
$env:MSYS2_ENV_CONV_EXCL = "MSYS2_ARG_CONV_EXCL"

$env:BASH_DISABLE_TIMEOUT = "1"
$env:SHELL_NO_TIMEOUT = "1"

$env:CLAUDE_DANGEROUSLY_SKIP_PERMISSIONS = "true"

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

# Image/Clipboard helpers
$env:CLAUDE_IMAGE_PATH_WINDOWS = $env:TEMP
$env:CLAUDE_TRANSLATE_MACOS_PATHS = "true"
$env:CLAUDE_TEMP_PATH_OVERRIDE = $env:TEMP

# Add Git (if present)
Add-GitToPath

Write-Host "  Translation: Windows path translation enabled"
Write-Host "  Permissions: Bypass enabled"
Write-Host "  Memory: 32GB heap (--max-old-space-size=32768)"
Write-Host

# Locate CLI (using patch-1 runner for Windows enhancements)
$cli = Join-Path $env:APPDATA 'npm\node_modules\win-claude-code\runner.js'
if (-not (Test-Path $cli)) {
  Write-Host
  Write-Host ('=' * 63) -ForegroundColor Red
  Write-Host "   ERROR: win-claude-code (patch-1) NOT FOUND" -ForegroundColor Red
  Write-Host ('=' * 63) -ForegroundColor Red
  Write-Host
  Write-Host "Expected location: $cli" -ForegroundColor Yellow
  Write-Host
  Write-Host "To install:" -ForegroundColor Cyan
  Write-Host "  npm install -g phylonyus/win-claude-code#patch-1" -ForegroundColor White
  Write-Host
  Write-Host "Window will remain open for debugging. Press Ctrl+C to close." -ForegroundColor Yellow
  Write-Host
  while ($true) { Start-Sleep -Seconds 60 }
}

# MCP junction fix (non-fatal if it fails)
Ensure-McpModuleJunction

Write-Host
Write-Host "[DIRECTORY INFO]"
Write-Host ("  Windows Path: {0}" -f (Get-Location))
Write-Host

# Launch loop with relaunch option
$continueRunning = $true
while ($continueRunning) {
  Write-Host "[LAUNCHING CLAUDE CODE - RESUME MODE]"
  Write-Host ("  Command: node win-claude-code/runner.js (patch-1) --dangerously-skip-permissions -r")
  Write-Host ("  Enhancements: Git Bash integration, path conversion, Windows optimizations")
  Write-Host ("  Time:    {0}" -f (Get-Date))
  Write-Host ('=' * 63)

  # Run in current tab with error handling
  try {
    # Note: ERR_STREAM_DESTROYED errors during initialization are non-fatal
    # They're caused by Node.js stream initialization race conditions
    # Claude Code will launch successfully despite these errors
    & node --max-old-space-size=32768 $cli --dangerously-skip-permissions -r
    $exitCode = $LASTEXITCODE

    Write-Host
    Write-Host ('=' * 63)
    Write-Host "   CLAUDE CODE SESSION ENDED"
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
  Write-Host "  [R] Relaunch Claude Code (continue mode)" -ForegroundColor Green
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
