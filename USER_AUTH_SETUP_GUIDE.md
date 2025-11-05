# User Management & Authentication Workflow Setup Guide

**Based on:** Grok PDF Recommendation #1
**Created:** 2025-11-03
**Workflow File:** `User_Auth_Workflow.json`

---

## Overview

This workflow implements the **first recommendation** from the Grok monetization report: **User Management and Authentication**. It enables subscription-based access control by tracking users, managing authentication, and routing based on subscription status.

### What This Workflow Does

1. ✅ **User Registration** - Automatically creates user accounts when first interacting via Telegram
2. ✅ **Login Tracking** - Updates last login timestamp for returning users
3. ✅ **Subscription Gating** - Routes users to different paths based on subscription tier (free/basic/pro)
4. ✅ **Usage Tracking** - Prepares foundation for usage quotas and billing
5. ✅ **Profile Management** - Stores user preferences and metadata

### Benefits for Monetization

- Enables subscription tiers (Free, Basic $4.99/month, Pro $19.99/month)
- Tracks paid users separately from free users
- Foundation for usage limits and billing
- Personalization increases retention
- Supports future payment integration

---

## Workflow Structure

### Node Breakdown (12 Nodes Total)

```
[Telegram Trigger]
    ↓
[Extract User Info] (Code)
    ↓
[Check User Exists] (Supabase Query)
    ↓
[User Exists?] (If Node)
    ├─ YES → [Update Last Login] (Supabase Update)
    └─ NO → [Create New User] (Supabase Insert) → [Welcome New User] (Telegram)
    ↓
[Get User Details] (Supabase Query)
    ↓
[Check Subscription Status] (If Node)
    ├─ PAID (basic/pro) → [Paid User Response] (Telegram)
    └─ FREE → [Free User Response] (Telegram)
```

### Subscription Tiers

| Tier | Price | Features | Target Users |
|------|-------|----------|--------------|
| **Free** | $0 | Image categorization only | Casual testers |
| **Basic** | $4.99/month | Full PDF delivery, 50 queries/month | Individual technicians |
| **Pro** | $19.99/month | Unlimited queries, custom integrations, advanced analytics | Enterprises |

---

## Prerequisites

### 1. Supabase Account & Project
- Sign up at https://supabase.com
- Create a new project
- Note your **API URL** and **API Key** (anon/public key)

