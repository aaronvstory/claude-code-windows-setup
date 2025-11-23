# win-claude-code: Canary vs Stable Version Analysis

**Last Updated:** November 22, 2025

---

## 📊 Version Comparison

| Aspect | Stable (1.0.7) | Canary (1.0.8-canary.3) |
|--------|----------------|-------------------------|
| **Release Date** | ~4 months ago | ~4 months ago |
| **Package Size** | 15.9 kB | 41.2 kB (2.6x larger) |
| **Status** | Production-ready | Experimental |
| **npm Tag** | `latest` | `canary` |
| **Stability** | ✅ Proven stable | ⚠️ Unknown |
| **Breaking Changes** | None | Possible |

---

## 🤔 Should You Upgrade to Canary?

### ❌ Reasons NOT to Upgrade

1. **Size Increase Signals Major Changes**
   - Stable: 15.9 kB
   - Canary: 41.2 kB (159% larger!)
   - **Analysis:** This isn't a small patch - significant code was added
   - **Risk:** Could introduce bugs or breaking changes

2. **No Published Changelog**
   - GitHub repo doesn't document what changed in 1.0.8-canary.3
   - Flying blind on what's different
   - Can't assess risk/benefit

3. **Canary = Experimental**
   - Canary releases are for testing, not production
   - Author may have abandoned canary if it had issues
   - Stable 1.0.7 was released AFTER some canary versions

4. **Current Setup Works Perfectly**
   - Your Node-based setup with 1.0.7 solves all known Windows issues
   - "If it ain't broke, don't fix it"

5. **No Auto-Update Path**
   - If canary breaks your setup, rolling back requires manual intervention
   - Could disrupt workflow

### ✅ Reasons TO Upgrade (Hypothetical)

If canary version addressed:
- Better path translation performance
- Additional MSYS workarounds
- Improved error messages
- Windows 11 specific fixes

**But we don't know if it does any of these!**

---

## 🔬 How to Safely Test Canary

If you want to experiment:

### Step 1: Backup Current Setup

```bash
# Document current working version
npm list -g win-claude-code > canary-test-backup.txt

# Note: npm doesn't support "rollback" so you need the version number
```

### Step 2: Install Canary

```bash
npm install -g win-claude-code@canary
```

### Step 3: Test Thoroughly

Test these scenarios:
- [ ] Basic launch in normal directory
- [ ] Launch in directory with spaces in path
- [ ] Launch in deep nested path (>200 chars)
- [ ] WSL path (\\wsl$\Ubuntu\...)
- [ ] Unicode characters in path
- [ ] Bash commands (grep, find, awk, sed)
- [ ] Large project (32GB memory allocation)
- [ ] MCP module loading
- [ ] Multiple consecutive launches
- [ ] Crash and auto-relaunch

### Step 4: Rollback if Issues

```bash
# Rollback to stable
npm install -g win-claude-code@1.0.7
```

---

## 🎯 Recommendation

**Stick with stable 1.0.7** for now because:

1. ✅ **Proven stable** in your production use
2. ✅ **Known quantity** - you understand what it does
3. ✅ **Documented behavior** - your SETUP_GUIDE.md explains it
4. ✅ **Works with your launchers** - full integration tested
5. ⚠️ **Canary is a mystery** - no changelog, no known fixes

---

## 📝 Version Timeline Context

```
1.0.4         (stable)
1.0.5         (stable)
1.0.6-canary.1 (experimental)
1.0.6-canary.2 (experimental)
1.0.6-canary.3 (experimental)
1.0.7         (stable) ← CURRENT RECOMMENDED
1.0.8-canary.1 (experimental)
1.0.8-canary.2 (experimental)
1.0.8-canary.3 (experimental) ← Latest canary
```

**Observation:** Author released stable 1.0.7 AFTER multiple canary builds.

**Interpretation:** Either:
- Canary builds had issues → not promoted to stable
- Canary is for major v1.1/v2.0 rewrite → not ready yet
- Author is testing breaking changes → too risky

---

## 🔍 What We Know About Canary

From npm metadata:
- **SHA:** b3f5133647d64c8ce60f64bd9ce436f451f8c1ab
- **Published:** ~4 months ago (same as stable)
- **Maintainer:** somersby10ml
- **Dependencies:** None (same as stable)

**What changed:** Code only (no new dependencies)

**File size increase:** +25.3 kB of JavaScript

**Likely changes** (speculation):
- Additional path translation edge cases
- More comprehensive hooks
- Enhanced error handling
- Development/debugging features
- Experimental Windows 11 optimizations

---

## 💡 When Should You Upgrade?

Wait for these signals:

1. **Author promotes canary to stable**
   - Version 1.0.8 (or higher) without `-canary` suffix
   - Indicates testing completed successfully

2. **Changelog published**
   - GitHub releases page shows what's new
   - Can assess risk/benefit

3. **Community testing**
   - Other users report success with canary
   - GitHub issues show no major breakage

4. **Specific bug you're hitting**
   - If you encounter a bug in 1.0.7
   - Canary mentions fixing it

---

## 🛠️ Advanced: Diffing the Packages

If you want to know what changed:

```bash
# Download both versions
npm pack win-claude-code@1.0.7
npm pack win-claude-code@1.0.8-canary.3

# Extract
tar -xzf win-claude-code-1.0.7.tgz
tar -xzf win-claude-code-1.0.8-canary.3.tgz

# Diff the runner.js files
diff package-1.0.7/runner.js package-1.0.8-canary.3/runner.js
```

This would show EXACTLY what changed, allowing informed decision.

---

## 📊 Decision Matrix

| Your Situation | Recommendation |
|----------------|----------------|
| Production use, stability critical | ✅ **Stay on 1.0.7** |
| Hitting specific bug | 🔍 Test canary in isolated env |
| Curious about improvements | 🧪 Test canary, be ready to rollback |
| Mission-critical project | ❌ **Do NOT upgrade to canary** |
| Setting up for someone else | ✅ **Use 1.0.7 stable** |

---

## 🎯 Final Verdict

**For your portable setup package:** Use **1.0.7 stable**

**Reasoning:**
- Sharing with others → stability critical
- No known issues with 1.0.7
- Canary changes unknown
- "Plug and play" requires reliability

**If you personally want to experiment:**
- Install canary on YOUR machine only
- Test for 1-2 weeks
- Document findings
- Update portable package only if canary proves superior

---

## 📚 Additional Resources

- **npm package:** https://www.npmjs.com/package/win-claude-code
- **GitHub repo:** https://github.com/somersby10ml/win-claude-code
- **Issues:** https://github.com/somersby10ml/win-claude-code/issues

---

**Conclusion:** Stick with proven stable 1.0.7 unless you have a specific reason to experiment with canary.
