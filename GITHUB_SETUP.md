# GitHub Repository Setup Guide

This guide explains how to push this repository to GitHub and share it with others.

---

## 📋 Prerequisites

- GitHub account
- Git installed locally
- GitHub Personal Access Token (PAT) or SSH key configured

---

## 🚀 First-Time Setup

### Step 1: Create GitHub Repository

1. Go to GitHub: https://github.com/new
2. Fill in details:
   - **Repository name:** `claude-code-windows-setup`
   - **Description:** "Production-ready Claude Code setup for Windows with path translation, Git Bash integration, and context menu"
   - **Visibility:**
     - **Public** - To share with community
     - **Private** - For personal/team use only
   - **Initialize:** Leave ALL checkboxes UNCHECKED (we have files already)
3. Click **"Create repository"**

### Step 2: Connect Local Repository to GitHub

The repository is already initialized with git. Now connect it to GitHub:

```bash
cd C:\claude\claude-code-windows-setup

# Add remote (replace aaronvstory with your GitHub username)
git remote add origin https://github.com/aaronvstory/claude-code-windows-setup.git

# Or use SSH if you have it configured
git remote add origin git@github.com:aaronvstory/claude-code-windows-setup.git

# Verify remote
git remote -v
```

### Step 3: Create Initial Commit

```bash
# Check what will be committed
git status

# All files should be staged already
# If not, add them:
git add .

# Create initial commit
git commit -m "Initial release: Claude Code Windows portable setup v1.0.0

Features:
- Automated installer with prerequisite checking
- 19 production-tested launcher scripts
- Right-click context menu integration (primary + continue)
- Path translation and Git Bash fixes
- Environment optimization (API tokens, memory, MSYS)
- WSL detection and auto-routing
- Registry files for easy context menu setup
- Comprehensive documentation

Solves 8+ Windows integration issues beyond win-claude-code alone."
```

### Step 4: Push to GitHub

```bash
# Push to main branch
git branch -M main
git push -u origin main
```

**If prompted for credentials:**
- Username: Your GitHub username
- Password: Your GitHub Personal Access Token (NOT your GitHub password)

**To create PAT:**
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token
3. Select scopes: `repo` (all)
4. Copy token (save somewhere safe!)

---

## 🔄 Updating the Repository

### After Making Changes

```bash
cd C:\claude\claude-code-windows-setup

# Check what changed
git status
git diff

# Add changed files
git add .

# Or add specific files
git add README.md launchers/

# Commit with descriptive message
git commit -m "Update: Brief description of changes"

# Push to GitHub
git push
```

### Example Update Workflow

```bash
# Scenario: You fixed a bug in the main launcher
git status
# Shows: modified: launchers/claude-code-clean-launcher.ps1

git add launchers/claude-code-clean-launcher.ps1
git commit -m "Fix: Correct MSYS path conversion in main launcher

- Added additional MSYS environment variable
- Improved error handling for missing Git Bash
- Updated comments for clarity"

git push
```

---

## 📦 Creating Releases

### When to Create a Release

Create a release when:
- New Claude Code version supported (2.0.50 → 2.1.0)
- Major launcher improvements
- New features added
- Bug fixes worth distributing

### How to Create a Release

**Via GitHub Web Interface:**

