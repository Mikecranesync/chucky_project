# Telegram Bot Setup Guide - Remote /chucky Access

**Purpose:** Configure Telegram bot to execute `/chucky` commands remotely from your phone
**Prerequisite:** VPS Claude CLI deployed (see `VPS_CLAUDE_DEPLOYMENT_GUIDE.md`)
**Estimated Time:** 30-45 minutes
**Date:** 2025-11-04

---

## Overview

This guide sets up a Telegram bot that lets you run `/chucky` commands from anywhere using your phone's Telegram app.

**What You'll Build:**
```
Your Phone (Telegram) → Bot receives /chucky command →
n8n workflow → SSH to VPS → Execute claude /chucky →
Format response → Send back to Telegram
```

**Benefits:**
- Execute commands from anywhere
- Mobile-friendly interface
- Secure (user whitelist + rate limiting)
- Audit logging
- Error handling

---

## Step 1: Create Telegram Bot

### 1.1: Talk to @BotFather

1. Open Telegram on phone or desktop
2. Search for `@BotFather` (official Telegram bot)
3. Start a conversation: `/start`

### 1.2: Create New Bot

```
You: /newbot
BotFather: Alright, a new bot. How are we going to call it? Please choose a name for your bot.

You: Chucky Remote Manager
BotFather: Good. Now let's choose a username for your bot. It must end in `bot`. Like this, for example: TetrisBot or tetris_bot.

You: chucky_remote_bot
BotFather: Done! Congratulations on your new bot.
```

**You'll receive:**
- Bot token: `123456789:ABCdefGhIJKlmNoPQRstuVWxyZ1234567890`
- Bot link: `t.me/chucky_remote_bot`

**⚠️ IMPORTANT:** Save the bot token securely! You'll need it for n8n.

---

## Step 2: Get Your Telegram User ID

You need your user ID to whitelist yourself in the workflow.

**Method 1: Use @userinfobot**
1. Search for `@userinfobot` in Telegram
2. Send any message to it
3. It will reply with your ID: `Your user ID: 123456789`

**Method 2: Use @getidsbot**
1. Search for `@getidsbot`
2. Send `/start`
3. Your ID will be shown

**Save your user ID** - you'll add it to the workflow's whitelist.

---

## Step 3: Import Workflow into n8n

### 3.1: Access Your n8n Instance

Open: `https://n8n.maintpc.com`

### 3.2: Import Workflow

1. Click **Workflows** (left sidebar)
2. Click **Import from File**
3. Select `ChuckyTelegramRemote.json`
4. Click **Import**

**Workflow imported!** You'll see 15 nodes.

---

## Step 4: Configure Telegram Credentials

### 4.1: Create Telegram Credential

1. Go to **Settings** → **Credentials**
2. Click **Add Credential**
3. Search for **Telegram**
4. Select **Telegram API**
5. Enter:
   - **Access Token**: (paste your bot token from Step 1)
6. Click **Save**
7. Name it: `telegram_bot`

### 4.2: Test Connection

1. Click **Test** button
2. Should show: ✅ Connection successful

---

## Step 5: Configure SSH Credentials

### 5.1: Create SSH Password Credential

1. Go to **Settings** → **Credentials**
2. Click **Add Credential**
3. Search for **SSH**
4. Select **SSH (Password)**
5. Enter:
   - **Host**: `n8n.maintpc.com`
   - **Port**: `22`
   - **Username**: `root` (or your VPS username)
   - **Password**: (your VPS SSH password)
6. Click **Save**
7. Name it: `vps_ssh_credentials`

### 5.2: Test SSH Connection

Open PowerShell:
```powershell
ssh root@n8n.maintpc.com
# Should connect without errors
# Type 'exit' to disconnect
```

---

## Step 6: Configure Workflow Security

### 6.1: Update User Whitelist

1. In n8n workflow, find node: **Parse & Validate Command**
2. Click to open it
3. Find this line in the code:
   ```javascript
   const ALLOWED_USER_IDS = [
     123456789  // PLACEHOLDER - CHANGE THIS!
   ];
   ```

4. Replace `123456789` with YOUR Telegram user ID from Step 2
5. Click **Execute Node** to save

**Example:**
```javascript
const ALLOWED_USER_IDS = [
  987654321  // Your actual ID
];
```

**Multiple users:**
```javascript
const ALLOWED_USER_IDS = [
  987654321,  // You
  111222333   // Team member
];
```

---

## Step 7: Configure Supabase Audit Logging

### 7.1: Create Audit Table in Supabase

