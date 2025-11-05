# VPS Readiness Check - Quick Guide

**Before installing Claude CLI on your VPS, run these checks to make sure everything is ready!**

---

## 🎯 Two Ways to Check Your VPS

### Method 1: From Windows (Recommended) ⭐

**Best if:** You have SSH access from your Windows machine

**Run this:**
```powershell
cd C:\Users\hharp\chucky_project
.\check-vps-readiness.ps1
```

**What it does:**
- Tests SSH connection from Windows to VPS
- Checks if n8n is accessible
- Detects n8n URL and API endpoint
- Verifies all requirements
- Creates a settings file with detected configuration
- Tells you exactly what to do next

**Time:** 2-3 minutes

---

### Method 2: On VPS Directly

**Best if:** SSH isn't working from Windows, or you prefer web terminal

**Steps:**

1. **Upload the script to your VPS:**

   **Option A: Via SCP (if SSH works)**
   ```powershell
   scp C:\Users\hharp\chucky_project\check-vps-from-inside.sh user@vps:/root/
   ```

   **Option B: Via Hostinger Web Terminal**
   - Go to Hostinger VPS panel
   - Open Web Terminal
   - Create file: `nano check-vps.sh`
   - Copy contents of `check-vps-from-inside.sh`
   - Paste into terminal
   - Save (Ctrl+X, Y, Enter)

2. **Run on VPS:**
   ```bash
   chmod +x check-vps.sh  # or ~/check-vps-from-inside.sh
   ./check-vps.sh
   ```

**What it does:**
- Comprehensive system check from inside VPS
- Checks Docker containers
- Tests n8n accessibility
- Detects configuration
- Creates detailed report
- Shows next steps

**Time:** 3-5 minutes

---

## 📋 What the Checks Look For

### ✅ Must Have (Critical)
- [x] **SSH Access** - Can connect to VPS
- [x] **n8n Running** - Container is up
- [x] **n8n Accessible** - Can reach the interface

### ⚠️ Should Have (Will Install if Missing)
- [ ] **Node.js** - Required for Claude CLI (auto-installs)
- [ ] **npm** - Comes with Node.js (auto-installs)
- [ ] **jq** - JSON processor (auto-installs)

### ℹ️ Nice to Have (Informational)
- [ ] **Docker** - Probably installed if n8n is running
- [ ] **Reverse Proxy** - Caddy or Nginx
- [ ] **SSL Certificates** - For HTTPS

---

## 📊 Sample Output

**From Windows check:**
```
==========================================
  VPS Readiness Check for Claude + n8n
==========================================

Checking VPS: root@n8n.maintpc.com

[1/10] Testing SSH Connection...
✓ SSH connection working

[2/10] Gathering VPS Information...
✓ OS: Ubuntu 22.04.3 LTS

[3/10] Checking Node.js...
✓ Node.js installed: v20.10.0

...

==========================================
  Summary Report
==========================================

VPS Details:
  Host: n8n.maintpc.com
  User: root
  OS: Ubuntu 22.04.3 LTS

Requirements:
✓ SSH Access
✓ n8n Running
✓ Node.js
✓ Docker

n8n Information:
  URL: https://n8n.maintpc.com
  API: https://n8n.maintpc.com/api/v1

Next Steps:
1. Generate n8n API Key:
   - Open: https://n8n.maintpc.com
   - Go to: Settings → API
   - Create API Key

2. Get Claude API Key:
   - Open Claude Desktop
   - Copy API key

3. Run Installation:
   - Run: .\deploy-claude-to-vps.ps1
```

---

## 🚨 Common Issues & Fixes

### Issue: SSH Connection Failed

**Error:** `✗ SSH connection failed`

**Causes:**
- SSH not enabled on VPS
- Wrong hostname or username
- Firewall blocking port 22
- Need to set up SSH keys

**Fixes:**
1. **Enable SSH in Hostinger:**
   - Go to Hostinger VPS panel
   - Look for SSH settings
   - Enable SSH access
   - Note the username and port

2. **Verify credentials:**
   ```powershell
   # Test manually
   ssh root@n8n.maintpc.com
   ```

3. **Use web terminal instead:**
   - Hostinger panel → Web Terminal
   - Run the inside check script directly

---

### Issue: n8n Not Found

