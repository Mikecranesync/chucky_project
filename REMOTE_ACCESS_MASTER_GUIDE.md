# Chucky Remote Access - Master Guide

**Complete guide for accessing `/chucky` commands from anywhere**

Version: 1.0.0
Date: 2025-11-04

---

## Quick Start (TL;DR)

**Goal:** Run `/chucky` commands from your phone

**3 Steps:**
1. Deploy Claude CLI to VPS (30 min) → `VPS_CLAUDE_DEPLOYMENT_GUIDE.md`
2. Set up Telegram bot (30 min) → `TELEGRAM_REMOTE_SETUP_GUIDE.md`
3. Test from phone (5 min) → `REMOTE_ACCESS_TESTING_CHECKLIST.md`

**Total Time:** ~75 minutes

---

## What You Get

### Before Remote Access
- `/chucky` only works on local Windows machine
- Must be at computer to manage workflows
- No mobile access

### After Remote Access
- Execute `/chucky` from anywhere via Telegram
- Manage workflows from phone
- All 4 workflow templates available remotely
- Session memory works across devices
- Secure with user whitelist + rate limiting

---

## Architecture

```
Your Phone (Telegram)
    ↓
Telegram Bot API
    ↓
n8n Workflow (on VPS)
    ↓
SSH to VPS
    ↓
Claude CLI executes: claude /chucky [command]
    ↓
Manager Agent routes to sub-agents
    ↓
Result formatted and sent back to Telegram
```

---

## Implementation Guide

### Phase 1: VPS Deployment

**Purpose:** Install Claude CLI on your VPS

**Files:**
- `VPS_CLAUDE_DEPLOYMENT_GUIDE.md` - Complete setup guide
- `check-vps-readiness.ps1` - Automated checks
- `deploy-claude-to-vps.ps1` - Deployment script
- `setup-claude-on-vps.sh` - VPS setup script

**Steps:**
1. Run `.\check-vps-readiness.ps1`
2. Run `.\deploy-claude-to-vps.ps1`
3. Test: `ssh root@n8n.maintpc.com "claude /chucky test"`

**Success Criteria:**
- Claude CLI responds on VPS
- API keys configured
- `.claude/` directory present

---

### Phase 2: Telegram Bot

**Purpose:** Create mobile interface for `/chucky`

**Files:**
- `TELEGRAM_REMOTE_SETUP_GUIDE.md` - Setup instructions
- `ChuckyTelegramRemote.json` - n8n workflow (import this)
- `audit_logging_schema.sql` - Supabase audit table

**Steps:**
1. Create bot with @BotFather
2. Get your Telegram user ID (@userinfobot)
3. Import workflow into n8n
4. Configure credentials
5. Update user whitelist
6. Activate workflow

**Success Criteria:**
- Bot responds to `/chucky` commands
- Results returned within 60 seconds
- Security features working

---

### Phase 3: Testing

**Purpose:** Validate everything works

**Files:**
- `REMOTE_ACCESS_TESTING_CHECKLIST.md` - 24 test scenarios

**Critical Tests:**
1. Simple command works
2. Node creation works
3. Session memory works
4. Security blocks unauthorized users
5. Rate limiting prevents abuse

**Success Criteria:**
- All basic tests pass
- No critical bugs
- Performance acceptable

---

## Security Features

### ✅ User Whitelist
Only authorized Telegram IDs can execute commands.

**Configure in:** `Parse & Validate Command` node
```javascript
const ALLOWED_USER_IDS = [
  YOUR_TELEGRAM_ID_HERE
];
```

### ✅ Command Sanitization
Prevents shell injection by removing dangerous characters.

**Protected against:**
- `;`, `|`, `` ` ``, `$`, `()` - Shell operators
- `../` - Directory traversal

### ✅ Rate Limiting
- **Limit:** 10 commands per 5 minutes per user
- **Prevents:** API abuse, quota exhaustion
- **Adjustable** in Code node

### ✅ Audit Logging
All commands logged to Supabase:
- User ID & username
- Command text
- Timestamp
- Execution time
- Success/failure

**Schema:** `audit_logging_schema.sql`

### ✅ SSH Security
- Password-protected SSH
- No root login recommended
- Use SSH keys for production

---

## Usage Examples

### Create a Node
```
/chucky create a webhook trigger node for Discord
```

**Response:** Complete node JSON in ~20 seconds

### Validate Workflow
```
/chucky validate ChuckyDiscordRAG.json
```

**Response:** Validation report with errors/warnings

### Production Ready Check
```
/chucky production-ready ChuckyDiscordRAG.json
```

**Response:** Complete validation pipeline (5-8 min)
- Test scenarios
- Structure validation
- Security audit
- Deployment guide

### Session Memory
```
You: /chucky create a sensor monitoring node
Bot: [Creates node]

You: /chucky add error handling to it
Bot: [Adds error handling to sensor node]