1. Go to your repository on GitHub
2. Click **"Releases"** (right sidebar)
3. Click **"Create a new release"**
4. Fill in:
   - **Tag:** `v1.0.0` (semantic versioning)
   - **Release title:** `Claude Code Windows Setup v1.0.0`
   - **Description:**
     ```markdown
     # Claude Code Windows - Production-Ready Setup v1.0.0

     Complete plug-and-play installation for Claude Code on Windows.

     ## ✨ Features
     - ✅ One-command automated installation
     - ✅ Right-click context menu ("Open" + "Continue")
     - ✅ Path translation (C:\ → /c/)
     - ✅ Git Bash integration
     - ✅ 8+ Windows-specific fixes

     ## 📦 Installation
     ```bash
     git clone https://github.com/aaronvstory/claude-code-windows-setup.git
     cd claude-code-windows-setup
     .\installer\install-claude-windows.ps1
     ```

     ## 📋 Prerequisites
     - Node.js 22+
     - Git for Windows (optional)
     - Admin rights (for context menu)

     ## 📚 Documentation
     See README.md for complete guide

     ## 🔄 Included Versions
     - @anthropic-ai/claude-code: 2.0.50
     - win-claude-code: 1.0.7 (stable)

     ## 🐛 Bug Reports
     https://github.com/aaronvstory/claude-code-windows-setup/issues
     ```
5. Click **"Publish release"**

**Via Git Tags:**

```bash
cd C:\claude\claude-code-windows-setup

# Create annotated tag
git tag -a v1.0.0 -m "Release v1.0.0 - Initial production-ready setup"

# Push tag to GitHub
git push origin v1.0.0

# Then create release via web interface using this tag
```

---

## 🌟 Promoting Your Repository

### Update README

Before sharing, update the README:

1. Replace all `aaronvstory` with your actual GitHub username
2. Update clone URLs
3. Update issue tracker URLs
4. Add your contact info (optional)

**Find and replace:**
```bash
# In README.md and other docs
# Replace: aaronvstory
# With: your-actual-username
```

### Share It

**Social Media:**
- Twitter/X: "Just published a production-ready Claude Code setup for Windows! Solves path translation, Git Bash, and 8+ other issues. Check it out: [URL] #ClaudeAI #Windows"
- LinkedIn: Share with brief description + link
- Dev.to / Hashnode: Write detailed blog post

**Communities:**
- Reddit r/ClaudeAI: Share with explanation
- Reddit r/windows: Cross-post if relevant
- Discord: Claude community servers
- Hacker News: If gets traction

**Company Internal:**
- Slack/Teams channels
- Internal wiki/documentation
- Developer onboarding guide
- Tech blog post

---

## 🛡️ Security Best Practices

### Before Pushing to GitHub

**✅ Already Done:**
- Sanitized Supabase token (`YOUR_SUPABASE_TOKEN_HERE` placeholder)
- Removed personal username paths (uses `$env:USERNAME`)
- No hardcoded API keys
- `.gitignore` configured

**⚠️ Double-Check:**

```bash
# Search for any remaining personal info
git grep -i "d0nbx"
git grep -i "sbp_"
git grep -E "[A-Za-z0-9_-]{20,}" launchers/

# Should find only placeholders, not real tokens
```

### Sensitive Information

**Never commit:**
- API keys / tokens
- Passwords
- Personal email addresses (in code)
- Internal company paths/URLs
- Database credentials

**Use placeholders:**
```powershell
# Good
$env:SUPABASE_ACCESS_TOKEN = $env:SUPABASE_ACCESS_TOKEN ?? 'YOUR_SUPABASE_TOKEN_HERE'

# Bad
$env:SUPABASE_ACCESS_TOKEN = 'sbp_8f64bbc3f7c78dcc26133c98d87a565c777c682f'
```

### If You Accidentally Commit Secrets

**Immediate action:**

```bash
# Remove file from git history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/file-with-secret" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (destructive!)
git push --force --all

# Rotate the compromised secret immediately!
```

**Better:** Use GitHub's secret scanning and rotate keys proactively.

---

## 📊 Repository Settings

### Recommended Settings

Go to **Settings** on GitHub:

**General:**
- ✅ Enable "Issues" (for bug reports)
- ✅ Enable "Discussions" (for community Q&A) - optional
- ❌ Disable "Wiki" (unless you want separate wiki)
- ❌ Disable "Projects" (unless project management needed)