**Error:** `⚠ n8n not accessible`

**Causes:**
- n8n container not running
- n8n on different port
- Firewall blocking access

**Fixes:**
1. **Check if n8n is running:**
   ```bash
   ssh user@vps "docker ps"
   ```

2. **Start n8n if stopped:**
   ```bash
   ssh user@vps "docker-compose up -d"
   ```

3. **Check n8n logs:**
   ```bash
   ssh user@vps "docker logs n8n"
   ```

---

### Issue: Node.js Not Installed

**Warning:** `⚠ Node.js not found`

**This is OK!** The setup script will install Node.js automatically.

**Or install manually:**
```bash
ssh user@vps
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

---

## 🎯 What You Need Before Running Checks

**Information to have ready:**
- [ ] VPS hostname or IP (e.g., `n8n.maintpc.com` or `123.45.67.89`)
- [ ] VPS username (e.g., `root`, `ubuntu`, or custom user)
- [ ] SSH password or key (if not already set up)

**Optional but helpful:**
- [ ] Hostinger VPS panel access
- [ ] n8n admin credentials

---

## 📝 Generated Files

### After Windows Check:
```
C:\Users\hharp\chucky_project\vps-settings.txt
```
Contains:
- Detected VPS configuration
- n8n URLs and endpoints
- Checklist for API keys
- Next commands to run

### After VPS Check:
```
~/vps-readiness-report.txt
```
Contains:
- Complete system information
- All running containers
- n8n configuration
- Warnings and errors
- Next steps

**Copy to Windows:**
```powershell
scp user@vps:~/vps-readiness-report.txt C:\Users\hharp\chucky_project\
```

---

## ⏭️ After Checks Pass

### If All Green ✓

You're ready! Run the installation:

```powershell
cd C:\Users\hharp\chucky_project
.\deploy-claude-to-vps.ps1
```

### If Warnings ⚠

Review the warnings and decide:
- **Node.js missing?** Setup will install it
- **Docker not found?** Might need to install or check if it's really missing
- **n8n not accessible externally?** Might be firewall, still OK for setup

### If Errors ✗

Fix the errors first:
- **SSH not working?** Enable SSH in Hostinger panel
- **n8n not running?** Start your n8n container
- **Major issues?** Contact Hostinger support or check docker-compose setup

---

## 🔧 Quick Commands Reference

**From Windows:**
```powershell
# Run readiness check
.\check-vps-readiness.ps1

# Deploy Claude CLI
.\deploy-claude-to-vps.ps1

# Manual SSH test
ssh user@n8n.maintpc.com

# Copy file to VPS
scp local-file.txt user@vps:/remote/path/

# Copy file from VPS
scp user@vps:/remote/file.txt ./local/path/
```

**On VPS:**
```bash
# Run internal check
bash check-vps-from-inside.sh

# Check Docker containers
docker ps

# Check n8n logs
docker logs n8n

# Test n8n locally
curl http://localhost:5678

# View report
cat ~/vps-readiness-report.txt
```

---

## 🎬 Quick Start (TL;DR)

**Just want to get started fast?**

```powershell
# 1. Run this (from Windows)
cd C:\Users\hharp\chucky_project
.\check-vps-readiness.ps1

# 2. If it says "READY", run this:
.\deploy-claude-to-vps.ps1

# 3. Done! 🎉
```

**If step 1 fails:**
- Use Hostinger web terminal
- Upload and run `check-vps-from-inside.sh`
- Fix any errors
- Try again

---

## 📞 Need Help?

**SSH Issues:**
- Check Hostinger VPS panel for SSH settings
- Try Hostinger web terminal as alternative
- Verify username and hostname are correct

**n8n Issues:**
- Check if container is running: `docker ps`
- Check logs: `docker logs n8n`
- Verify docker-compose.yml configuration

**General VPS Issues:**
- Contact Hostinger support
- Check VPS status in Hostinger panel
- Verify VPS is not suspended or offline

---

**Created:** 2025-11-03
**Files in this package:**
- `check-vps-readiness.ps1` - Windows check script
- `check-vps-from-inside.sh` - VPS internal check
- `VPS_CHECK_GUIDE.md` - This guide
- `deploy-claude-to-vps.ps1` - Installation script

**Ready to check your VPS? Run the scripts above!** 🚀
