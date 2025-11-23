# Claude Code for Windows - Production-Ready Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue.svg)](https://www.microsoft.com/windows)
[![Node Version](https://img.shields.io/badge/Node.js-22%2B-green.svg)](https://nodejs.org/)

**A complete, plug-and-play Claude Code installation for Windows that actually works.**

Solves path translation, Git Bash integration, MSYS mangling, and 8+ other Windows-specific issues that plague standard installations.

---

## 🎯 What This Provides

✅ **One-command installation** - Automated setup in 2-3 minutes
✅ **Right-click context menu** - Launch from any folder in Explorer
✅ **Path translation** - Automatic `C:\Users` → `/c/users` conversion
✅ **Git Bash integration** - Unix commands (grep, find, awk, sed) work seamlessly
✅ **Environment setup** - API tokens, memory allocation, MSYS fixes
✅ **WSL detection** - Auto-routes `\\wsl$\` paths to WSL launcher
✅ **Auto-relaunch** - Crash? Press 'R' to restart immediately
✅ **Production-tested** - Based on real-world Windows development workflows

---

## 🚀 Quick Start

### Prerequisites

1. **Node.js 22+** (required)
   - Download: https://nodejs.org/
   - Verify: `node --version`

2. **Git for Windows** (highly recommended)
   - Download: https://git-scm.com/download/win
   - Install to: `C:\Program Files\Git` (default)
   - Provides: Unix commands for Claude Code

### Installation (3 minutes)

**Option 1: Automated (Recommended)**

```powershell
# Clone or download this repository
git clone https://github.com/YOUR-USERNAME/claude-code-windows-setup.git
cd claude-code-windows-setup

# Run installer as Administrator (for context menu)
.\installer\install-claude-windows.ps1
```

**Option 2: Manual**

```bash
# Install packages
npm install -g @anthropic-ai/claude-code@2.0.50 --ignore-scripts
npm install -g win-claude-code@1.0.7

# Deploy launchers
New-Item -ItemType Directory -Path "C:\claude\launchers\right-click" -Force
Copy-Item ".\launchers\*" -Destination "C:\claude\launchers\right-click\" -Recurse -Force

# Register context menu (requires Admin)
# Double-click: registry\install-context-menu.reg
```

**Option 3: Registry-Only (If Already Have npm Packages)**

If you already have Claude Code and win-claude-code installed globally:

```powershell
# Just deploy launchers and context menu
Copy-Item ".\launchers\*" -Destination "C:\claude\launchers\right-click\" -Force

# Double-click to register context menu
.\registry\install-context-menu.reg
```

### Usage

**Method 1: Right-Click Menu** (Best Experience)
1. Navigate to your project folder in File Explorer
2. Right-click on the folder (or inside it on empty space)
3. Click **"Open with Claude Code"**

**Method 2: Resume Conversation**
- Right-click folder → **"Continue with Claude Code"**
- Automatically resumes your last conversation in that directory

**Method 3: Run Launcher Directly**
```powershell
C:\claude\launchers\right-click\claude-code-clean-launcher.bat
```

**Method 4: Command Line** (Basic, Missing Features)
```bash
win-claude-code
```

---

## 📋 What Makes This Special?

### Standard win-claude-code Installation

Running `win-claude-code` directly gives you:
- ✅ Basic path translation (C:\ → /c/)
- ✅ Git Bash integration
- ❌ No API tokens loaded
- ❌ Default Node.js memory (OOM on large projects)
- ❌ MSYS path mangling not prevented
- ❌ Scoop Git may interfere (broken)
- ❌ No auto-relaunch on crash
- ❌ No MCP module junctions
- ❌ No WSL detection

### This Enhanced Setup

Using the launchers from this repository:
- ✅ Basic path translation (C:\ → /c/)
- ✅ Git Bash integration
- ✅ **API tokens auto-loaded from Windows Registry**
- ✅ **32GB Node.js heap allocated**
- ✅ **MSYS path mangling disabled** (`MSYS_NO_PATHCONV=1`)
- ✅ **Program Files Git prioritized** (avoids Scoop conflicts)
- ✅ **Auto-relaunch on crash** (press 'R' to restart)
- ✅ **MCP module junctions created** automatically
- ✅ **WSL paths detected** → redirected to WSL launcher

**Result:** 8 additional fixes beyond what win-claude-code alone provides!

---

## 🔧 Features in Detail

### 1. Path Translation

**Problem:** Windows uses `C:\Users`, Claude Code expects `/c/users`

**Solution:** win-claude-code hooks Node.js filesystem calls:
```javascript
windowsToPosix = (path) => {
  return path
    .replace(/\\/g, '/')           // C:\Users → C:/Users
    .replace(/^([A-Z]):/i, '/$1')  // C: → /c
    .toLowerCase()                 // /C → /c
}
```

**Result:** Unix tools (grep, find, awk, sed) work on Windows paths

### 2. Git Bash Integration

**Problem:** Claude Code expects `/bin/bash`, but Windows doesn't have it

**Solution:** win-claude-code redirects to Git Bash:
```javascript
if (command === '/bin/bash') {
  command = 'C:/Program Files/Git/usr/bin/bash.exe';
}
```

**Result:** Bash commands execute successfully

### 3. MSYS Path Mangling Prevention

**Problem:** MSYS auto-converts paths, causing double-conversion

**Solution:** Launchers set environment variables:
```powershell
$env:MSYS_NO_PATHCONV = "1"
$env:MSYS2_ARG_CONV_EXCL = "*"
$env:MSYS_PATH_CONVERT_DISABLE = "1"
```

**Result:** Paths stay correct through the entire toolchain

### 4. API Token Auto-Loading

**Problem:** API tokens in environment variables are fragile

**Solution:** Launchers load from Windows Registry:
```powershell
foreach ($k in @('GITHUB_TOKEN','BRAVE_API_KEY','EXA_API_KEY','PERPLEXITY_API_KEY')) {
  if (-not (Test-Path "env:$k")) {
    $val = Get-EnvFromRegistry $k
    if ($val) { Set-Item "env:$k" -Value $val }
  }
}
```

**Setup:**
```powershell
# Store tokens securely in registry (user-level)
[Environment]::SetEnvironmentVariable('GITHUB_TOKEN', 'your_token', 'User')
```

**Result:** Tokens available in Claude Code automatically

### 5. Memory Allocation

**Problem:** Large projects cause Node.js out-of-memory errors

**Solution:** Launchers allocate 32GB heap:
```powershell
$env:NODE_OPTIONS = "--max-old-space-size=32768"
```

**Result:** No memory issues on large codebases

### 6. MCP Module Junctions

**Problem:** MCP servers expect modules at `~/.mcp-modules/node_modules`

**Solution:** Launcher creates junction:
```powershell
New-Item -ItemType Junction -Path "$HOME\.mcp-modules\node_modules\@anthropic-ai\claude-code" -Target "$env:APPDATA\npm\node_modules\@anthropic-ai\claude-code"
```

**Result:** MCP integrations find required modules

### 7. WSL Detection

**Problem:** Right-clicking on `\\wsl$\Ubuntu\...` paths fails

**Solution:** Launcher detects and redirects:
```powershell
if ($TargetPath -match '^\\\\wsl') {
  & $wslLauncher $TargetPath
  exit
}
```

**Result:** Seamless WSL integration

### 8. Auto-Relaunch on Crash

**Problem:** Claude crashes, you have to re-navigate to directory

**Solution:** Launcher loop with prompt:
```powershell
while ($continueRunning) {
  & win-claude-code --dangerously-skip-permissions

  Write-Host "[R] Relaunch Claude Code"
  Write-Host "[X] Exit"
  $choice = Read-Host
}
```

**Result:** Press 'R' to immediately restart in same directory

---

## 📁 Repository Structure

```
claude-code-windows-setup/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore patterns
│
├── installer/
│   ├── install-claude-windows.ps1    # Automated installer
│   ├── register-context-menu.ps1     # Context menu registration only
│   └── uninstall.ps1                  # Clean removal
│
├── launchers/
│   ├── claude-code-clean-launcher.bat          # Primary launcher (BAT)
│   ├── claude-code-clean-launcher.ps1          # Primary launcher (PowerShell)
│   ├── claude-code-clean-launcher-continue.bat # Resume conversation (BAT)
│   ├── claude-code-clean-launcher-continue.ps1 # Resume conversation (PowerShell)
│   ├── claude-code-rust-launcher.bat           # Rust version launcher
│   ├── claude-code-rust-launcher.ps1
│   ├── claude-code-wsl-launcher.bat            # WSL launcher
│   ├── claude-code-wsl-launcher.ps1
│   └── ...                                     # Additional specialized launchers
│
├── registry/
│   ├── install-context-menu.reg      # Right-click menu registration
│   ├── uninstall-context-menu.reg    # Remove right-click menu
│   └── README.md                       # Registry setup documentation
│
└── docs/
    ├── WINDOWS_SETUP_GUIDE.md         # Complete technical documentation
    ├── CANARY_VS_STABLE.md            # Version comparison (stay on stable)
    ├── RUST_VS_NODE_ANALYSIS.md       # Why Node-based is primary
    └── ...                            # Additional documentation
```

---

## 🎨 Right-Click Context Menu

This setup adds **two** context menu items to Windows Explorer:

### 1. "Open with Claude Code" (Primary)

**Registry Location:**
```
HKEY_CLASSES_ROOT\Directory\shell\ClaudeCode
HKEY_CLASSES_ROOT\Directory\Background\shell\ClaudeCode
```

**Launcher:**
```
C:\claude\launchers\right-click\claude-code-clean-launcher.bat
```

**Appears:**
- Right-click on any folder
- Right-click on empty space inside folder

### 2. "Continue with Claude Code" (Resume)

**Registry Location:**
```
HKEY_CLASSES_ROOT\Directory\shell\ClaudeCodeContinue
HKEY_CLASSES_ROOT\Directory\Background\shell\ClaudeCodeContinue
```

**Launcher:**
```
C:\claude\launchers\right-click\claude-code-clean-launcher-continue.bat
```

**Functionality:**
- Resumes your last conversation in that directory
- Perfect for continuing work sessions

### Manual Registry Setup

If you prefer manual control or the installer fails:

**Install:**
```powershell
# Double-click to add entries
.\registry\install-context-menu.reg
```

**Uninstall:**
```powershell
# Double-click to remove entries
.\registry\uninstall-context-menu.reg
```

**Customize:**
Edit `registry\install-context-menu.reg` to change:
- Menu text ("Open with Claude Code" → your text)
- Launcher paths (if not using default location)
- Icons (Windows system icons or custom)

See `registry/README.md` for complete customization guide.

---

## 🔄 Updating

### Update Claude Code Core

```bash
npm install -g @anthropic-ai/claude-code@latest --ignore-scripts
```

### Update win-claude-code Wrapper

```bash
npm update -g win-claude-code
```

### Update Launchers

```powershell
# Pull latest from GitHub
git pull

# Redeploy launchers
Copy-Item ".\launchers\*" -Destination "C:\claude\launchers\right-click\" -Recurse -Force
```

### Check Current Versions

```bash
# Node-based (should show 2.0.50+)
win-claude-code --version

# Check npm packages
npm list -g @anthropic-ai/claude-code
npm list -g win-claude-code
```

---

## 🐛 Troubleshooting

### Issue: "win-claude-code: command not found"

**Cause:** npm global bin not in PATH

**Fix:**
```powershell
# Check npm global bin location
npm config get prefix

# Add to PATH (User level)
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$npmPath = (npm config get prefix)
[Environment]::SetEnvironmentVariable('Path', "$currentPath;$npmPath", 'User')

# Restart terminal
```

### Issue: "Git Bash not found" warning

**Cause:** Git for Windows not installed or wrong location

**Fix:**
1. Download Git for Windows: https://git-scm.com/download/win
2. Install to default location: `C:\Program Files\Git`
3. Restart Claude Code

**Note:** Git Bash is optional but highly recommended (provides Unix commands)

### Issue: Right-click menu items don't appear

**Causes:**
1. Registry entries not added (insufficient permissions)
2. Windows Explorer cache

**Fix:**
```powershell
# Method 1: Run registry file as Admin
# Right-click: registry\install-context-menu.reg
# Select "Run as administrator"

# Method 2: Restart Windows Explorer
taskkill /f /im explorer.exe
start explorer.exe

# Method 3: Reboot computer
```

### Issue: Menu item appears but clicking does nothing

**Cause:** Launcher path doesn't exist

**Fix:**
```powershell
# Verify launcher exists
Test-Path "C:\claude\launchers\right-click\claude-code-clean-launcher.bat"

# If False, redeploy launchers
Copy-Item ".\launchers\*" -Destination "C:\claude\launchers\right-click\" -Force
```

### Issue: Claude Code crashes on startup

**Cause:** Conflicting installations or corrupted npm cache

**Fix:**
```bash
# Clean reinstall
npm uninstall -g @anthropic-ai/claude-code win-claude-code
npm cache clean --force
npm install -g @anthropic-ai/claude-code@2.0.50 --ignore-scripts
npm install -g win-claude-code@1.0.7
```

### Issue: Scoop Git conflicts

**Problem:** Scoop's Git Bash has broken hardcoded paths

**Fix:**
Launchers automatically prioritize Program Files Git. If issues persist:
```powershell
# Option 1: Uninstall Scoop Git
scoop uninstall git

# Option 2: Install Program Files Git
# Download from: https://git-scm.com/download/win
```

### More Help

See `docs/WINDOWS_SETUP_GUIDE.md` for comprehensive troubleshooting.

---

## 📖 Documentation

### Quick References

- **README.md** (this file) - Quick start and overview
- **registry/README.md** - Context menu setup and customization

### In-Depth Guides

- **docs/WINDOWS_SETUP_GUIDE.md** - Complete technical documentation
  - Architecture explanation
  - What each component does
  - Launcher internals
  - Comparison tables

- **docs/CANARY_VS_STABLE.md** - win-claude-code version analysis
  - Why stick with stable 1.0.7
  - What changed in canary (unknown/experimental)
  - How to safely test canary

- **docs/RUST_VS_NODE_ANALYSIS.md** - Node vs Rust comparison
  - Why Node-based is primary (Rust has terminal rendering issues)
  - Can we patch Rust? (Partially, not worth it)
  - Technical analysis of problems

---

## 🤝 Contributing

Contributions welcome! Here's how you can help:

### Report Issues

**Found a bug?**
1. Check existing issues: https://github.com/YOUR-USERNAME/claude-code-windows-setup/issues
2. Create new issue with:
   - Windows version (10/11)
   - Node.js version
   - Error message / screenshot
   - Steps to reproduce

### Submit Improvements

**Have a fix or enhancement?**
1. Fork this repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Make changes and test thoroughly
4. Commit (`git commit -m 'Add amazing feature'`)
5. Push (`git push origin feature/amazing-feature`)
6. Open Pull Request

### Share Feedback

**Using this setup?**
- ⭐ Star the repository
- Share with colleagues
- Write blog post / tweet about it
- Submit suggestions

---

## 🎯 Use Cases

### For Yourself

- Clean Windows machine → One-command setup
- Multiple development machines → Consistent environment
- After Windows reinstall → Quick recovery

### For Your Team

- Standardized Claude Code setup across team
- Onboarding new developers
- Internal company distribution
- Knowledge base documentation

### For the Community

- Help other Windows users struggling with path issues
- Contribute to open-source ecosystem
- Build reputation / portfolio
- Get feedback for improvements

---

## 📊 FAQ

### Q: Why not just use the Rust version?

**A:** The Rust version (`claude.exe`) has critical terminal rendering issues on Windows:
- ANSI escape codes render as text (visible `←[32m` codes)
- Progress bars malfunction
- Colors don't work properly
- Cursor positioning errors

See `docs/RUST_VS_NODE_ANALYSIS.md` for complete analysis.

### Q: Should I update to win-claude-code canary (1.0.8-canary.3)?

**A:** No, stick with stable 1.0.7:
- Canary is 159% larger (major changes, unknown stability)
- No published changelog
- Author released stable 1.0.7 AFTER canary (suggests issues)
- Current setup works perfectly

See `docs/CANARY_VS_STABLE.md` for complete analysis.

### Q: Do I need administrator privileges?

**A:** Only for context menu registration (writes to `HKEY_CLASSES_ROOT`)

**Without admin:**
- npm packages install fine (user-level)
- Launchers work (run directly)
- Can't register right-click menu

**With admin:**
- Everything works
- Right-click context menu added

### Q: Can I customize the launchers?

**A:** Yes! Launchers are PowerShell scripts you can edit:
- Change environment variables
- Modify memory allocation
- Add custom pre/post hooks
- Change window titles
- Customize API token loading

See launcher `.ps1` files for comments and structure.

### Q: Will this work with WSL?

**A:** Yes! Launchers include WSL detection:
- Right-click on `\\wsl$\Ubuntu\...` paths
- Automatically launches WSL-specific launcher
- Handles path translation for WSL environment

### Q: How do I uninstall?

**A:** Run the uninstaller or manually:
```powershell
# Automated
.\installer\uninstall.ps1

# Manual
npm uninstall -g @anthropic-ai/claude-code win-claude-code
Remove-Item -Path "C:\claude\launchers" -Recurse -Force
# Double-click: registry\uninstall-context-menu.reg
```

### Q: Can I install to a different path?

**A:** Yes, but you'll need to update:
1. Edit `install-claude-windows.ps1` → change `$targetDir` variable
2. Edit `registry\install-context-menu.reg` → change launcher paths
3. Run installer or manually copy files

### Q: Does this support PowerShell 5.1 or only 7+?

**A:** Both work:
- PowerShell 7+ (recommended) - Better performance, modern features
- Windows PowerShell 5.1 (fallback) - Works but may have minor issues

Installer checks and warns if using old version.

---

## 🏆 Credits & Acknowledgments

**Built Upon:**
- **Claude Code** by [Anthropic](https://anthropic.com)
- **win-claude-code** by [somersby10ml](https://github.com/somersby10ml/win-claude-code)

**Enhanced With:**
- Production-tested launcher scripts
- Windows-specific path fixes
- Environment optimization
- Context menu integration

**Contributors:**
- Original Windows integration work: Production use case refinements
- Community feedback: Issue reports and suggestions
- You? Submit a PR!

---

## 📄 License

**This repository:**
- MIT License (see LICENSE file)
- Free to use, modify, distribute

**Bundled software:**
- Claude Code: Anthropic Terms of Service
- win-claude-code: MIT License (somersby10ml)

---

## 🆘 Support

**Documentation:**
- Check `docs/` folder for detailed guides
- See `registry/README.md` for context menu help
- Review Troubleshooting section above

**Issues:**
- GitHub Issues: https://github.com/YOUR-USERNAME/claude-code-windows-setup/issues
- win-claude-code: https://github.com/somersby10ml/win-claude-code/issues
- Claude Code: https://claude.ai

**Community:**
- Reddit: r/ClaudeAI
- Discord: Claude community servers
- Twitter: #ClaudeAI hashtag

---

## 🎉 Ready to Get Started?

```powershell
# Clone this repository
git clone https://github.com/YOUR-USERNAME/claude-code-windows-setup.git
cd claude-code-windows-setup

# Run installer (as Admin for context menu)
.\installer\install-claude-windows.ps1

# Wait ~2 minutes

# Test it!
# Right-click any folder → "Open with Claude Code"
```

**Enjoy seamless Claude Code on Windows!** 🚀

---

**⭐ If this setup helped you, please star the repository and share with others!**
