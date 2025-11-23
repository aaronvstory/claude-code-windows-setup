#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Automated installer for Claude Code Windows portable setup

.DESCRIPTION
    Installs Claude Code with win-claude-code wrapper and enhanced launchers.
    Configures environment, registers context menu, and verifies installation.

.NOTES
    Version: 1.0.0
    Requires: Administrator privileges for context menu registration
    Platform: Windows 10/11
#>

param(
    [switch]$SkipContextMenu,
    [switch]$SkipNpmInstall,
    [string]$ClaudeVersion = "2.0.50",
    [string]$WrapperVersion = "1.0.7"
)

$ErrorActionPreference = 'Stop'

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Failure { Write-Host $args -ForegroundColor Red }

function Write-Header($text) {
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host ""
}

function Test-Prerequisites {
    Write-Header "Checking Prerequisites"

    $allGood = $true

    # Check Node.js
    Write-Info "Checking Node.js..."
    try {
        $nodeVersion = & node --version 2>&1
        if ($nodeVersion -match 'v(\d+)\.') {
            $major = [int]$Matches[1]
            if ($major -ge 22) {
                Write-Success "  ✓ Node.js $nodeVersion (OK)"
            } else {
                Write-Failure "  ✗ Node.js $nodeVersion (need v22+)"
                $allGood = $false
            }
        }
    } catch {
        Write-Failure "  ✗ Node.js not found"
        Write-Warning "    Download: https://nodejs.org/"
        $allGood = $false
    }

    # Check npm
    Write-Info "Checking npm..."
    try {
        $npmVersion = & npm --version 2>&1
        Write-Success "  ✓ npm $npmVersion"
    } catch {
        Write-Failure "  ✗ npm not found"
        $allGood = $false
    }

    # Check Git for Windows (optional but recommended)
    Write-Info "Checking Git for Windows..."
    $gitPath = "C:\Program Files\Git\usr\bin\bash.exe"
    if (Test-Path $gitPath) {
        Write-Success "  ✓ Git Bash found at $gitPath"
    } else {
        Write-Warning "  ⚠ Git Bash not found (optional but recommended)"
        Write-Warning "    Download: https://git-scm.com/download/win"
        Write-Warning "    Unix commands (grep, find, awk, sed) won't work without it"
    }

    # Check PowerShell version
    Write-Info "Checking PowerShell..."
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -ge 7) {
        Write-Success "  ✓ PowerShell $psVersion"
    } elseif ($psVersion.Major -ge 5) {
        Write-Warning "  ⚠ Windows PowerShell $psVersion (PowerShell 7+ recommended)"
        Write-Warning "    Download: https://github.com/PowerShell/PowerShell/releases"
    } else {
        Write-Failure "  ✗ PowerShell too old: $psVersion"
        $allGood = $false
    }

    # Check admin privileges
    Write-Info "Checking administrator privileges..."
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Write-Success "  ✓ Running as Administrator"
    } else {
        Write-Warning "  ⚠ Not running as Administrator"
        Write-Warning "    Context menu registration will be skipped"
        $script:SkipContextMenu = $true
    }

    Write-Host ""

    if (-not $allGood) {
        Write-Failure "Prerequisites check failed. Please install missing components."
        exit 1
    }

    Write-Success "All prerequisites satisfied!"
    return $true
}

