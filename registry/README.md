# Registry Files for Context Menu Integration

These `.reg` files configure Windows Explorer right-click context menus for Claude Code.

---

## 📋 What Gets Added

### Primary Launcher: "Open with Claude Code"

**Appears when you:**
- Right-click on a folder
- Right-click on empty space inside a folder

**Launches:**
```
C:\claude\launchers\right-click\claude-code-clean-launcher.bat
```

**Icon:** Windows folder icon (imageres.dll,190)

### Continue Launcher: "Continue with Claude Code"

**Appears when you:**
- Right-click on a folder
- Right-click on empty space inside a folder

**Launches:**
```
C:\claude\launchers\right-click\claude-code-clean-launcher-continue.bat
```

**Resumes:** Your last conversation in that directory

**Icon:** Windows folder with arrow icon (imageres.dll,191)

---

## 🚀 Installation

### Method 1: Double-Click (Easiest)

1. **Install context menu:**
   - Double-click `install-context-menu.reg`
   - Click "Yes" when Windows asks to add entries
   - Done! Right-click any folder to see new menu items

2. **Test it:**
   - Navigate to any folder in File Explorer
   - Right-click on the folder (or inside it on empty space)
   - You should see "Open with Claude Code"

### Method 2: PowerShell (Automated Installer Included)

The main installer already registers context menu automatically:
```powershell
.\installer\install-claude-windows.ps1
```

### Method 3: Manual Registry Editing

If you prefer manual control:

1. Open Registry Editor (`regedit.exe` as Administrator)
2. Navigate to: `HKEY_CLASSES_ROOT\Directory\shell\`
3. Create keys manually following the structure in `install-context-menu.reg`

---

## 🗑️ Uninstallation

### Quick Uninstall

1. Double-click `uninstall-context-menu.reg`
2. Click "Yes" when Windows asks to remove entries
3. Context menu items removed!

### Via Installer

```powershell
.\installer\uninstall.ps1
```

Removes both npm packages AND context menu entries.

---

## ⚙️ Registry Locations

### Primary Launcher

**Folder right-click:**
```
HKEY_CLASSES_ROOT\Directory\shell\ClaudeCode
HKEY_CLASSES_ROOT\Directory\shell\ClaudeCode\command
```

**Background right-click (inside folder):**
```
HKEY_CLASSES_ROOT\Directory\Background\shell\ClaudeCode
HKEY_CLASSES_ROOT\Directory\Background\shell\ClaudeCode\command
```

### Continue Launcher

**Folder right-click:**
```
HKEY_CLASSES_ROOT\Directory\shell\ClaudeCodeContinue
HKEY_CLASSES_ROOT\Directory\shell\ClaudeCodeContinue\command
```

**Background right-click (inside folder):**
```
HKEY_CLASSES_ROOT\Directory\Background\shell\ClaudeCodeContinue
HKEY_CLASSES_ROOT\Directory\Background\shell\ClaudeCodeContinue\command
```

---

## 🛠️ Customization

### Change Launcher Path

If your launchers are in a different location, edit `install-context-menu.reg`:

**Find:**
```reg
@="\"C:\\claude\\launchers\\right-click\\claude-code-clean-launcher.bat\" \"%V\""
```

**Replace with your path:**
```reg
@="\"D:\\MyTools\\launchers\\claude-code-clean-launcher.bat\" \"%V\""
```

**Note:** Use double backslashes (`\\`) in .reg files!

### Change Menu Text

Edit the display text:

**Find:**
```reg
@="Open with Claude Code"
```

**Change to:**
```reg
@="Launch Claude AI"
```

### Change Icon

**Current icon:** `C:\\Windows\\System32\\imageres.dll,190`

**Other options:**
- `imageres.dll,191` - Folder with arrow
- `imageres.dll,3` - Folder icon
- `shell32.dll,4` - Folder open icon
- `"C:\\path\\to\\custom.ico"` - Custom icon file

**Example:**
```reg
"Icon"="C:\\Windows\\System32\\shell32.dll,4"
```

### Add Submenu

To nest items under a submenu, edit registry:

**Create parent:**
```reg
[HKEY_CLASSES_ROOT\Directory\shell\ClaudeMenu]
@="Claude Code"
"SubCommands"=""
```

**Add items to submenu:**
```reg
[HKEY_CLASSES_ROOT\Directory\shell\ClaudeMenu\shell\Open]
@="Open"
[HKEY_CLASSES_ROOT\Directory\shell\ClaudeMenu\shell\Open\command]
@="\"C:\\claude\\launchers\\right-click\\claude-code-clean-launcher.bat\" \"%V\""
```

(This creates "Claude Code" → "Open" hierarchy)

---

## 🐛 Troubleshooting

### Issue: Menu items don't appear after installation

**Causes:**
1. Registry entries not added (insufficient permissions)
2. Launcher path incorrect
3. Windows Explorer cache

**Fixes:**
1. Run `install-context-menu.reg` as Administrator:
   - Right-click → "Run as administrator"
2. Restart Windows Explorer:
   ```powershell
   taskkill /f /im explorer.exe
   start explorer.exe
   ```
3. Reboot computer

### Issue: Menu item appears but clicking does nothing

**Cause:** Launcher path doesn't exist

**Fix:**
1. Verify launcher exists:
   ```powershell
   Test-Path "C:\claude\launchers\right-click\claude-code-clean-launcher.bat"
   ```
2. If false, run full installer:
   ```powershell
   .\installer\install-claude-windows.ps1
   ```

### Issue: Error "Cannot find launcher file"

**Cause:** Path mismatch in registry vs actual location

**Fix:**
1. Find actual launcher location:
   ```powershell
   Get-ChildItem -Path C:\ -Filter "claude-code-clean-launcher.bat" -Recurse -ErrorAction SilentlyContinue
   ```
2. Edit `install-context-menu.reg` with correct path
3. Re-apply registry file

### Issue: Want to change menu text after installation

**Fix:**
1. Edit `install-context-menu.reg`
2. Change `@="Open with Claude Code"` to desired text
3. Double-click to reapply (overwrites existing)

### Issue: Menu items duplicated

**Cause:** Multiple registry entries or capitalization differences

**Fix:**
1. Run `uninstall-context-menu.reg`
2. Open Registry Editor manually
3. Search for "ClaudeCode" entries
4. Delete all found
5. Reinstall with `install-context-menu.reg`

---

## 📊 What the Registry Entries Do

### Command Value: `"%V"` Parameter

```reg
@="\"C:\\claude\\launchers\\right-click\\claude-code-clean-launcher.bat\" \"%V\""
```

**Breakdown:**
- `\"C:\\claude\\...\\launcher.bat\"` - Path to launcher (escaped quotes)
- `\"%V\"` - Windows passes folder path here

