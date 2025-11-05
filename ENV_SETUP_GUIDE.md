# Environment Variables Setup Guide

**Version:** 1.0.0
**Date:** 2025-11-04
**Purpose:** Secure credential management using `.env` files

---

## Quick Start

### Step 1: Create Your `.env` File

```powershell
# Copy the template
Copy-Item .env.example .env

# Edit with your actual values
notepad .env
```

### Step 2: Fill In Your Secrets

Replace all `YOUR_*_HERE` placeholders with real values.

### Step 3: Load Environment Variables

**On Windows:**
```powershell
# Load .env into current session
. .\load-env.ps1
```

**On VPS/Linux:**
```bash
# Load .env into current session
source ./load-env.sh
```

---

## Getting Your API Keys

### 1. Claude API Key

**Get your existing key:**
```powershell
claude config get apiKey
```

**Or generate new key:**
1. Go to: https://console.anthropic.com/settings/keys
2. Click **Create Key**
3. Name: "Chucky Project"
4. Copy the key (starts with `sk-ant-api03_`)
5. Paste in `.env`: `ANTHROPIC_API_KEY=sk-ant-api03_...`

---

### 2. Telegram Bot Token

**Create bot:**
1. Message @BotFather on Telegram
2. Send: `/newbot`
3. Follow prompts
4. Copy bot token (format: `123456789:ABC...`)
5. Paste in `.env`: `TELEGRAM_BOT_TOKEN=123456789:ABC...`

**Get your user ID:**
1. Message @userinfobot on Telegram
2. Copy your user ID (format: `987654321`)
3. Paste in `.env`: `TELEGRAM_USER_ID=987654321`

---

### 3. n8n API Key

**Generate key:**
1. Go to: `https://n8n.maintpc.com/settings/api`
2. Click **Create API Key**
3. Name: "Chucky Remote Access"
4. Copy the key (format: `n8n_api_...`)
5. Paste in `.env`: `N8N_API_KEY=n8n_api_...`

---

### 4. Supabase Keys

**Get keys:**
1. Go to: https://supabase.com/dashboard
2. Select your project
3. Go to: Settings → API
4. Copy:
   - **URL:** `https://yourproject.supabase.co`
   - **anon/public key:** `eyJhbGci...`
   - **service_role key:** `eyJhbGci...`
5. Paste in `.env`:
   ```
   SUPABASE_URL=https://yourproject.supabase.co
   SUPABASE_ANON_KEY=eyJhbGci...
   SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
   ```

---

### 5. Google API Keys (Optional)

**For Google Drive & Gemini:**
1. Go to: https://console.cloud.google.com/apis/credentials
2. Create OAuth 2.0 credentials
3. Create API key for Gemini
4. Copy and paste in `.env`

---

### 6. VPS SSH Credentials

**Get from Hostinger panel:**
1. Log into Hostinger
2. VPS → SSH Access
3. Copy:
   - Host: `n8n.maintpc.com`
   - User: Usually `root`
   - Password: From panel
4. Paste in `.env`:
   ```
   VPS_HOST=n8n.maintpc.com
   VPS_SSH_USER=root
   VPS_SSH_PASSWORD=your_password
   ```

---

## Using Environment Variables

### In PowerShell Scripts

```powershell
# Load .env first
. .\load-env.ps1

# Then use the variables
$apiKey = $env:ANTHROPIC_API_KEY
$vpsHost = $env:VPS_HOST

# Example: SSH with .env credentials
ssh "$env:VPS_SSH_USER@$env:VPS_HOST"

# Example: Deploy with .env
.\deploy-claude-to-vps.ps1
# Script will automatically use .env values if loaded
```

---

### In Bash Scripts (VPS)

```bash
# Load .env first
source ./load-env.sh

# Then use the variables
API_KEY=$ANTHROPIC_API_KEY
VPS_HOST=$VPS_HOST

# Example: Configure Claude
claude config set apiKey "$ANTHROPIC_API_KEY"

# Example: Export for other scripts
export ANTHROPIC_API_KEY
export N8N_API_KEY
```

---

### In n8n Workflows

**Option 1: Use n8n Credentials (Recommended)**
1. Create credentials in n8n
2. Reference in workflow nodes

**Option 2: Environment Variables**
1. Set on VPS in `~/.bashrc`:
   ```bash
   export ANTHROPIC_API_KEY="sk-ant-api..."
   export N8N_API_KEY="n8n_api..."
   ```
2. Restart n8n to load variables
3. Reference in workflows: `{{ $env.ANTHROPIC_API_KEY }}`

---

## Updated Deployment Process

### With `.env` File

**Before (manual entry):**
```powershell
.\deploy-claude-to-vps.ps1
# Prompted for: VPS host, user, password, API keys...
# Had to type everything manually
```

**After (using .env):**
```powershell
# 1. Load environment
. .\load-env.ps1

# 2. Deploy (uses .env automatically)
.\deploy-claude-to-vps.ps1
# No prompts! Uses values from .env
```

---

## Updating Deployment Scripts

You can modify `deploy-claude-to-vps.ps1` to use `.env`:

```powershell
# At the top of deploy-claude-to-vps.ps1
. .\load-env.ps1

# Then use environment variables instead of prompts
$VpsHost = $env:VPS_HOST
$VpsUser = $env:VPS_SSH_USER
$VpsPassword = $env:VPS_SSH_PASSWORD
$ClaudeApiKey = $env:ANTHROPIC_API_KEY
$N8nApiKey = $env:N8N_API_KEY

# Rest of script...
```