**Branches:**
- Set `main` as default branch
- Add branch protection rules (if multiple contributors):
  - ✅ Require pull request reviews
  - ✅ Require status checks to pass
  - ❌ Don't restrict who can push (for personal repo)

**Pages** (optional):
- Enable GitHub Pages to host documentation
- Source: Deploy from branch `main` / `docs` folder
- Custom domain (optional)

---

## 🤝 Collaboration

### Accepting Contributions

**If you want contributors:**

1. **Add CONTRIBUTING.md:**
   ```markdown
   # Contributing

   Thanks for your interest!

   ## Reporting Bugs
   - Use GitHub Issues
   - Include: Windows version, Node.js version, error messages
   - Provide steps to reproduce

   ## Submitting Changes
   1. Fork the repository
   2. Create feature branch
   3. Make changes and test
   4. Submit pull request

   ## Code Style
   - PowerShell: Follow PSScriptAnalyzer recommendations
   - Documentation: Clear, concise, with examples
   ```

2. **Enable PR template** (`.github/pull_request_template.md`):
   ```markdown
   ## Description
   [Describe your changes]

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update

   ## Testing
   - [ ] Tested on Windows 10
   - [ ] Tested on Windows 11
   - [ ] Launchers work correctly

   ## Checklist
   - [ ] No personal info included
   - [ ] Documentation updated
   - [ ] Follows existing code style
   ```

### Managing Issues

**Issue templates** (`.github/ISSUE_TEMPLATE/bug_report.md`):
```markdown
---
name: Bug Report
about: Report a problem with the setup
---

**Describe the bug**
A clear description of what happened.

**Environment**
- Windows version: [10/11]
- Node.js version: [run `node --version`]
- Claude Code version: [run `win-claude-code --version`]

**Steps to Reproduce**
1. Go to '...'
2. Run '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.
```

---

## 📈 Repository Maintenance

### Monthly Tasks

- [ ] Check for Claude Code updates
- [ ] Check for win-claude-code updates
- [ ] Review open issues
- [ ] Test on latest Windows updates
- [ ] Update documentation if needed

### Quarterly Tasks

- [ ] Full test on clean Windows VM
- [ ] Review launcher optimizations
- [ ] Update screenshots/demos
- [ ] Collect user feedback

### Version Bumping

**Semantic Versioning:**
- **Major** (2.0.0): Breaking changes (new Claude version, new launcher structure)
- **Minor** (1.1.0): New features (additional launchers, new capabilities)
- **Patch** (1.0.1): Bug fixes (small tweaks, doc updates)

**Update version in:**
1. README.md (badge/header)
2. PACKAGE_MANIFEST.md
3. Git tag
4. GitHub release

---

## 🎯 Repository Metrics

### What to Track

**GitHub Insights:**
- ⭐ Stars (indicates interest)
- 🍴 Forks (indicates use/contribution)
- 👁️ Watchers (indicates following updates)
- 📊 Traffic (clones, views, unique visitors)
- 🐛 Issues (engagement, problems found)
- 🔀 Pull Requests (contributions)

**External:**
- Social media shares
- Blog post views
- Community mentions
- Download counts (if distributing zips)

### Success Indicators

**Good signs:**
- ⭐ 10+ stars in first month
- Issues opened (shows usage)
- Pull requests submitted
- Community discussions
- Other repos linking to yours

---

## 🎉 You're Ready!

Your repository is now:
- ✅ Initialized with git
- ✅ All files committed
- ✅ Personal info sanitized
- ✅ Documentation complete
- ✅ Ready to push to GitHub

**Next steps:**

```bash
# 1. Create GitHub repository (see Step 1)

# 2. Add remote (replace aaronvstory)
cd C:\claude\claude-code-windows-setup
git remote add origin https://github.com/aaronvstory/claude-code-windows-setup.git

# 3. Push!
git branch -M main
git push -u origin main

# 4. Create v1.0.0 release on GitHub

# 5. Share with the world!
```

**Good luck with your repository!** 🚀