function Install-NpmPackages {
    if ($SkipNpmInstall) {
        Write-Info "Skipping npm install (--SkipNpmInstall flag)"
        return
    }

    Write-Header "Installing npm Packages"

    Write-Info "Installing @anthropic-ai/claude-code@$ClaudeVersion..."
    try {
        & npm install -g "@anthropic-ai/claude-code@$ClaudeVersion" --ignore-scripts
        Write-Success "  ✓ Claude Code installed"
    } catch {
        Write-Failure "  ✗ Failed to install Claude Code"
        Write-Failure "    Error: $_"
        exit 1
    }

    Write-Info "Installing win-claude-code@$WrapperVersion..."
    try {
        & npm install -g "win-claude-code@$WrapperVersion"
        Write-Success "  ✓ win-claude-code installed"
    } catch {
        Write-Failure "  ✗ Failed to install win-claude-code"
        Write-Failure "    Error: $_"
        exit 1
    }

    Write-Host ""
    Write-Info "Verifying installations..."

    $claudeInstalled = & npm list -g @anthropic-ai/claude-code 2>&1 | Select-String -Pattern "@anthropic-ai/claude-code@"
    $wrapperInstalled = & npm list -g win-claude-code 2>&1 | Select-String -Pattern "win-claude-code@"

    if ($claudeInstalled) {
        Write-Success "  ✓ $claudeInstalled"
    } else {
        Write-Failure "  ✗ Claude Code verification failed"
    }

    if ($wrapperInstalled) {
        Write-Success "  ✓ $wrapperInstalled"
    } else {
        Write-Failure "  ✗ win-claude-code verification failed"
    }

    Write-Success "`nPackages installed successfully!"
}

function Deploy-Launchers {
    Write-Header "Deploying Launchers"

    $targetDir = "C:\claude\launchers\right-click"
    $sourceDir = Join-Path $PSScriptRoot "..\launchers"

    Write-Info "Target directory: $targetDir"
    Write-Info "Source directory: $sourceDir"

    if (-not (Test-Path $sourceDir)) {
        Write-Failure "  ✗ Source launchers directory not found: $sourceDir"
        exit 1
    }

    # Create target directory
    Write-Info "Creating target directory..."
    try {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Write-Success "  ✓ Directory created/verified"
    } catch {
        Write-Failure "  ✗ Failed to create directory: $_"
        exit 1
    }

    # Copy launchers
    Write-Info "Copying launcher files..."
    try {
        $files = Get-ChildItem -Path $sourceDir -Filter "*.ps1", "*.bat" -File
        $fileCount = $files.Count

        if ($fileCount -eq 0) {
            Write-Warning "  ⚠ No launcher files found in $sourceDir"
            return
        }

        foreach ($file in $files) {
            Copy-Item -Path $file.FullName -Destination $targetDir -Force
            Write-Success "  ✓ $($file.Name)"
        }

        Write-Success "`n$fileCount files deployed successfully!"
    } catch {
        Write-Failure "  ✗ Failed to copy files: $_"
        exit 1
    }
}

function Register-ContextMenu {
    if ($SkipContextMenu) {
        Write-Info "`nSkipping context menu registration (no admin privileges or --SkipContextMenu flag)"
        return
    }

    Write-Header "Registering Context Menu"

    $launcherPath = "C:\claude\launchers\right-click\claude-code-clean-launcher.bat"

    if (-not (Test-Path $launcherPath)) {
        Write-Failure "  ✗ Launcher not found: $launcherPath"
        Write-Failure "    Deploy launchers first"
        return
    }

    try {
        # Register for folders
        Write-Info "Registering for folder context menu..."

        $keyPath = "Registry::HKEY_CLASSES_ROOT\Directory\shell\ClaudeCode"

        # Remove existing if present
        if (Test-Path $keyPath) {
            Remove-Item -Path $keyPath -Recurse -Force
        }

        # Create new keys
        New-Item -Path $keyPath -Force | Out-Null
        Set-ItemProperty -Path $keyPath -Name "(Default)" -Value "Open with Claude Code"
        Set-ItemProperty -Path $keyPath -Name "Icon" -Value "C:\Windows\System32\imageres.dll,190"

        New-Item -Path "$keyPath\command" -Force | Out-Null
        Set-ItemProperty -Path "$keyPath\command" -Name "(Default)" -Value "`"$launcherPath`" `"%V`""

        Write-Success "  ✓ Folder context menu registered"

        # Register for background (inside folder)
        Write-Info "Registering for folder background context menu..."

        $bgKeyPath = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\ClaudeCode"

        if (Test-Path $bgKeyPath) {
            Remove-Item -Path $bgKeyPath -Recurse -Force
        }

        New-Item -Path $bgKeyPath -Force | Out-Null
        Set-ItemProperty -Path $bgKeyPath -Name "(Default)" -Value "Open with Claude Code"
        Set-ItemProperty -Path $bgKeyPath -Name "Icon" -Value "C:\Windows\System32\imageres.dll,190"

        New-Item -Path "$bgKeyPath\command" -Force | Out-Null
        Set-ItemProperty -Path "$bgKeyPath\command" -Name "(Default)" -Value "`"$launcherPath`" `"%V`""

        Write-Success "  ✓ Folder background context menu registered"

        Write-Success "`nContext menu registered successfully!"
        Write-Info "Right-click any folder → 'Open with Claude Code'"

    } catch {
        Write-Failure "  ✗ Failed to register context menu: $_"
        Write-Warning "    You may need to run this script as Administrator"
    }
}