**%V expands to:**
- Right-click on folder: `C:\Users\Name\Projects\MyProject`
- Right-click on background: `C:\Users\Name\Projects` (current directory)

**Launcher receives this as parameter:**
```powershell
param([string]$TargetPath)  # Receives %V value
```

### Icon Value

```reg
"Icon"="C:\\Windows\\System32\\imageres.dll,190"
```

**Format:** `<dll-path>,<icon-index>`

**Windows system DLLs with icons:**
- `imageres.dll` - Windows 7+ icons (modern)
- `shell32.dll` - Classic Windows icons
- `explorer.exe` - Explorer icons

**Browse icons:**
```powershell
# Extract icon index from DLL (requires PowerShell module)
[System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\imageres.dll")
```

Or use icon viewing tools to preview indices.

---

## 🔐 Security Considerations

### Registry Permissions

**HKEY_CLASSES_ROOT** requires Administrator privileges because:
- Affects all users on the system
- Controls shell extensions
- Can execute arbitrary commands

**Best practice:**
- Only install from trusted `.reg` files
- Review contents before applying
- Use user-level alternatives if available (limited, not for context menu)

### Command Injection

**Potential risk:** If launcher path contains spaces or special characters

**Mitigation:** Registry entries use proper quoting:
```reg
@="\"C:\\path with spaces\\launcher.bat\" \"%V\""
```

**Launcher scripts should validate `$TargetPath`:**
```powershell
param([string]$TargetPath)

# Validate path exists and is directory
if ($TargetPath -and (Test-Path $TargetPath) -and (Get-Item $TargetPath) -is [System.IO.DirectoryInfo]) {
    Set-Location -Path $TargetPath
} else {
    Write-Error "Invalid target path: $TargetPath"
    exit 1
}
```

---

## 📚 Additional Resources

**Microsoft Documentation:**
- [Registry Editor Guide](https://support.microsoft.com/en-us/windows/how-to-open-registry-editor-in-windows-10-deab38e6-91d6-e0aa-4b7c-8878d9e07b11)
- [Context Menu Extension](https://docs.microsoft.com/en-us/windows/win32/shell/context-menu)

**Tools:**
- [ShellMenuView](https://www.nirsoft.net/utils/shell_menu_view.html) - View/disable context menu items
- [FileTypesMan](https://www.nirsoft.net/utils/file_types_manager.html) - Manage file associations

---

## 🎯 Quick Reference

| Task | Command |
|------|---------|
| **Install context menu** | Double-click `install-context-menu.reg` |
| **Remove context menu** | Double-click `uninstall-context-menu.reg` |
| **Restart Explorer** | `taskkill /f /im explorer.exe && start explorer.exe` |
| **View registry** | `regedit` → `HKCR\Directory\shell\ClaudeCode` |
| **Test launcher exists** | `Test-Path "C:\claude\launchers\right-click\claude-code-clean-launcher.bat"` |

---

**Tip:** Keep a copy of your customized `install-context-menu.reg` for easy reinstallation after Windows updates or system changes!