---

## Security Best Practices

### ✅ DO:

1. **Keep `.env` local only**
   - Already in `.gitignore`
   - Never commit to git
   - Never share publicly

2. **Use different `.env` files per environment**
   ```
   .env.development
   .env.staging
   .env.production
   ```

3. **Rotate keys regularly**
   - Every 90 days
   - Update `.env` with new keys
   - Revoke old keys

4. **Use strong passwords**
   - VPS password: 16+ characters
   - Use password manager

5. **Backup `.env` securely**
   - Store in password manager
   - Encrypted backup
   - Not in cloud storage

---

### ❌ DON'T:

1. **Never commit `.env` to git**
   ```bash
   # Check before committing
   git status
   # Should NOT show .env
   ```

2. **Never share `.env` via**
   - Email
   - Slack/Discord
   - Screenshots
   - Pastebin

3. **Never use placeholder values in production**
   ```
   # BAD - placeholder not replaced
   ANTHROPIC_API_KEY=YOUR_KEY_HERE

   # GOOD - actual key
   ANTHROPIC_API_KEY=sk-ant-api03_actual_key
   ```

4. **Never use production keys in development**
   - Use separate API keys
   - Separate bot tokens
   - Separate databases

---

## Troubleshooting

### Issue: "Environment variables not loading"

**Symptom:** `$env:ANTHROPIC_API_KEY` is empty

**Solution:**
```powershell
# Make sure you sourced the script (note the dot)
. .\load-env.ps1

# NOT:
.\load-env.ps1  # This won't work!
```

---

### Issue: "Placeholder values warning"

**Symptom:** Script shows "has placeholder value - please update!"

**Solution:**
1. Open `.env`
2. Find lines with `YOUR_*_HERE`
3. Replace with actual values
4. Save and reload: `. .\load-env.ps1`

---

### Issue: ".env file not found"

**Symptom:** Script says ".env file not found"

**Solution:**
```powershell
# Create from template
Copy-Item .env.example .env

# Edit with your values
notepad .env
```

---

### Issue: "Invalid format"

**Symptom:** "Invalid format (expected KEY=VALUE)"

**Solution:**
- Check for spaces around `=`
- Should be: `KEY=value` (no spaces)
- Not: `KEY = value` (spaces = error)

---

## Example `.env` File

```bash
# Working example (replace with your actual values)

# Claude API
ANTHROPIC_API_KEY=sk-ant-api03_1234567890abcdefghijklmnop

# VPS
VPS_HOST=n8n.maintpc.com
VPS_SSH_PORT=22
VPS_SSH_USER=root
VPS_SSH_PASSWORD=MySecureP@ssw0rd123

# n8n
N8N_API_KEY=n8n_api_abc123def456
N8N_API_BASE_URL=https://n8n.maintpc.com/api/v1

# Telegram
TELEGRAM_BOT_TOKEN=123456789:ABCdefGhI-JKlmnoPQRst123456
TELEGRAM_USER_ID=987654321

# Supabase
SUPABASE_URL=https://myproject.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abc123

# Google
GOOGLE_GEMINI_API_KEY=AIzaSyD1234567890abcdefghijklmnop
```

---

## Checking What's Loaded

### PowerShell

```powershell
# After loading .env
. .\load-env.ps1

# Check specific variable
$env:ANTHROPIC_API_KEY

# Check all environment variables
Get-ChildItem Env: | Where-Object { $_.Name -match 'ANTHROPIC|VPS|TELEGRAM|N8N' }
```

### Bash

```bash
# After loading .env
source ./load-env.sh

# Check specific variable
echo $ANTHROPIC_API_KEY

# Check all loaded variables
env | grep -E 'ANTHROPIC|VPS|TELEGRAM|N8N'
```

---

## Integration with Existing Scripts

### Update `deploy-claude-to-vps.ps1`

Add at the top:

```powershell
# Load environment variables
if (Test-Path ".env") {
    . .\load-env.ps1
    Write-Host "Using credentials from .env"
} else {
    Write-Host "No .env found, will prompt for values"
}

# Use .env values with fallback to prompts
$VpsHost = if ($env:VPS_HOST) { $env:VPS_HOST } else { Read-Host "VPS Host" }
$VpsUser = if ($env:VPS_SSH_USER) { $env:VPS_SSH_USER } else { Read-Host "SSH User" }
# ... etc
```

---

## Files Reference

| File | Purpose |
|------|---------|
| `.env.example` | Template with all variables |
| `.env` | Your actual secrets (gitignored) |
| `load-env.ps1` | PowerShell loader |
| `load-env.sh` | Bash loader |
| `.gitignore` | Ensures .env never committed |

---

## Migration Checklist

- [ ] Copy `.env.example` to `.env`
- [ ] Fill in all API keys
- [ ] Fill in VPS credentials
- [ ] Fill in Telegram bot token
- [ ] Fill in Telegram user ID
- [ ] Fill in Supabase credentials
- [ ] Test loading: `. .\load-env.ps1`
- [ ] Verify variables: `$env:ANTHROPIC_API_KEY`
- [ ] Update deployment scripts to use .env
- [ ] Test deployment with .env
- [ ] Backup .env to password manager
- [ ] Never commit .env to git!

---

**Version:** 1.0.0
**Last Updated:** 2025-11-04
**Security:** Keep .env secret and secure!
