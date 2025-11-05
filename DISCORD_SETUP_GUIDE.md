# Discord Setup Guide for Chucky Industrial Maintenance Bot

This guide walks you through setting up Discord infrastructure from scratch for the Chucky AI workflow.

## Part 1: Create Discord Server

### Step 1: Create New Server

1. Open Discord desktop app or web app (https://discord.com)
2. Click the **+** button in the server list (left sidebar)
3. Select **Create My Own**
4. Choose **For me and my friends** (or skip this step)
5. **Server Name:** `Chucky Industrial Maintenance`
6. Upload server icon (optional)
7. Click **Create**

### Step 2: Create Channel Structure

Delete the default channels and create this structure:

#### Text Channels:

1. **#equipment-analysis**
   - Purpose: Image analysis results from Gemini AI
   - Topic: "Equipment photo analysis and categorization"

2. **#troubleshooting**
   - Purpose: Interactive troubleshooting sessions
   - Topic: "Equipment diagnostic workflows and decision trees"

3. **#maintenance-logs**
   - Purpose: Maintenance action documentation
   - Topic: "Work orders, repairs, and service records"

4. **#alerts**
   - Purpose: Safety alerts and critical notifications
   - Topic: "⚠️ Critical safety issues and urgent equipment alerts"

5. **#search-results**
   - Purpose: RAG system queries and web searches
   - Topic: "Ask Chucky questions about your equipment"

6. **#bot-commands**
   - Purpose: Testing slash commands
   - Topic: "Test bot commands here: /troubleshoot, /analyze, /inspect, /status"

#### To Create Each Channel:

1. Click **+** next to "TEXT CHANNELS"
2. Enter channel name (include # symbol)
3. Set channel topic in channel settings (gear icon)
4. Click **Create Channel**

### Step 3: Configure Channel Permissions (Optional)

For production use, restrict bot to specific channels:

1. Right-click channel → **Edit Channel**
2. Go to **Permissions** tab
3. Click **+** next to "Roles/Members"
4. Add your bot role (you'll create this after making the bot)
5. Enable: **View Channel**, **Send Messages**, **Embed Links**, **Attach Files**

---

## Part 2: Create Discord Bot

### Step 1: Access Discord Developer Portal

1. Go to https://discord.com/developers/applications
2. Log in with your Discord account
3. Click **New Application** (top right)
4. **Application Name:** `Chucky AI Bot`
5. Accept Developer Terms of Service
6. Click **Create**

### Step 2: Configure Bot Settings

#### General Information Tab:

1. **Name:** Chucky AI Bot
2. **Description:** "Industrial maintenance troubleshooting assistant with AI-powered image analysis"
3. **App Icon:** Upload Chucky logo (optional)
4. **Tags:** Add tags like "utility", "productivity", "ai"
5. Click **Save Changes**

#### Bot Tab:

1. Click **Bot** in left sidebar
2. Click **Add Bot** → **Yes, do it!**
3. **Username:** `Chucky` (or preferred name)
4. **Icon:** Upload bot avatar
5. **Public Bot:** Toggle OFF (keep bot private to your server)
6. **Require OAuth2 Code Grant:** Toggle OFF

### Step 3: Enable Privileged Gateway Intents

**CRITICAL:** These intents are required for the bot to function:

1. Scroll down to **Privileged Gateway Intents**
2. Enable these toggles:
   - ✅ **Presence Intent** (optional - for user status)
   - ✅ **Server Members Intent** (for role-based access)
   - ✅ **Message Content Intent** (REQUIRED - to read message content)
3. Click **Save Changes**

### Step 4: Get Bot Token

**IMPORTANT:** The bot token is like a password - never share it publicly!

1. In **Bot** tab, scroll to **Token** section
2. Click **Reset Token** (if this is first time, it will say "Copy")
3. Click **Yes, do it!** to confirm
4. Click **Copy** to copy the token
5. **Save this token securely** - you'll need it for n8n credentials

**Token format:** `MTExMjM0NTY3ODkwMTIzNDU2Nw.GhIjKl.MnOpQrStUvWxYzAbCdEfGhIjKlMnOpQrStUvWxYz`

**Security Notes:**
- Never commit the token to Git
- Never share in screenshots or messages
- Store in password manager or environment variables
- Regenerate if compromised

---

## Part 3: Configure OAuth2 & Invite Bot

### Step 1: Configure OAuth2 URL Generator

1. Click **OAuth2** in left sidebar
2. Click **URL Generator** sub-tab
3. Under **Scopes**, select:
   - ✅ `bot`
   - ✅ `applications.commands` (for slash commands)

### Step 2: Set Bot Permissions

Under **Bot Permissions**, select:

#### Text Permissions:
- ✅ **Send Messages**
- ✅ **Send Messages in Threads**
- ✅ **Create Public Threads**
- ✅ **Create Private Threads**
- ✅ **Embed Links**
- ✅ **Attach Files**
- ✅ **Read Message History**
- ✅ **Mention Everyone** (for @here alerts)
- ✅ **Add Reactions**
- ✅ **Use Slash Commands**

#### Optional Permissions:
- ✅ **Manage Messages** (to delete/edit bot messages)
- ✅ **Manage Threads** (to archive resolved issues)

**Do NOT select:**
- ❌ Administrator (security risk)
- ❌ Manage Server
- ❌ Manage Roles (unless you need role automation)

### Step 3: Generate & Use Invite URL

1. Scroll down to **Generated URL** section
2. Copy the full URL (should look like: `https://discord.com/api/oauth2/authorize?client_id=123456789...`)
3. Paste URL in your browser
4. Select **Chucky Industrial Maintenance** server from dropdown
5. Click **Authorize**
6. Complete CAPTCHA
7. Click **Close** when done

### Step 4: Verify Bot Joined

1. Return to your Discord server
2. Check member list (right sidebar) - you should see **Chucky AI Bot** with "BOT" tag
3. Bot will appear offline until n8n workflow is activated

---

## Part 4: Gather Required Information

Before configuring n8n, collect these details:

### Bot Token
- From Developer Portal → Bot tab → Token section
- Format: `MTExMjM0NTY3ODkwMTIzNDU2Nw.GhIjKl.MnOp...`
- **NEVER share or commit this token**
- Store in n8n Cloud credentials or .env file

### Server ID (Guild ID)
1. In Discord, enable Developer Mode:
   - Settings → Advanced → Developer Mode → Toggle ON
2. Right-click your server icon → **Copy Server ID**
3. Format: `1234567890123456789` (18-19 digit number)

### Channel IDs
For each channel, right-click channel name → **Copy Channel ID**

Store these in your `.env` file or n8n credentials:
- `#equipment-analysis`: `DISCORD_CHANNEL_EQUIPMENT_ANALYSIS`
- `#troubleshooting`: `DISCORD_CHANNEL_TROUBLESHOOTING`
- `#maintenance-logs`: `DISCORD_CHANNEL_MAINTENANCE_LOGS`
- `#alerts`: `DISCORD_CHANNEL_ALERTS`
- `#search-results`: `DISCORD_CHANNEL_SEARCH_RESULTS`
- `#bot-commands`: `DISCORD_CHANNEL_BOT_COMMANDS`

### Bot User ID (Application ID)
1. Right-click bot in member list → **Copy User ID**
2. Or get from Developer Portal → OAuth2 → General → Application ID
3. Format: `1234567890123456789`
4. Store as `DISCORD_CLIENT_ID` in your environment variables 

---

## Part 5: Test Bot Connectivity (Optional)

You can test the bot token before setting up n8n:

### Option A: Using curl (Command Line)

```bash
curl -H "Authorization: Bot YOUR_BOT_TOKEN_HERE" https://discord.com/api/v10/users/@me
```

**Expected response:**
```json
{
  "id": "1234567890123456789",
  "username": "Chucky",
  "discriminator": "0",
  "bot": true
}
```

### Option B: Using Python

```python
import requests

BOT_TOKEN = "YOUR_BOT_TOKEN_HERE"
headers = {"Authorization": f"Bot {BOT_TOKEN}"}
response = requests.get("https://discord.com/api/v10/users/@me", headers=headers)
print(response.json())
```

**If you see an error:**
- `401 Unauthorized` → Token is invalid or regenerated
- `403 Forbidden` → Missing intents or permissions
- Connection error → Check your internet connection

---11.3.25 5.54pm

## Part 6: Configure n8n Credentials

### Step 1: Install Community Discord Node

1. In n8n, go to **Settings** (gear icon)
2. Click **Community Nodes**
3. Click **Install a community node**
4. Enter package name: `n8n-nodes-discord`
5. Click **Install**
6. Wait for installation to complete (may take 1-2 minutes)
7. Restart n8n if prompted

**Alternative package (if first doesn't work):**
- `@florianai/n8n-nodes-discord-trigger`

### Step 2: Add Discord Bot Token Credential

1. In n8n workflow, add a Discord node (from community nodes)
2. Click credential dropdown → **Create New Credential**
3. Or go to **Credentials** menu → **Add Credential** → Search "Discord"
4. Select **Discord Bot Token** credential type

**Fill in:**
- **Name:** `Chucky Discord Bot`
- **Bot Token:** Paste token from Developer Portal
- Click **Save**

### Step 3: Test Credential

1. Add Discord node to workflow
2. Select credential
3. Choose operation: **Message → Send**
4. **Channel ID:** Paste a channel ID from your server
5. **Message:** `Hello from Chucky! Bot is connected.`
6. Click **Execute Node**

**If successful:** Message appears in Discord channel
**If error:** Check token, channel ID, and bot permissions

---

## Part 7: Set Up Slash Commands (Advanced)

Slash commands require registration with Discord API. The community node handles this automatically, but here's manual setup if needed:

### Automatic Registration (Recommended)

The `n8n-nodes-discord` community node registers slash commands automatically when you:
1. Add Discord Trigger node
2. Select event type: **Command**
3. Configure command name, description, and options
4. Activate workflow

Discord API registers the command within 1-5 minutes.

### Manual Registration (If Needed)

Use Discord Developer Portal:
1. Go to your application
2. Click **General Information**
3. Copy **Application ID**
4. Use this curl command:

```bash
curl -X POST \
  -H "Authorization: Bot YOUR_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "troubleshoot",
    "description": "Start equipment troubleshooting workflow",
    "options": [
      {
        "name": "equipment",
        "description": "Equipment ID or type",
        "type": 3,
        "required": true
      },
      {
        "name": "issue",
        "description": "Brief description of the issue",
        "type": 3,
        "required": true
      }
    ]
  }' \
  https://discord.com/api/v10/applications/YOUR_APPLICATION_ID/commands
```

**Option types:**
- `3` = String
- `4` = Integer
- `5` = Boolean
- `6` = User
- `7` = Channel

---

## Troubleshooting

### Bot Not Responding

1. **Check bot is online:**
   - In Discord, bot should show green status when workflow is active
   - If offline, workflow trigger is not running

2. **Verify Message Content Intent:**
   - Developer Portal → Bot → Privileged Gateway Intents
   - Ensure **Message Content Intent** is enabled

3. **Check channel permissions:**
   - Right-click channel → Edit Channel → Permissions
   - Ensure bot role has **View Channel** and **Send Messages**

### Slash Commands Not Appearing

1. **Wait 5 minutes** after registering commands (Discord API delay)
2. **Kick and re-invite bot** to refresh permissions
3. **Check applications.commands scope** in OAuth2 URL
4. **Re-activate workflow** to re-register commands

### Bot Can't Send Embeds

1. Verify **Embed Links** permission in channel settings
2. Check embed JSON syntax (use validator: https://autocode.com/tools/discord/embed-builder/)
3. Ensure embed description is under 4,096 characters

### 401 Unauthorized Error

- Token is invalid or expired
- Regenerate token in Developer Portal
- Update credential in n8n

### 403 Forbidden Error

- Missing permissions in channel
- Bot not in server
- Message Content Intent not enabled

---

## Next Steps

Once Discord infrastructure is set up:

1. ✅ Discord server created with channels
2. ✅ Bot created and configured
3. ✅ Bot invited to server
4. ✅ Community node installed in n8n
5. ✅ Credentials configured and tested

**Continue to:** `DISCORD_WORKFLOW_IMPLEMENTATION.md` for building the n8n workflow nodes.

---

## Quick Reference

### Channel IDs
Fill these in after creating channels:

```
#equipment-analysis: ________________
#troubleshooting: ________________
#maintenance-logs: ________________
#alerts: ________________
#search-results: ________________
#bot-commands: ________________
```

### Color Codes for Embeds

```javascript
const embedColors = {
  critical: 15158332,   // Red
  warning: 16776960,    // Yellow
  info: 3447003,        // Blue
  success: 3066993,     // Green
  maintenance: 10181046 // Purple
};
```

### Common Bot Permissions Value

If manually setting permissions integer: `274878024768`

This includes: Send Messages, Embed Links, Attach Files, Read Message History, Use Slash Commands, Manage Messages, Create Threads

---

## Resources

- **Discord Developer Portal:** https://discord.com/developers/applications
- **Discord API Documentation:** https://discord.com/developers/docs
- **Community Node (Primary):** https://github.com/edbrdi/n8n-nodes-discord
- **Community Node (Alternative):** https://github.com/smallcloudai/n8n-nodes-discord-forum
- **Embed Builder Tool:** https://autocode.com/tools/discord/embed-builder/
- **Permission Calculator:** https://discordapi.com/permissions.html