You: /chucky now generate tests for that
Bot: [Creates tests for sensor node with error handling]
```

---

## Troubleshooting

### Bot Doesn't Respond

**Check:**
1. Workflow is Active in n8n
2. Webhook registered (execute Telegram Trigger node)
3. VPS is accessible: `ping n8n.maintpc.com`
4. n8n is running: `ssh root@n8n.maintpc.com "docker ps"`

**Common Causes:**
- n8n container stopped
- Webhook not registered
- VPS firewall blocking

---

### "Unauthorized User" Error

**Cause:** Your Telegram ID not in whitelist

**Fix:**
1. Get your ID: Message @userinfobot
2. Edit `Parse & Validate Command` node
3. Add your ID to `ALLOWED_USER_IDS` array
4. Save and re-activate workflow

---

### Commands Time Out

**Causes:**
- VPS is slow (low resources)
- Complex command
- Network latency

**Solutions:**
1. Check VPS resources:
   ```bash
   ssh root@n8n.maintpc.com
   top
   free -h
   df -h
   ```
2. Upgrade VPS plan if needed
3. Use simpler commands first

---

### Rate Limit Hit

**Message:** "Rate limit exceeded. Wait X seconds"

**Cause:** Sent >10 commands in 5 minutes

**Solutions:**
- Wait the specified time
- Adjust limits in Code node if needed

---

## Performance Benchmarks

| Operation | Target Time | Maximum |
|-----------|-------------|---------|
| Simple node creation | < 30s | < 60s |
| Workflow validation | < 20s | < 45s |
| Complex feature | 2-5 min | < 8 min |
| Production-ready | 5-8 min | < 12 min |

**If slower:**
- Check VPS CPU/RAM usage
- Consider VPS upgrade
- Check network latency

---

## Monitoring

### View Audit Logs

```sql
-- Recent commands
SELECT * FROM chucky_audit
ORDER BY timestamp DESC
LIMIT 50;

-- Failed commands
SELECT * FROM chucky_audit
WHERE success = false
ORDER BY timestamp DESC;

-- User statistics
SELECT username,
       COUNT(*) as total,
       AVG(execution_time_ms) as avg_ms
FROM chucky_audit
GROUP BY username;
```

### n8n Execution Logs

1. Go to n8n → Executions
2. Filter: "Chucky Telegram Remote"
3. Review success/failure rates
4. Check execution times

---

## Advanced Features

### Add More Users

```javascript
const ALLOWED_USER_IDS = [
  987654321,  // You
  111222333,  // Team member
  444555666   // Another user
];
```

### Custom Bot Commands

Message @BotFather:
```
/setcommands
> Select your bot
> Enter:
chucky - Execute Chucky manager command
help - Show help
status - Check status
```

### Voice Commands (Future)

1. Add Speech-to-Text node (Whisper API)
2. Connect to Telegram voice message trigger
3. Transcribe → Execute as /chucky command

---

## Alternative Access Methods

### Option 1: Telegram Bot (Recommended)
**Pros:** Mobile-friendly, easy setup, good UX
**Cons:** Requires bot setup
**Time:** 30 min setup

### Option 2: Discord Bot
**Pros:** Rich embeds, slash commands, team-friendly
**Cons:** More complex setup
**Time:** 45 min setup
**Guide:** Coming soon

### Option 3: Direct SSH from Phone
**Pros:** No bot needed, full control
**Cons:** Typing on phone keyboard tedious
**Time:** 5 min setup

**Apps:**
- Android: Termux (free)
- iOS: Blink Shell ($20)

**Usage:**
```bash
ssh root@n8n.maintpc.com
cd ~/chucky_project
claude /chucky "your command"
```

### Option 4: Webhook API
**Pros:** Most flexible, can integrate anywhere
**Cons:** Most complex, no UI
**Time:** 2-3 hours
**Guide:** Coming soon

---

## Files Reference

### Setup Guides
- `VPS_CLAUDE_DEPLOYMENT_GUIDE.md` - VPS deployment (579 lines)
- `TELEGRAM_REMOTE_SETUP_GUIDE.md` - Telegram bot (432 lines)
- `REMOTE_ACCESS_TESTING_CHECKLIST.md` - Testing (24 scenarios)

### Workflow & Scripts
- `ChuckyTelegramRemote.json` - n8n workflow (338 lines, 15 nodes)
- `audit_logging_schema.sql` - Supabase schema (156 lines)
- `check-vps-readiness.ps1` - VPS verification
- `deploy-claude-to-vps.ps1` - Automated deployment
- `setup-claude-on-vps.sh` - VPS setup script

### Manager System
- `.claude/agents/chucky-manager.md` - Orchestration agent
- `.claude/commands/chucky.md` - Slash command reference
- `CHUCKY_MANAGER_USER_GUIDE.md` - How to use /chucky

---

## Support & Resources

### Documentation
- **This Guide:** Overview and quick start
- **VPS Guide:** Detailed VPS setup
- **Telegram Guide:** Bot setup instructions
- **Testing Checklist:** Validation procedures
- **Manager Guide:** /chucky command reference

### GitHub Issues
Report problems or request features

### Community
Share your setup and get help

---

## Next Steps

### ✅ After Setup Complete:

**You can:**
- Execute `/chucky` from anywhere
- Create/validate nodes on the go
- Run workflow templates remotely
- Test workflows from phone
- Get instant results

**Try these commands:**
```
/chucky What can you do?
/chucky create a webhook node
/chucky validate ChuckyDiscordRAG.json
/chucky production-ready workflow.json
```

### 🚀 Future Enhancements:

1. **Discord Integration** - Richer formatting, slash commands
2. **Voice Commands** - Speak your requests
3. **File Uploads** - Send workflow JSON files
4. **Interactive Approvals** - Confirm before executing
5. **Status Notifications** - Get alerts when workflows fail
6. **Multi-language** - Internationalization
7. **Analytics Dashboard** - Usage statistics and insights

---

**Version:** 1.0.0
**Last Updated:** 2025-11-04
**Maintainer:** Claude Code + User
**Status:** Production Ready
