# Discord Configuration Reference

## Bot Details

**Bot Name**: Chucky (Industrial Maintenance Assistant)
**Application ID**: 1435031220009304084
**Bot User ID**: 1435031220009304084

**Bot Token**: `YOUR_DISCORD_BOT_TOKEN_HERE`
**Client Secret**: `YOUR_CLIENT_SECRET_HERE`

> **Security Note**: These credentials are for development/testing. In production, store securely in environment variables or n8n's credential manager.

## Server Configuration

**Server ID**: 1435030211442770002
**Server Name**: Chucky Industrial Maintenance

## Channel IDs

| Channel Name | ID | Purpose |
|--------------|-----|---------|
| #equipment-analysis | 1435030487637819602 | Image uploads for AI vision analysis |
| #troubleshooting | 1435030564255170640 | Main Q&A interaction channel |
| #maintenance-logs | 1435030623977869452 | Completed work logging |
| #alerts | 1435030771042746542 | System alerts and warnings |
| #search-results | 1435030856698953790 | RAG search result displays |
| #bot-commands | 1435030900957118605 | Bot testing and admin commands |

## Bot Intents (Required)

Enable these intents in Discord Developer Portal:

- ✅ **Message Content Intent** (CRITICAL - required for reading messages)
- ✅ **Server Members Intent** (for @mentions and user data)
- ✅ **Presence Intent** (optional - for online status)

## Bot Permissions

Required OAuth2 scopes and permissions:

**Scopes**:
- `bot`
- `applications.commands`

**Bot Permissions** (Integer: 412317248640):
- Send Messages
- Send Messages in Threads
- Embed Links
- Attach Files
- Read Message History
- Mention Everyone (for alerts)
- Use Slash Commands
- Manage Messages (for cleanup)
- Create Public Threads
- Create Private Threads

## Command Prefix

All bot commands use the `!` prefix:
- `!troubleshoot <description>`
- `!analyze <with image attachment>`
- `!search <keywords>`
- `!help`

## Webhook Configuration

**Webhook URL Pattern**: `https://your-n8n-instance.com/webhook/discord-chucky`

The n8n Discord Trigger node automatically handles:
- Signature verification
- Event parsing
- Message extraction

## Message Format Examples

### Basic Text Command
```
User: !troubleshoot Motor is making grinding noise
Bot: [Sends structured response with troubleshooting steps]
```

### Image Analysis Command
```
User: !analyze [uploads motor.jpg]
Bot: **Equipment Analysis:**
     Category: 3-Phase AC Motor
     Confidence: 92%
     [Detailed analysis...]
```

### Embed Response Structure
```javascript
{
  title: "Troubleshooting: Motor Grinding Noise",
  color: 0xFF0000, // Red for critical issues
  fields: [
    { name: "Symptom", value: "Grinding noise during operation" },
    { name: "Likely Cause", value: "Bearing failure" },
    { name: "Safety", value: "⚠️ Lockout/Tagout required" }
  ],
  footer: { text: "Chucky AI | Confidence: 88%" }
}
```

## Error Responses

When errors occur, Chucky sends user-friendly messages:
- API failures: "I'm having trouble connecting to my knowledge base..."
- Low confidence: "I need more information to help accurately..."
- Invalid commands: "I didn't understand that command. Try `!help`"

## Rate Limits

Discord API rate limits:
- 50 messages per second per channel
- 5 slash commands per second
- Webhooks: 30 requests per 60 seconds

n8n workflow includes built-in retry logic and backoff for rate limit handling.

## Testing Channels

Use #bot-commands for testing to avoid disrupting production channels.

## Admin Commands (Future)

Planned admin-only commands:
- `!stats` - Bot usage statistics
- `!reindex` - Rebuild vector database
- `!config` - View current configuration
