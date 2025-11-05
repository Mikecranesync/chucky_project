# Telegram Webhook HTTPS Error - Fix Guide

**Error:** `Bad Request: bad webhook: An HTTPS URL must be provided for webhook`

**Date:** 2025-11-02
**n8n Instance:** http://localhost:5679 (local development)

---

## Problem

Telegram Bot API **requires HTTPS** for webhooks. Your local n8n instance runs on HTTP (`http://localhost:5679`), which Telegram won't accept.

**Why this happens:**
- Telegram webhooks need secure HTTPS connections
- Localhost uses HTTP (not secure)
- Telegram immediately rejects HTTP webhook URLs
- This is a security requirement from Telegram

---

## Solution Options

### ✅ Option 1: Switch to Polling Mode (RECOMMENDED for local dev)

**Best for:** Local development and testing

**How it works:**
- n8n checks Telegram every few seconds for new messages
- No webhook needed (no HTTPS required)
- Works perfectly with localhost
- Slight delay (2-5 seconds) but reliable

**Steps:**

1. **Open n8n** http://localhost:5679
2. **Find your Telegram Trigger node** (likely named "Chucky Telegram Trigger")
3. **Click on the node** to open settings
4. **Change to Polling Mode:**
   - Look for "Updates" or "Mode" setting
   - Select **"Polling"** instead of "Webhook"
   - Set poll interval: **Every 5 seconds** (or your preference)
5. **Save** the workflow
6. **Activate** the workflow

**Configuration Example:**
```json
{
  "updates": "message",
  "additionalFields": {
    "download": true
  }
}
```

---

### Option 2: Use ngrok for Temporary HTTPS

**Best for:** Testing webhooks temporarily

**Steps:**

1. **Install ngrok:**
   ```bash
   # Download from https://ngrok.com/download
   # Or use choco/scoop on Windows
   choco install ngrok
   ```

2. **Start ngrok tunnel:**
   ```bash
   ngrok http 5679
   ```

3. **Copy the HTTPS URL** (looks like: `https://abc123.ngrok.io`)

4. **Update n8n:**
   - Stop n8n container
   - Edit `docker-compose.local.yml`:
     ```yaml
     environment:
       - WEBHOOK_URL=https://abc123.ngrok.io/
     ```
   - Restart n8n

5. **Update Telegram node:**
   - Use webhook mode
   - n8n will register the ngrok URL with Telegram

**Limitations:**
- ⚠️ URL changes every time ngrok restarts
- ⚠️ Free tier has limits
- ⚠️ Requires ngrok running constantly

---

### Option 3: Deploy to VPS with HTTPS (Production solution)

**Best for:** Production use

You already have a VPS plan at: `https://n8n.maintpc.com`

**Steps:**

1. **Fix VPS n8n deployment** (you have a YAML error to resolve)
2. **Get SSL certificate** (Caddy handles this automatically)
3. **Import Chucky workflow** to VPS n8n
4. **Configure Telegram Bot:**
   - Use webhook mode
   - Webhook URL: `https://n8n.maintpc.com/webhook/...`
5. **Test and activate**

**Advantages:**
- ✅ Permanent HTTPS URL
- ✅ No localhost limitations
- ✅ Production-ready
- ✅ Real-time webhook responses (instant)

---

##  Comparison

| Feature | Polling (Local) | ngrok | VPS Production |
|---------|----------------|-------|----------------|
| **HTTPS Required** | ❌ No | ✅ Yes | ✅ Yes |
| **Works with Localhost** | ✅ Yes | ✅ Yes | ❌ No |
| **Response Time** | 2-5 sec delay | Instant | Instant |
| **Setup Difficulty** | ⭐ Easy | ⭐⭐ Medium | ⭐⭐⭐ Advanced |
| **Cost** | Free | Free tier | VPS cost |
| **Reliability** | ✅ High | ⚠️ Medium | ✅ High |
| **Production Ready** | ❌ No | ❌ No | ✅ Yes |

---

## Recommended Path