### 2. Telegram Bot
- Create bot via [@BotFather](https://t.me/BotFather) on Telegram
- Get your **Bot Token**
- Enable webhook mode in n8n

### 3. n8n Instance
- Running n8n (local or cloud)
- Public URL for Telegram webhooks (use ngrok for local testing)

---

## Step-by-Step Setup

### Step 1: Create Supabase Database Table

Run this SQL in your Supabase SQL Editor (Database → SQL Editor → New Query):

```sql
-- Create users table
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    telegram_id TEXT UNIQUE NOT NULL,
    username TEXT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    subscription_status TEXT DEFAULT 'free' CHECK (subscription_status IN ('free', 'basic', 'pro')),
    usage_count INTEGER DEFAULT 0,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for fast telegram_id lookups
CREATE INDEX idx_users_telegram_id ON users(telegram_id);

-- Create index for subscription queries
CREATE INDEX idx_users_subscription ON users(subscription_status);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Optional: Create sample data
INSERT INTO users (telegram_id, username, first_name, subscription_status, usage_count)
VALUES
    ('123456789', 'test_user_free', 'Test', 'free', 5),
    ('987654321', 'test_user_pro', 'Premium', 'pro', 150);

-- Verify table created
SELECT * FROM users;
```

### Step 2: Configure n8n Credentials

#### A. Add Supabase Credentials

1. In n8n, go to **Settings → Credentials**
2. Click **Add Credential** → Search "Supabase"
3. Enter:
   - **Host**: Your Supabase project URL (e.g., `https://xxxxx.supabase.co`)
   - **Service Role Secret**: Found in Supabase → Settings → API → `service_role` key (for admin access)
4. Click **Save**

#### B. Add Telegram Credentials

1. In n8n Credentials, click **Add Credential** → Search "Telegram"
2. Enter your **Bot Token** from BotFather
3. Click **Save**

### Step 3: Import Workflow into n8n

1. Open n8n workflow editor
2. Click **Add Workflow** → **Import from File**
3. Select `User_Auth_Workflow.json`
4. The workflow will load with all nodes pre-configured

### Step 4: Configure Node Credentials

Go through each node and assign credentials:

1. **Telegram Trigger** → Select your Telegram credential
2. **Check User Exists** (Supabase) → Select Supabase credential
3. **Create New User** (Supabase) → Select Supabase credential
4. **Update Last Login** (Supabase) → Select Supabase credential
5. **Get User Details** (Supabase) → Select Supabase credential
6. **Welcome New User** (Telegram) → Select Telegram credential
7. **Free User Response** (Telegram) → Select Telegram credential
8. **Paid User Response** (Telegram) → Select Telegram credential

### Step 5: Update Supabase Table Name

Make sure all Supabase nodes reference the correct table name `users`:
- Each Supabase node has a `tableId` parameter
- Verify it's set to: `users`

### Step 6: Activate Workflow

1. Click **Active** toggle (top right) to enable the workflow
2. n8n will register the Telegram webhook automatically
3. Check n8n logs for successful webhook registration

### Step 7: Test the Workflow

#### Test 1: New User Registration
1. Send any message to your Telegram bot
2. Expected: Welcome message with "Free Plan" status
3. Check Supabase: New user record should be created

#### Test 2: Returning User
1. Send another message
2. Expected: Authentication confirmation with usage count
3. Check Supabase: `last_login` should be updated

#### Test 3: Paid User
1. In Supabase, manually update a user's `subscription_status` to `pro`:
   ```sql
   UPDATE users
   SET subscription_status = 'pro'
   WHERE telegram_id = 'YOUR_TELEGRAM_ID';
   ```
2. Send message to bot
3. Expected: Premium welcome message

---

## Workflow Logic Details

### Node 1: Telegram Trigger
- **Type**: `telegramTrigger`
- **Purpose**: Receives messages from Telegram users
- **Config**: Listens for "message" updates
- **Output**: Full Telegram message object

### Node 2: Extract User Info (Code Node)
```javascript
// Extracts key user information from Telegram message
const message = $input.first().json.message;
const telegramUser = message.from;

return {
  json: {
    telegram_id: telegramUser.id.toString(),
    username: telegramUser.username || `user_${telegramUser.id}`,
    first_name: telegramUser.first_name || '',
    last_name: telegramUser.last_name || '',
    chat_id: message.chat.id,
    message_text: message.text || '',
    timestamp: new Date().toISOString()
  }
};
```

### Node 3: Check User Exists (Supabase Query)
- **Operation**: Get All (with filter)
- **Table**: `users`
- **Filter**: `telegram_id` equals extracted ID
- **Purpose**: Checks if user record already exists

### Node 4: User Exists? (If Node)
- **Condition**: Check if query returned results (`length > 0`)
- **True Path**: User exists → Update last login
- **False Path**: New user → Create user record

### Node 5: Create New User (Supabase Insert)
- **Operation**: Insert
- **Fields**:
  - `telegram_id` → From extracted data
  - `username` → From Telegram
  - `subscription_status` → Default: `"free"`
  - `usage_count` → Default: `0`
  - `last_login` → Current timestamp
  - `created_at` → Current timestamp

### Node 6: Update Last Login (Supabase Update)
- **Operation**: Update
- **Filter**: `telegram_id` matches
- **Fields Updated**:
  - `last_login` → Current timestamp
  - `username` → Refresh from Telegram (handles username changes)

### Node 7: Get User Details (Supabase Query)
- **Purpose**: Retrieve full user record with subscription status
- **Used By**: Both new and returning user paths converge here
- **Output**: Complete user object for routing decisions

### Node 8: Check Subscription Status (If Node)
- **Condition**: `subscription_status` equals `"basic"` OR `"pro"`
- **True Path**: Paid user → Premium response
- **False Path**: Free user → Free tier response

### Node 9-11: Response Nodes
- Send appropriate Telegram messages based on user tier
- Include usage stats and upgrade prompts

---

## Extending the Workflow

### Add Usage Counting

After authentication, increment `usage_count`:

```javascript
// Add this code node after "Get User Details"
const currentCount = $json[0].usage_count || 0;
const newCount = currentCount + 1;

// Then add Supabase Update node:
UPDATE users
SET usage_count = {{ $json.newCount }}
WHERE telegram_id = {{ $('Extract User Info').item.json.telegram_id }}
```

### Add Usage Limits (Quota Enforcement)

After "Check Subscription Status", add:

```javascript
// Code node: Check Quota
const user = $json[0];
const limits = {
  free: 5,
  basic: 50,
  pro: 999999
};

const limit = limits[user.subscription_status] || 5;
const exceeded = user.usage_count >= limit;

return {
  json: {
    ...user,
    limit: limit,
    remaining: limit - user.usage_count,
    exceeded: exceeded
  }
};
```

Then add an If node to block or upsell if exceeded.

### Connect to Main Chucky Workflow

1. After successful authentication, pass user data to main workflow
2. Use Switch node or multiple If nodes to route:
   - Free users → Basic image categorization only
   - Basic users → Full PDF delivery
   - Pro users → All features + priority processing

3. Example connection:
   ```
   [Check Subscription Status]
       ├─ PAID → [Call Main Chucky Workflow] (Execute Workflow Trigger)
       └─ FREE → [Limited Features Branch]
   ```

---

## Troubleshooting

### Issue: "Table 'users' not found"
**Solution**:
1. Check Supabase SQL editor
2. Run the CREATE TABLE SQL again
3. Verify table name is exactly `users` (lowercase)

### Issue: Telegram webhook not firing
**Solution**:
1. Ensure n8n has a public URL (not localhost)
2. Check webhook registration in n8n logs
3. Deactivate and reactivate workflow
4. Verify bot token is correct

### Issue: Supabase connection fails
**Solution**:
1. Check API URL format: `https://xxxxx.supabase.co`
2. Use `service_role` key, not `anon` key for admin operations
3. Verify Supabase project is not paused

### Issue: User created but subscription check fails
**Solution**:
1. Check `subscription_status` field contains valid value: 'free', 'basic', or 'pro'
2. Verify If node condition syntax in "Check Subscription Status" node
3. Test with manual Supabase query:
   ```sql
   SELECT * FROM users WHERE subscription_status IN ('basic', 'pro');
   ```

---

## Next Steps

After implementing this workflow:

1. ✅ **Test thoroughly** with different user types
2. 🔄 **Implement Recommendation #2**: Payment Integration (Stripe/PayPal nodes)
3. 📊 **Add Usage Quotas** (Recommendation #3): Enforce limits per tier
4. 🔐 **Enhance Security** (Recommendation #5): Add encryption and compliance
5. 🎯 **Connect to Chucky**: Integrate with main photo analysis workflow

---

## Estimated Implementation Time

- **Database Setup**: 15 minutes
- **n8n Import & Configuration**: 30 minutes
- **Testing**: 15 minutes
- **Total**: ~1 hour

**As per Grok Report**: 2-3 nodes, 1-2 days (conservative estimate)

---

## Database Schema Reference

### Users Table Structure

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Auto-generated unique identifier |
| `telegram_id` | TEXT | UNIQUE, NOT NULL | Telegram user ID (indexed) |
| `username` | TEXT | | Telegram username |
| `first_name` | TEXT | | User's first name |
| `last_name` | TEXT | | User's last name |
| `email` | TEXT | | Email address (optional, for future OAuth) |
| `subscription_status` | TEXT | CHECK constraint | 'free', 'basic', or 'pro' |
| `usage_count` | INTEGER | DEFAULT 0 | Number of requests made |
| `last_login` | TIMESTAMP | | Last interaction timestamp |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Account creation time |
| `updated_at` | TIMESTAMP | AUTO-UPDATE | Last record update time |

### Indexes

- `idx_users_telegram_id` - Fast user lookup by Telegram ID
- `idx_users_subscription` - Fast filtering by subscription tier

---

## File Locations

- **Workflow JSON**: `User_Auth_Workflow.json`
- **Setup Guide**: `USER_AUTH_SETUP_GUIDE.md` (this file)
- **Source Reference**: `grok_report (1).pdf` - Pages 1-2

---

## Support & Resources

- **n8n Documentation**: https://docs.n8n.io
- **Supabase Docs**: https://supabase.com/docs
- **Telegram Bot API**: https://core.telegram.org/bots/api

---

**Ready to monetize Chucky! 💰**

This workflow forms the foundation for subscription-based access control. Once tested, proceed to add payment integration (Stripe) and usage quotas to complete the monetization stack.