function Test-Installation {
    Write-Header "Testing Installation"

    Write-Info "Testing win-claude-code command..."
    try {
        $output = & win-claude-code --version 2>&1 | Out-String
        if ($output -match '\d+\.\d+\.\d+') {
            Write-Success "  ✓ win-claude-code works: $($Matches[0])"
        } else {
            Write-Warning "  ⚠ win-claude-code responded but version unclear"
        }
    } catch {
        Write-Failure "  ✗ win-claude-code command failed"
        Write-Failure "    Error: $_"
        Write-Warning "    You may need to restart your terminal"
    }

    Write-Info "Checking launcher exists..."
    $launcherPath = "C:\claude\launchers\right-click\claude-code-clean-launcher.bat"
    if (Test-Path $launcherPath) {
        Write-Success "  ✓ Primary launcher found: $launcherPath"
    } else {
        Write-Failure "  ✗ Launcher not found: $launcherPath"
    }

    Write-Success "`nInstallation test complete!"
}

function Show-Summary {
    Write-Header "Installation Summary"

    Write-Host "✅ Claude Code Windows setup completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart your terminal (to refresh PATH)" -ForegroundColor White
    Write-Host "  2. Navigate to a project folder" -ForegroundColor White
    Write-Host "  3. Right-click → 'Open with Claude Code'" -ForegroundColor White
    Write-Host ""
    Write-Host "Or run directly:" -ForegroundColor Cyan
    Write-Host "  C:\claude\launchers\right-click\claude-code-clean-launcher.bat" -ForegroundColor White
    Write-Host ""
    Write-Host "Documentation:" -ForegroundColor Cyan
    Write-Host "  README.md - Usage guide" -ForegroundColor White
    Write-Host "  docs\WINDOWS_SETUP_GUIDE.md - Technical details" -ForegroundColor White
    Write-Host "  docs\TROUBLESHOOTING.md - Common issues" -ForegroundColor White
    Write-Host ""
    Write-Host "Installed versions:" -ForegroundColor Cyan

    $claudeVer = & npm list -g @anthropic-ai/claude-code 2>&1 | Select-String -Pattern "@(\d+\.\d+\.\d+)"
    $wrapperVer = & npm list -g win-claude-code 2>&1 | Select-String -Pattern "@(\d+\.\d+\.\d+)"

    if ($claudeVer -match '@([\d\.]+)') {
        Write-Host "  @anthropic-ai/claude-code: $($Matches[1])" -ForegroundColor White
    }
    if ($wrapperVer -match '@([\d\.]+)') {
        Write-Host "  win-claude-code: $($Matches[1])" -ForegroundColor White
    }

    Write-Host ""
}

# Main installation flow
try {
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor Magenta
    Write-Host "  Claude Code Windows - Automated Installer v1.0.0" -ForegroundColor Magenta
    Write-Host ("=" * 70) -ForegroundColor Magenta
    Write-Host ""

    Test-Prerequisites
    Install-NpmPackages
    Deploy-Launchers
    Register-ContextMenu
    Test-Installation
    Show-Summary

    Write-Host ""
    Write-Success "Installation completed successfully! 🎉"
    Write-Host ""

} catch {
    Write-Host ""
    Write-Failure "Installation failed: $_"
    Write-Host ""
    Write-Host "Please check the error messages above and try again." -ForegroundColor Yellow
    Write-Host "For help, see docs\TROUBLESHOOTING.md" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