1. Go to your Supabase dashboard
2. Open **SQL Editor**
3. Run this SQL:

```sql
CREATE TABLE IF NOT EXISTS chucky_audit (
  id SERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  user_id TEXT,
  username TEXT,
  command TEXT,
  platform TEXT,
  execution_time_ms INT,
  success BOOLEAN,
  error TEXT
);

-- Create index for faster queries
CREATE INDEX idx_chucky_audit_timestamp ON chucky_audit(timestamp DESC);
CREATE INDEX idx_chucky_audit_user ON chucky_audit(user_id);
```

### 7.2: Configure Supabase Credential in n8n

1. Go to **Settings** → **Credentials**
2. Click **Add Credential**
3. Search for **Supabase**
4. Select **Supabase API**
5. Enter:
   - **Host**: `your-project.supabase.co`
   - **Service Role Key**: (from Supabase Settings → API)
6. Click **Save**
7. Name it: `supabase`

**Optional:** If you don't want audit logging, you can disable the "Audit Log (Supabase)" node in the workflow.

---

## Step 8: Activate Workflow

### 8.1: Enable Workflow

1. In n8n, open the **Chucky Telegram Remote** workflow
2. Click the **Active** toggle (top right)
3. Should show: ✅ Active

### 8.2: Verify Webhook

1. In workflow, click on **Telegram Trigger** node
2. Click **Execute Node**
3. Should show: Webhook URL registered

**Webhook URL format:**
```
https://n8n.maintpc.com/webhook/chucky-telegram-webhook
```

---

## Step 9: Test from Your Phone

### 9.1: Find Your Bot

1. Open Telegram app
2. Search for your bot: `@chucky_remote_bot`
3. Click **Start** or send `/start`

### 9.2: Test Simple Command

Send this message:
```
/chucky What can you do?
```

**Expected response:**
```
⏳ Processing your request...

📝 Command: What can you do?

⏱ This may take 10-60 seconds...
```

Then after ~20 seconds:
```
✅ Command Completed

📝 Request: `What can you do?`

📤 Result:
```
[Manager capabilities listed]
```

⏱ Execution time: 18.3s
```

### 9.3: Test Node Creation

```
/chucky create a webhook trigger node
```

**Expected:** Complete node JSON returned.

### 9.4: Test Workflow Validation

```
/chucky validate ChuckyDiscordRAG.json
```

**Expected:** Validation report returned.

---

## Usage Examples

### Create a Node
```
/chucky create a Code node that parses JSON sensor data
```

### Validate Workflow
```
/chucky validate ChuckyDiscordRAG.json
```

### Use Workflow Template
```
/chucky production-ready ChuckyDiscordRAG.json
```

### Get Help
```
/chucky What slash commands are available?
```

### Session Memory (Follow-ups)
```
/chucky create a temperature monitoring node
# [Bot creates node]

/chucky add error handling to it
# [Bot adds error handling to the node it just created]
```

---

## Security Features

### ✅ User Whitelist
Only authorized Telegram user IDs can execute commands.

### ✅ Command Sanitization
Prevents shell injection attacks by removing dangerous characters.

### ✅ Rate Limiting
- Max 10 commands per 5 minutes per user
- Prevents abuse and API quota exhaustion

### ✅ Audit Logging
All commands logged to Supabase with:
- User ID & username
- Command executed
- Timestamp
- Execution time
- Success/failure status

### ✅ Error Handling
Graceful error messages instead of technical stack traces.

---

## Troubleshooting

### Issue: Bot doesn't respond

**Check:**
1. Workflow is **Active** (toggle is ON)
2. Telegram credentials are valid
3. Webhook is registered (click Telegram Trigger node, execute)
4. n8n instance is accessible from internet

**Solution:**
```bash
# SSH into VPS
ssh root@n8n.maintpc.com

# Check n8n is running
docker ps | grep n8n

# Check n8n logs
docker logs -f n8n-container-name
```

---

### Issue: "Unauthorized user" error

**Symptoms:** Bot replies with error message about unauthorized access

**Cause:** Your Telegram user ID is not in the whitelist

**Solution:**
1. Get your user ID from @userinfobot
2. Update whitelist in **Parse & Validate Command** node
3. Save and re-activate workflow

---

### Issue: SSH connection failed

**Symptoms:** Workflow shows SSH error

**Check:**
1. VPS is accessible: `ping n8n.maintpc.com`
2. SSH credentials are correct
3. SSH port 22 is open
4. Claude CLI is installed on VPS

