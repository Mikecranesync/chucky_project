# VPS Claude CLI Deployment Guide

**Purpose:** Deploy Claude Code CLI to your Hostinger VPS for remote `/chucky` access
**VPS Domain:** n8n.maintpc.com
**Estimated Time:** 30-45 minutes
**Date:** 2025-11-04

---

## Overview

This guide walks you through deploying Claude Code CLI to your VPS so you can execute `/chucky` commands remotely from Telegram, Discord, or any device with SSH access.

**What You'll Get:**
- Claude CLI installed on VPS
- `/chucky` command accessible remotely
- All 5 sub-agents available on VPS
- All 7 slash commands functional
- Foundation for Telegram/Discord bot integration

---

## Prerequisites Check

Before starting, verify you have:

### On Your Local Machine (Windows)
- [x] PowerShell with administrator access
- [x] Project directory: `C:\Users\hharp\chucky_project`
- [x] Deployment scripts present:
  - `check-vps-readiness.ps1`
  - `deploy-claude-to-vps.ps1`
  - `setup-claude-on-vps.sh`
- [x] Claude API key (from local Claude Code)
- [x] SSH access to VPS

### On Your VPS
- [x] Running at: n8n.maintpc.com
- [x] n8n already installed and running
- [x] SSH access enabled
- [ ] Node.js installed (we'll verify)
- [ ] Claude CLI installed (we'll install)

### Credentials Needed
1. **VPS SSH credentials** (username/password or SSH key)
2. **Claude API key** (get from local: `claude config get apiKey`)
3. **n8n API key** (generate from n8n.maintpc.com if not exists)

---

## Step 1: Get Your Credentials

### 1.1: Get Claude API Key

On your local Windows machine:

```powershell
# Get your Claude API key
claude config get apiKey

# Should output: sk-ant-api...
# Save this - you'll need it for VPS configuration
```

**If not set locally:**
```powershell
# Set it first (get key from https://console.anthropic.com/settings/keys)
claude config set apiKey YOUR_API_KEY_HERE
```

---

### 1.2: Get n8n API Key

1. **Open n8n:** https://n8n.maintpc.com
2. **Navigate to:** Settings → API
3. **Create API Key:**
   - Click "Create API Key"
   - Name: "Claude CLI Remote Access"
   - Save the key (won't be shown again)

**Example API key format:** `n8n_api_1234567890abcdef...`

---

### 1.3: Get VPS SSH Credentials

**Check your Hostinger VPS panel:**
- Username: Usually `root` or your custom user
- Password: From Hostinger panel
- Host: `n8n.maintpc.com`
- Port: Usually `22`

**Test SSH access first:**
```powershell
# From PowerShell
ssh root@n8n.maintpc.com

# Or if you have a specific user:
ssh yourusername@n8n.maintpc.com
```

If SSH works, you'll see a Linux prompt. Type `exit` to return to PowerShell.

---

## Step 2: Check VPS Readiness

Run the automated VPS readiness checker:

```powershell
cd C:\Users\hharp\chucky_project

# Run readiness check
.\check-vps-readiness.ps1
```

**What it checks:**
- VPS is accessible via SSH
- Required ports are open (22, 80, 443, 5678)
- n8n is running
- Node.js is installed
- Git is available
- Disk space sufficient (>2GB free)
- Memory available (>500MB free)

**Expected Output:**
```
VPS Readiness Check
===================
✅ SSH access working
✅ n8n responding on n8n.maintpc.com
✅ Node.js v20.x.x installed
✅ Git installed
✅ Disk space: 25GB free
✅ Memory: 2GB available

Ready for Claude CLI deployment!
```

**If any checks fail:** See Troubleshooting section at end of this guide.

---

## Step 3: Deploy Claude CLI to VPS

### 3.1: Run Deployment Script

```powershell
# Still in project directory
.\deploy-claude-to-vps.ps1
```

**You'll be prompted for:**
1. VPS hostname: `n8n.maintpc.com`
2. SSH username: `root` (or your username)
3. SSH password: `*********`
4. Claude API key: `sk-ant-api...`
5. n8n API key: `n8n_api...`

**What the script does:**
1. Connects to VPS via SSH
2. Copies `setup-claude-on-vps.sh` to VPS
3. Executes setup script remotely
4. Installs Claude CLI via npm
5. Configures API keys
6. Copies `.claude/` directory structure
7. Copies `context/` files
8. Sets up environment variables
9. Creates helper scripts
10. Tests Claude CLI installation

**Expected Duration:** 5-10 minutes

**Expected Output:**
```
Connecting to VPS...
✅ Connected to n8n.maintpc.com

Copying setup script...
✅ setup-claude-on-vps.sh uploaded

Running setup...
Installing Node.js (if needed)...
Installing Claude CLI...
✅ Claude CLI v1.x.x installed

Configuring API keys...
✅ Claude API key configured
✅ n8n API key configured

Copying .claude directory...
✅ Agents copied (6 files)
✅ Commands copied (7 files)
✅ Settings copied

Copying context files...
✅ Context files copied (3 files)

Testing Claude CLI...
✅ Claude CLI responds correctly

Deployment complete! 🎉
```

---

### 3.2: Manual Verification (SSH into VPS)

Connect to VPS and verify installation:

```bash
# SSH into VPS
ssh root@n8n.maintpc.com

# Check Claude CLI is installed
claude --version
# Expected: Claude CLI v1.x.x

# Check .claude directory structure
ls -la ~/.claude/
# Expected: agents/ commands/ settings.local.json

# Check context files
ls -la ~/chucky_project/context/
# Expected: project_overview.md workflow_architecture.md discord_config.md

# Test /chucky command
claude /chucky --help
# Expected: Command help output

# Test simple command
claude /chucky "What can you do?"
# Expected: Manager agent responds with capabilities

# Exit VPS
exit
```

---

## Step 4: Configure Environment Variables

The deployment script should have created `~/.bashrc` entries. Verify:

```bash
# SSH into VPS
ssh root@n8n.maintpc.com

# Check environment variables
cat ~/.bashrc | grep -E "ANTHROPIC_API_KEY|N8N_API"

# Should see:
# export ANTHROPIC_API_KEY="sk-ant-api..."
# export N8N_API_KEY="n8n_api..."
# export N8N_API_BASE_URL="https://n8n.maintpc.com/api/v1"

# Reload bashrc
source ~/.bashrc

# Test variables are set
echo $ANTHROPIC_API_KEY
echo $N8N_API_KEY
```

---

## Step 5: Test Remote /chucky Commands

Now test that `/chucky` works on VPS:

```bash
# Still SSH'd into VPS

# Test 1: List capabilities
claude /chucky "What commands are available?"

# Test 2: Simple node creation (won't actually create, just shows JSON)
claude /chucky "Show me a webhook trigger node configuration"

# Test 3: List workflows (if n8n API key works)
claude /chucky "List all n8n workflows"

# Test 4: Validate a workflow
claude /chucky "Validate ChuckyDiscordRAG.json"
```

**If all tests pass:** ✅ VPS deployment successful!

**If tests fail:** See Troubleshooting section.

---

## Step 6: Create Project Directory Structure

Ensure the VPS has the proper project structure:

```bash
# SSH into VPS
ssh root@n8n.maintpc.com

# Create project directory if it doesn't exist
mkdir -p ~/chucky_project
cd ~/chucky_project

# Copy .claude directory (if not already done by script)
# This should already be done, but verify:
ls -la

# Expected structure:
# .claude/
# ├── agents/
# ├── commands/
# └── settings.local.json
# context/
# ├── project_overview.md
# ├── workflow_architecture.md
# └── discord_config.md
```

---

## Step 7: Performance Test

Test response times to ensure VPS performance is acceptable:

```bash
# SSH into VPS

# Simple command (should be < 30 seconds)
time claude /chucky "Create a Code node"

# Complex command (should be < 60 seconds)
time claude /chucky "Explain the Chucky architecture"
```

**Expected Performance:**
- Simple commands: 10-30 seconds
- Complex commands: 30-60 seconds

**If slower:** VPS may need more resources or network latency is high.

---

## Troubleshooting

### Issue: SSH Connection Failed

**Symptoms:** `ssh: connect to host n8n.maintpc.com port 22: Connection refused`

**Solutions:**
1. Check VPS is running in Hostinger panel
2. Verify SSH is enabled in Hostinger VPS settings
3. Check firewall rules (port 22 should be open)
4. Try Hostinger web terminal instead
5. Check DNS: `ping n8n.maintpc.com`

---

### Issue: Node.js Not Installed

**Symptoms:** `node: command not found`

**Solution:**
```bash
# Install Node.js 20.x on VPS
ssh root@n8n.maintpc.com

# For Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
npm --version
```

---

### Issue: Claude CLI Installation Failed

**Symptoms:** `npm install -g @anthropic-ai/claude-cli` fails

**Solution:**
```bash
# Try with sudo
sudo npm install -g @anthropic-ai/claude-cli

# Or install to user directory
npm install --prefix ~/.local @anthropic-ai/claude-cli
export PATH=~/.local/bin:$PATH
```

---

### Issue: Claude API Key Invalid

**Symptoms:** `Error: Invalid API key`

**Solution:**
1. Verify API key is correct (no extra spaces)
2. Generate new API key at https://console.anthropic.com/settings/keys
3. Set on VPS:
   ```bash
   claude config set apiKey YOUR_NEW_KEY
   ```

---

### Issue: /chucky Command Not Found

**Symptoms:** `bash: /chucky: No such file or directory`

**Solution:**
```bash
# /chucky is not a system command, it's a Claude CLI command
# Must be invoked as:
claude /chucky "your request"

# NOT:
/chucky "your request"  # This won't work
```

---

### Issue: .claude Directory Missing

**Symptoms:** `/chucky` commands fail with "no such agent"

**Solution:**
```bash
# Manually copy from local to VPS
# From Windows PowerShell:
scp -r .claude root@n8n.maintpc.com:~/chucky_project/
scp -r context root@n8n.maintpc.com:~/chucky_project/

# Then on VPS, verify:
ssh root@n8n.maintpc.com
ls -la ~/chucky_project/.claude/
ls -la ~/chucky_project/context/
```

---

### Issue: Slow Response Times

**Symptoms:** Commands take > 60 seconds

**Solutions:**
1. **Check VPS resources:**
   ```bash
   free -h  # Memory usage
   df -h    # Disk usage
   top      # CPU usage
   ```

2. **Upgrade VPS plan** in Hostinger if resources are maxed out

3. **Check network latency:**
   ```bash
   ping api.anthropic.com
   ```

4. **Consider using haiku model** for faster responses in `.claude/settings.local.json`

---

### Issue: n8n API Key Not Working

**Symptoms:** Commands that query n8n workflows fail

**Solution:**
1. **Regenerate API key** in n8n.maintpc.com (Settings → API)
2. **Update on VPS:**
   ```bash
   ssh root@n8n.maintpc.com
   echo 'export N8N_API_KEY="your_new_key"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Test API access:**
   ```bash
   curl -H "X-N8N-API-KEY: $N8N_API_KEY" https://n8n.maintpc.com/api/v1/workflows
   # Should return JSON list of workflows
   ```

---

## Security Checklist

After deployment, verify security:

- [ ] SSH password is strong (or using SSH keys)
- [ ] Claude API key is stored in environment variable (not hardcoded)
- [ ] n8n API key is stored in environment variable
- [ ] VPS firewall is configured (only necessary ports open)
- [ ] SSH is using non-default port (optional but recommended)
- [ ] Fail2ban is configured (optional, prevents brute force)
- [ ] Regular backups are enabled in Hostinger

---

## Next Steps

Once VPS deployment is complete:

### ✅ You Can Now:
1. **SSH from phone** and run Claude commands directly
2. **Build Telegram bot** that calls Claude on VPS (Phase 2)
3. **Build Discord bot** that calls Claude on VPS (Phase 3)
4. **Automate workflows** with cron jobs on VPS

### 🚀 Proceed to Phase 2:
- **Telegram Bot Integration** - See `TELEGRAM_REMOTE_SETUP_GUIDE.md`
- Or use Direct SSH from phone (see instructions below)

---

## Direct SSH Access from Phone (Alternative to Telegram/Discord)

If you want immediate access without building bot workflows:

### Android:
1. **Install Termux** (free, F-Droid or GitHub)
2. Open Termux:
   ```bash
   pkg install openssh
   ssh root@n8n.maintpc.com
   cd ~/chucky_project
   claude /chucky "your command"
   ```

### iOS:
1. **Install Blink Shell** ($20) or Termius (free tier)
2. Configure SSH connection to n8n.maintpc.com
3. Connect and run:
   ```bash
   cd ~/chucky_project
   claude /chucky "your command"
   ```

---

## Files Created on VPS

After successful deployment:

```
~/chucky_project/
├── .claude/
│   ├── agents/
│   │   ├── chucky-manager.md
│   │   ├── n8n-workflow-expert.md
│   │   ├── industrial-knowledge-curator.md
│   │   ├── discord-integration-specialist.md
│   │   ├── documentation-maintainer.md
│   │   └── testing-coordinator.md
│   ├── commands/
│   │   ├── chucky.md
│   │   ├── chucky-node-builder.md
│   │   ├── chucky-workflow-validator.md
│   │   ├── chucky-doc-generator.md
│   │   ├── chucky-troubleshoot-builder.md
│   │   ├── chucky-test-scenario.md
│   │   └── chucky-embed-designer.md
│   └── settings.local.json
├── context/
│   ├── project_overview.md
│   ├── workflow_architecture.md
│   └── discord_config.md
└── README.md (optional)

~/.bashrc (updated with):
export ANTHROPIC_API_KEY="sk-ant-api..."
export N8N_API_KEY="n8n_api..."
export N8N_API_BASE_URL="https://n8n.maintpc.com/api/v1"
```

---

## Validation Checklist

Before proceeding to Phase 2, verify:

- [ ] Claude CLI installed on VPS (`claude --version` works)
- [ ] API keys configured (`echo $ANTHROPIC_API_KEY` returns key)
- [ ] `.claude/` directory present with all agents and commands
- [ ] `context/` files copied
- [ ] `/chucky` command responds (`claude /chucky --help`)
- [ ] Simple command works (`claude /chucky "create a node"`)
- [ ] n8n API accessible (if you have workflows to query)
- [ ] Response time acceptable (< 60 seconds)
- [ ] SSH access reliable and secure

---

## Success Criteria

**VPS deployment is successful when:**
1. ✅ You can SSH into VPS
2. ✅ `claude --version` returns version number
3. ✅ `claude /chucky "test"` returns a response
4. ✅ Environment variables are set correctly
5. ✅ All files are in place (`.claude/`, `context/`)
6. ✅ No error messages appear

**You're now ready for Phase 2: Telegram/Discord Bot Integration!**

---

**Deployment Date:** 2025-11-04
**Version:** 1.0.0
**Maintainer:** Claude Code + User
**Next:** `TELEGRAM_REMOTE_SETUP_GUIDE.md`