### For Now (Local Development):
**Use Option 1: Polling Mode**
- Quick to set up (5 minutes)
- Reliable for testing
- No additional tools needed
- Works great for development

### For Later (Production):
**Use Option 3: VPS Deployment**
- Fix your VPS setup at https://n8n.maintpc.com
- Deploy Chucky workflow
- Use webhooks for instant response
- Professional setup

---

## Step-by-Step: Switch to Polling (Detailed)

### 1. Open Workflow
```
http://localhost:5679/workflow/ET0fWxeEeuWDQCTp
```

### 2. Find Telegram Trigger Node
Look for nodes like:
- "Chucky Telegram Trigger"
- "Telegram Bot"
- Any node with Telegram icon

### 3. Configure Polling
Click the node and set:

**Type:** `n8n-nodes-base.telegramTrigger`

**Parameters:**
```json
{
  "updates": ["message"],
  "additionalFields": {
    "download": true
  }
}
```

**Credential:** Select your Telegram Bot API credential

### 4. Remove Webhook Settings
- Delete any webhook URL fields
- Remove any HTTPS-related settings
- Keep only the bot token

### 5. Save & Activate
- Click **Save** (top right)
- Toggle **Active** switch
- Watch for polling to start

### 6. Test
- Send a photo to your Telegram bot
- Wait 2-5 seconds
- Check n8n execution log
- Verify photo was processed

---

## Telegram Bot Setup (if needed)

If you don't have a Telegram Bot yet:

### 1. Create Bot with BotFather
1. Open Telegram and search for `@BotFather`
2. Send `/newbot`
3. Follow prompts to name your bot
4. **Copy the API token** (looks like: `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`)

### 2. Add Credential in n8n
1. Go to **Settings** → **Credentials**
2. Click **Add Credential**
3. Search for "Telegram"
4. Select **"Telegram API"**
5. Paste your bot token
6. Save

### 3. Configure Bot
Send to @BotFather:
```
/setprivacy - Disable (so bot can read all messages)
/setcommands - Add any commands you want
```

---

## Troubleshooting

### Error: "Webhook failed"
**Solution:** You're still in webhook mode. Switch to polling.

### Error: "Unauthorized"
**Solution:** Check your bot token in credentials.

### Bot doesn't respond
**Solutions:**
1. Check workflow is **Active** (toggle at top)
2. Verify Telegram trigger node is connected to workflow
3. Check n8n execution logs for errors
4. Test bot token with: `https://api.telegram.org/bot<TOKEN>/getMe`

### Photos not categorized
**Solutions:**
1. Check Google Drive OAuth is configured
2. Verify Gemini API credentials
3. Check Supabase connection
4. Review workflow execution logs

---

## Next Steps

### Immediate (5 minutes):
1. ✅ Switch Telegram trigger to polling mode
2. ✅ Save and activate workflow
3. ✅ Test by sending a photo to the bot

### Short-term:
1. Verify all credentials are configured:
   - Telegram Bot API
   - Google Drive OAuth2
   - Google Gemini API
   - Supabase API
2. Test full workflow end-to-end
3. Monitor for any errors

### Long-term:
1. Fix VPS deployment at https://n8n.maintpc.com
2. Migrate to production with webhooks
3. Set up monitoring and backups

---

## Files & Resources

**Created Files:**
- This guide: `C:\Users\hharp\chucky_project\TELEGRAM_WEBHOOK_FIX.md`

**n8n Workflow:**
- ID: `ET0fWxeEeuWDQCTp`
- Name: "Chucky"
- URL: http://localhost:5679/workflow/ET0fWxeEeuWDQCTp

**Documentation:**
- n8n Telegram Trigger: https://docs.n8n.io/integrations/builtin/trigger-nodes/n8n-nodes-base.telegramtrigger/
- Telegram Bot API: https://core.telegram.org/bots/api
- ngrok docs: https://ngrok.com/docs

---

**Created:** 2025-11-02
**Author:** Claude Code (Sonnet 4.5)
**Status:** Ready to implement