**Solution:**
```bash
# Test SSH manually
ssh root@n8n.maintpc.com

# Once connected, test Claude
claude /chucky --help

# Should return help text
```

---

### Issue: Rate limit exceeded

**Symptoms:** "Rate limit exceeded. Please wait X seconds"

**Cause:** Too many commands sent in short time (>10 in 5 minutes)

**Solution:** Wait the specified time, then try again.

**To adjust limits:** Edit **Parse & Validate Command** node:
```javascript
const MAX_COMMANDS = 10;  // Change this
const RATE_LIMIT_WINDOW = 5 * 60 * 1000;  // 5 minutes
```

---

### Issue: Command takes too long

**Symptoms:** Timeout or no response after 60+ seconds

**Causes:**
- VPS is slow (low resources)
- Complex command requires more time
- Network latency

**Solutions:**
1. Use simpler commands first
2. Upgrade VPS plan for more resources
3. Check VPS CPU/memory usage:
   ```bash
   ssh root@n8n.maintpc.com
   top
   free -h
   ```

---

### Issue: Audit logging fails

**Symptoms:** Workflow shows error at Audit Log node

**Causes:**
- Supabase table doesn't exist
- Supabase credentials invalid
- Table schema mismatch

**Solutions:**
1. Run the SQL from Step 7.1 again
2. Check Supabase credentials
3. Or disable the Audit Log node (set **Continue On Fail** to true)

---

## Advanced Configuration

### Custom Bot Commands

Add custom commands to your bot:

1. Message @BotFather: `/setcommands`
2. Select your bot
3. Enter commands:
```
chucky - Execute Chucky manager command
help - Show available commands
status - Check bot status
```

### Add More Users

Edit whitelist:
```javascript
const ALLOWED_USER_IDS = [
  987654321,  // You
  111222333,  // Team member 1
  444555666   // Team member 2
];
```

### Adjust Response Formatting

Edit **Format Response** node to customize Telegram message format.

### Add Confirmation for Destructive Commands

Add logic to ask for confirmation before executing certain commands:
```javascript
if (command.includes('delete') || command.includes('remove')) {
  // Send confirmation request
  // Wait for user response
}
```

---

## Monitoring & Maintenance

### View Audit Logs

Query Supabase to see command history:

```sql
-- Recent commands
SELECT * FROM chucky_audit
ORDER BY timestamp DESC
LIMIT 50;

-- Commands by user
SELECT username, COUNT(*) as total_commands
FROM chucky_audit
GROUP BY username;

-- Failed commands
SELECT * FROM chucky_audit
WHERE success = false
ORDER BY timestamp DESC;

-- Average execution time
SELECT AVG(execution_time_ms) as avg_ms,
       MAX(execution_time_ms) as max_ms
FROM chucky_audit
WHERE success = true;
```

### Monitor Usage

Check workflow executions in n8n:
1. Go to **Executions** tab
2. Filter by "Chucky Telegram Remote"
3. Review success/failure rates

---

## Next Steps

Once Telegram bot is working:

### ✅ You Can Now:
- Execute `/chucky` commands from anywhere
- Create and validate nodes on the go
- Run workflow templates remotely
- Get instant results on your phone

### 🚀 Optional Enhancements:
1. **Add Discord bot** (similar setup, richer formatting)
2. **Add voice commands** (Telegram voice notes → transcribe → execute)
3. **Add file uploads** (send workflow JSON files for validation)
4. **Add status notifications** (get alerts when workflows fail)
5. **Add interactive buttons** (approve/reject before executing)

### 📖 Related Guides:
- `VPS_CLAUDE_DEPLOYMENT_GUIDE.md` - VPS setup
- `CHUCKY_MANAGER_USER_GUIDE.md` - /chucky command reference
- `REMOTE_SECURITY_GUIDE.md` - Security best practices

---

## Quick Reference

### Bot Commands
```
/chucky [your request] - Execute Chucky command
/help - Show help
/start - Start bot
```

### Example Requests
```
/chucky create a webhook node
/chucky validate ChuckyDiscordRAG.json
/chucky production-ready workflow.json
/chucky What can you do?
```

### Credentials Needed
- Telegram bot token (from @BotFather)
- VPS SSH credentials
- Supabase credentials (optional, for audit logs)
- Your Telegram user ID (for whitelist)

### Files Created
- `ChuckyTelegramRemote.json` - n8n workflow (338 lines)
- Supabase `chucky_audit` table

---

**Setup Date:** 2025-11-04
**Version:** 1.0.0
**Maintainer:** Claude Code + User
**Support:** See troubleshooting section or GitHub issues
