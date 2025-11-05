# Usage Quotas & Tiered Access Setup Guide

**Based on:** Grok PDF Recommendation #3
**Created:** 2025-11-03
**Workflows:** `Quota_Enforcement_Workflow.json` + `Monthly_Quota_Reset.json`

---

## Overview

This implements **Recommendation #3** from the Grok monetization report: **Usage Quotas and Tiered Access**. It prevents abuse, creates scalable pricing models, and drives upgrade conversions by enforcing tier-based usage limits.

### What These Workflows Do

**Workflow 1: Quota Enforcement (12 nodes)**
1. ✅ Checks user quota before processing requests
2. ✅ Enforces tier-based limits (Free: 5, Basic: 50, Pro: Unlimited)
3. ✅ Increments usage count automatically
4. ✅ Blocks requests when quota exceeded
5. ✅ Sends upsell messages to blocked users
6. ✅ Warns users approaching their limit (>80%)
7. ✅ Logs all usage events for analytics

**Workflow 2: Monthly Quota Reset (13 nodes)**
1. ✅ Runs automatically on 1st of each month
2. ✅ Generates monthly usage reports
3. ✅ Resets all user quotas to 0
4. ✅ Archives old usage data
5. ✅ Notifies admin of reset completion
6. ✅ Sends upsell messages to heavy free users

### Quota Limits by Tier

| Tier | Monthly Limit | Enforcement | Upgrade Prompt |
|------|---------------|-------------|----------------|
| **Free** | 5 requests | ✅ Hard Block | At 4 requests (80%) + when exceeded |
| **Basic** | 50 requests | ✅ Hard Block | At 40 requests (80%) + when exceeded |
| **Pro** | Unlimited | ❌ No Limit | N/A |
| **Pay-Per-Use** | Unlimited | ❌ No Limit | Charged per request |

---

## Prerequisites

### 1. Completed Previous Workflows
- ✅ **Workflow #1**: User Authentication (must exist)
- ✅ **Workflow #2**: Payment Integration (recommended)
- ✅ `users` table with `usage_count` column
- ✅ `usage_tracking` table from payment schema

### 2. Main Chucky Workflow
- This quota system integrates with your existing Chucky workflow
- You'll call the Quota Enforcement workflow BEFORE processing images/PDFs

---

## Step-by-Step Setup

### PART 1: Database Setup

#### Step 1: Run Quota Schema Script

1. Open Supabase SQL Editor
2. Copy entire contents of `supabase_quota_schema.sql`
3. Paste and execute
4. Verify completion:

```sql
-- Check new tables created
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('monthly_reports', 'quota_tiers', 'quota_events', 'usage_tracking_archive')
ORDER BY table_name;
```

Should return 4 tables.

5. Check new functions:

```sql
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('get_quota_status', 'increment_usage_with_check', 'reset_all_quotas')
ORDER BY routine_name;
```

Should return 3+ functions.

6. Verify views created:

```sql
SELECT table_name FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE '%quota%' OR table_name LIKE '%usage%'
ORDER BY table_name;
```

Should return views like `user_quota_status`, `users_at_risk`, etc.

---

### PART 2: Import Workflows

#### Step 2: Import Quota Enforcement Workflow

1. n8n → **Add Workflow** → **Import from File**
2. Select `Quota_Enforcement_Workflow.json`
3. Workflow loads with 12 nodes

#### Step 3: Import Monthly Reset Scheduler

1. n8n → **Add Workflow** → **Import from File**
2. Select `Monthly_Quota_Reset.json`
3. Workflow loads with 13 nodes

---

### PART 3: Configure Workflows

#### Step 4: Configure Quota Enforcement Workflow

**Assign Credentials:**

1. **Get User & Quota** (Supabase) → Supabase credential
2. **Increment Usage Count** (Supabase) → Supabase credential
3. **Log Usage Event** (Supabase) → Supabase credential
4. **Send Quota Warning** (Telegram) → Telegram credential
5. **Send Quota Exceeded** (Telegram) → Telegram credential

**No other configuration needed!** The workflow is ready to use.

#### Step 5: Configure Monthly Reset Scheduler

**Assign Credentials:**

All Supabase nodes (7 total) → Supabase credential
All Telegram nodes (2 total) → Telegram credential

**Update Admin Telegram ID:**

1. Find node: **"Notify Admin (Telegram)"**
2. Click to edit
3. Replace `YOUR_ADMIN_TELEGRAM_ID` with your actual Telegram ID
   - To find your ID: Send message to @userinfobot on Telegram

**Schedule Configuration:**

The workflow is pre-configured to run at **midnight on the 1st of every month**.

Cron expression: `0 0 1 * *`

To change the schedule:
1. Click **"Monthly Reset (1st of month)"** node
2. Modify the cron expression:
   - `0 0 1 * *` = Midnight, 1st of month
   - `0 2 1 * *` = 2 AM, 1st of month
   - `0 0 * * *` = Daily at midnight (for testing)

---

### PART 4: Integrate with Main Workflow

#### Step 6: Add Quota Check to Chucky Workflow

Your main Chucky workflow needs to call the Quota Enforcement workflow BEFORE processing requests.

**Integration Pattern:**

```
[Telegram Trigger]
    ↓
[Extract User Info]
    ↓
[Execute Workflow: Quota Enforcement] ← ADD THIS
    ↓
[IF] quota_response.allowed = true?
    ├─ YES → [Process Image/PDF] (your existing logic)
    └─ NO → [Stop] (user already notified by quota workflow)
```

**How to Add "Execute Workflow" Node:**

1. Open your main Chucky workflow
2. Add node → **Core Nodes** → **Execute Workflow**
3. Configure:
   - **Source**: Select "Database"
   - **Workflow**: Select "Quota Enforcement & Usage Tracking"
4. Pass data to quota workflow:

```javascript
// In a Code node before Execute Workflow
return {
  json: {
    telegram_id: $json.telegram_id,
    chat_id: $json.chat_id,
    action_type: 'image_analysis' // or 'pdf_generation', 'api_query'
  }
};
```

5. After Execute Workflow node, add IF node:

```javascript
// Condition
$json.allowed === true
```

- **True** → Continue to your image processing
- **False** → Stop workflow (user was already notified)

---

### PART 5: Activate & Test

#### Step 7: Activate Both Workflows

1. **Quota Enforcement** → Toggle **Active**
2. **Monthly Reset Scheduler** → Toggle **Active**
3. Check n8n logs for successful activation

#### Step 8: Test Quota Enforcement

**Test 1: Free User Within Quota**

1. Ensure test user has `usage_count` < 5
2. Trigger your main workflow
3. **Expected**:
   - Quota check passes
   - Usage incremented
   - Image/PDF processed
   - User receives response

**Test 2: Free User Approaching Limit (Warning)**

1. Set test user `usage_count` = 4 (80%)
2. Trigger workflow
3. **Expected**:
   - Quota check passes
   - Usage incremented to 5
   - User receives **quota warning** message
   - Processing continues

**Test 3: Free User Exceeds Quota**

1. Set test user `usage_count` = 5
2. Trigger workflow
3. **Expected**:
   - Quota check FAILS
   - Usage NOT incremented
   - User receives **quota exceeded** message with upgrade buttons
   - Processing STOPS

**Test 4: Pro User (Unlimited)**

1. Set test user `subscription_status` = 'pro'
2. Set `usage_count` = 9999
3. Trigger workflow
4. **Expected**:
   - Quota check passes (no limit for pro)
   - Usage incremented
   - Processing continues

#### Step 9: Test Monthly Reset (Manual Trigger)

**Option A: Change Schedule to Test Immediately**

1. Edit **"Monthly Reset (1st of month)"** node
2. Change cron to run in 2 minutes: `*/2 * * * *` (every 2 minutes)
3. Save and activate
4. Wait 2 minutes
5. **Expected**:
   - All users' `usage_count` reset to 0
   - Monthly report created
   - Admin receives Telegram notification
   - Heavy free users receive upsell messages

**Option B: Manually Execute**

1. Open **Monthly Quota Reset Scheduler** workflow
2. Click **Test Workflow** button
3. All nodes execute once
4. Check results

**Verify Reset:**

```sql
SELECT telegram_id, usage_count, last_reset_at FROM users;
```

All `usage_count` should be 0, `last_reset_at` should be recent.

---

## Workflow Logic Explained

### Quota Enforcement Workflow

```
[Execute Workflow Trigger] ← Called from main workflow
    ↓
[Get User & Quota] ← Query Supabase for user data
    ↓
[Calculate Quota Status] ← Code node:
    │  • Get tier (free/basic/pro)
    │  • Get current usage
    │  • Calculate limit (5/50/unlimited)
    │  • Check if exceeded
    ↓
[Quota Available?] ← IF node
    │
    ├─ YES (Under Limit)
    │   ↓
    │   [Increment Usage Count] ← usage_count + 1
    │   ↓
    │   [Log Usage Event] ← Insert into usage_tracking
    │   ↓
    │   [Return Success Response] ← allowed: true
    │   ↓
    │   [Check Warning (>80%)?] ← IF node
    │       ├─ YES → [Send Quota Warning] ← "4/5 used"
    │       └─ NO → (silent success)
    │
    └─ NO (Exceeded)
        ↓
        [Send Quota Exceeded] ← Telegram with upgrade buttons
        ↓
        [Return Blocked Response] ← allowed: false
```

**Return Values:**

Success:
```json
{
  "allowed": true,
  "quota_status": {
    "tier": "free",
    "used": 3,
    "limit": 5,
    "remaining": 2,
    "usage_percentage": 60
  },
  "message": "✅ Request allowed. 2 requests remaining this month."
}
```

Blocked:
```json
{
  "allowed": false,
  "status": "quota_exceeded",
  "quota_status": {
    "tier": "free",
    "used": 5,
    "limit": 5,
    "remaining": 0
  },
  "message": "🚫 Monthly quota exceeded (5/5). Upgrade to continue.",
  "days_until_reset": 12
}
```

### Monthly Reset Scheduler

```
[Schedule Trigger: 1st of month, midnight]
    ↓
[Get Pre-Reset Stats] ← Count users, sum usage
    ↓
[Create Usage Report] ← Generate monthly summary
    ↓
[Save Monthly Report] ← Insert into monthly_reports table
    ↓
[Reset All Usage Counts] ← UPDATE users SET usage_count = 0
    ↓
[Archive Old Usage Data] ← Move data >90 days to archive
    ↓
[Prepare Reset Notification] ← Format admin message
    ↓
[Notify Admin] + [Get Heavy Free Users]
    │               ↓
    │          [Split In Batches] ← Process 10 at a time
    │               ↓
    │          [Send Reset + Upsell] ← "Quota reset! Upgrade?"
    │               ↓
    │          [Wait (Rate Limit)] ← 2 sec delay
    │               ↓
    │          (Loop back to Split In Batches)
    ↓
(Complete)
```

**Heavy Free Users:**
Users with `subscription_status = 'free'` AND `usage_count >= 4` (80%+ of quota) receive personalized upgrade messages after reset.

---

## Database Schema Overview

### New Tables (4 total)

#### 1. `monthly_reports`
Monthly usage statistics

```
- id (UUID, PK)
- report_month (TEXT, unique) ← "January 2025"
- report_date (TIMESTAMP)
- total_users, free_users, basic_users, pro_users (INTEGER)
- total_requests, avg_requests_per_user (DECIMAL)
- users_at_limit (INTEGER)
- mrr, conversion_rate (DECIMAL)
- new_users, churned_users (INTEGER)
```

#### 2. `quota_tiers`
Centralized tier configuration

```
- tier_name (TEXT, PK) ← 'free', 'basic', 'pro', 'pay_per_use'
- monthly_limit (INTEGER) ← 5, 50, 999999, 999999
- price (DECIMAL) ← 0.00, 4.99, 19.99, 0.10
- features (JSONB) ← Feature flags
- description (TEXT)
- is_active (BOOLEAN)
```

#### 3. `quota_events`
Audit log of quota enforcement events

```
- id (UUID, PK)
- telegram_id (TEXT)
- event_type (TEXT) ← 'quota_exceeded', 'quota_warning', 'quota_reset', etc.
- tier (TEXT)
- usage_at_event (INTEGER)
- limit_at_event (INTEGER)
- message_sent (BOOLEAN)
- timestamp (TIMESTAMP)
- metadata (JSONB)
```

#### 4. `usage_tracking_archive`
Long-term storage of usage data

```
- id (UUID)
- telegram_id, action_type, cost, timestamp (same as usage_tracking)
- metadata (JSONB)
- archived_at (TIMESTAMP)
```

### Updated Table

#### `users` (3 new columns)
```
+ last_request_at (TIMESTAMP) ← Most recent API call
+ last_reset_at (TIMESTAMP) ← Last quota reset date
+ quota_warnings_sent (INTEGER) ← Warning count this period
```

### Functions Created

1. **`get_quota_status(telegram_id)`** - Returns current quota status for user
2. **`increment_usage_with_check(telegram_id)`** - Atomic increment with quota validation
3. **`reset_all_quotas()`** - Reset all users' quotas (monthly)
4. **`get_users_approaching_limit(threshold)`** - Find users near their limit

### Views Created

1. **`user_quota_status`** - Real-time quota status for all users
2. **`users_at_risk`** - Users using >80% of quota
3. **`users_exceeded_quota`** - Users currently blocked
4. **`daily_usage_trends`** - Daily request statistics

---

## Analytics & Reporting

### Key Metrics to Track

#### 1. Quota Usage Analysis

```sql
-- Overall quota utilization
SELECT
    tier,
    COUNT(*) as user_count,
    AVG(usage_count) as avg_usage,
    AVG(usage_percentage) as avg_percent_used
FROM user_quota_status
GROUP BY tier
ORDER BY tier;
```

#### 2. Conversion Opportunities

```sql
-- Free users hitting limits (high conversion potential)
SELECT * FROM users_at_risk
WHERE tier = 'free'
ORDER BY usage_percentage DESC;
```

#### 3. Quota Exceeded Events

```sql
-- Users blocked in last 7 days
SELECT
    COUNT(DISTINCT telegram_id) as blocked_users,
    COUNT(*) as block_events,
    AVG(usage_at_event) as avg_usage_at_block
FROM quota_events
WHERE event_type = 'quota_exceeded'
  AND timestamp >= NOW() - INTERVAL '7 days';
```

#### 4. Upgrade Urgency

```sql
-- Free users who hit limit multiple times (HOT leads!)
SELECT
    u.telegram_id,
    u.username,
    u.usage_count,
    COUNT(qe.id) as times_blocked
FROM users u
JOIN quota_events qe ON u.telegram_id = qe.telegram_id
WHERE u.subscription_status = 'free'
  AND qe.event_type = 'quota_exceeded'
  AND qe.timestamp >= u.last_reset_at
GROUP BY u.telegram_id, u.username, u.usage_count
HAVING COUNT(qe.id) >= 2
ORDER BY times_blocked DESC;
```

#### 5. Monthly Trends

```sql
-- Compare monthly reports
SELECT
    report_month,
    total_users,
    total_requests,
    conversion_rate,
    mrr
FROM monthly_reports
ORDER BY report_date DESC
LIMIT 12;
```

### Dashboards

Create these views in your analytics tool (Metabase, Tableau, etc.):

1. **Quota Health Dashboard**
   - Current quota utilization by tier
   - Users at risk (>80%)
   - Users exceeded (blocked)
   - Daily request volume

2. **Conversion Funnel**
   - Free users by usage level
   - Warning messages sent
   - Quota exceeded events
   - Upgrade conversion rate

3. **Revenue Impact**
   - MRR from paid users
   - Estimated lost revenue (blocked free users × upgrade price)
   - Conversion rate trend

---

## Optimization Strategies

### 1. Dynamic Upselling

**Trigger upgrade prompts based on behavior:**

```sql
-- Users who hit 80% twice in one period (eager users!)
SELECT DISTINCT u.telegram_id, u.username
FROM users u
JOIN quota_events qe ON u.telegram_id = qe.telegram_id
WHERE qe.event_type = 'quota_warning'
  AND qe.timestamp >= u.last_reset_at
GROUP BY u.telegram_id, u.username
HAVING COUNT(*) >= 2;
```

Send these users a special offer: "You're a power user! Get 50% off Basic plan."

### 2. Grace Periods

Allow 1-2 extra requests after limit for good UX:

```javascript
// In Calculate Quota Status node
const gracePeriod = tier === 'free' ? 1 : 2;
const effectiveLimit = limit + gracePeriod;
const quotaExceeded = currentUsage >= effectiveLimit;
```

### 3. Soft vs Hard Limits

**Soft Limit (80%)**: Warning + continue
**Hard Limit (100%)**: Block + upsell

This creates urgency while maintaining good experience.

### 4. Seasonal Adjustments

Temporarily increase limits during promotions:

```sql
UPDATE quota_tiers
SET monthly_limit = monthly_limit * 2
WHERE tier_name = 'free';
```

Reset after promotion ends.

---

## Troubleshooting

### Problem: Quota not enforcing (users can exceed limit)

**Solution:**
- Check IF node condition in Quota Enforcement workflow
- Verify `usage_count` is incrementing: `SELECT usage_count FROM users WHERE telegram_id = 'XXX';`
- Ensure main workflow is calling Execute Workflow node correctly
- Check IF node after Execute Workflow is checking `$json.allowed`

### Problem: Users not receiving warning messages

**Solution:**
- Check usage percentage calculation in "Calculate Quota Status" node
- Verify Telegram credentials assigned to warning node
- Check IF node condition: `usage_percentage >= 80`
- Ensure `chat_id` is passed correctly from main workflow

### Problem: Monthly reset not running

**Solution:**
- Check workflow is **Active**
- Verify cron expression: `0 0 1 * *` (midnight, 1st of month)
- Check n8n logs for schedule trigger execution
- Test manually by clicking "Test Workflow"

### Problem: Usage count not resetting

**Solution:**
- Check `reset_all_quotas()` function exists:
  ```sql
  SELECT * FROM reset_all_quotas();
  ```
- Verify query execution in "Reset All Usage Counts" node
- Check `last_reset_at` column updated:
  ```sql
  SELECT last_reset_at FROM users LIMIT 5;
  ```

### Problem: Database functions not working

**Solution:**
- Re-run `supabase_quota_schema.sql` completely
- Check function exists:
  ```sql
  \df get_quota_status
  ```
- Test function manually:
  ```sql
  SELECT * FROM get_quota_status('123456789');
  ```

---

## Benefits for Monetization

### 1. Creates Urgency for Upgrades

❌ **Without Quotas:**
"You can upgrade anytime."
→ Low conversion, users procrastinate

✅ **With Quotas:**
"You've used 4/5 requests. Upgrade now or wait 12 days."
→ High urgency, conversion boost

### 2. Freemium Model Attracts Users

- **Free tier** = Easy signup, low barrier
- **Usage limits** = Value demonstration
- **Upgrade prompts** = Natural conversion path

**Industry Average**: 10-20% conversion (Grok PDF)

### 3. Prevents Abuse

- **Cost Control**: Limits AI API costs from free users
- **Fair Usage**: Pro users get premium experience
- **Sustainability**: Free tier is sustainable

### 4. Data-Driven Pricing

Track which users hit limits → Optimize tier sizes:
- If 90% of free users stay under 3 requests → Lower to 3
- If 80% of basic users hit 50 → Raise to 75

---

## Next Steps

### Phase 1: Deploy & Monitor (Week 1)
- [ ] Import and configure both workflows
- [ ] Integrate quota check into main Chucky workflow
- [ ] Test with multiple user tiers
- [ ] Monitor quota_events table for patterns

### Phase 2: Optimize Conversion (Week 2)
- [ ] Analyze which users hit limits most
- [ ] Test different warning thresholds (70% vs 80%)
- [ ] A/B test upsell message copy
- [ ] Add urgency indicators ("12 days until reset")

### Phase 3: Advanced Features (Week 3+)
- [ ] Add pay-per-use billing integration
- [ ] Implement grace period (1 extra request)
- [ ] Create conversion dashboard
- [ ] Set up automated upsell campaigns

### Phase 4: Connect All Workflows
- [ ] User Auth (✅ Done) → Quota Enforcement → Payment → Main Chucky
- [ ] Full end-to-end flow working
- [ ] All tiers properly enforced
- [ ] Revenue tracking automated

---

## File Reference

- **Quota Enforcement Workflow**: `Quota_Enforcement_Workflow.json`
- **Monthly Reset Scheduler**: `Monthly_Quota_Reset.json`
- **Database Schema**: `supabase_quota_schema.sql`
- **Setup Guide**: `QUOTA_MANAGEMENT_SETUP_GUIDE.md` (this file)

---

## Support Resources

- **n8n Execute Workflow**: https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.executeworkflow/
- **n8n Schedule Trigger**: https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/
- **Supabase Functions**: https://supabase.com/docs/guides/database/functions
- **PostgreSQL Triggers**: https://www.postgresql.org/docs/current/triggers.html

---

**🎯 Quota management complete! You can now enforce usage limits and drive upgrade conversions!**

**Estimated Implementation**: 1-2 hours (per Grok: 1 day, 2-4 nodes)
**Conversion Impact**: 10-20% free → paid conversion with urgency-based prompts
**Cost Savings**: Prevents abuse, limits free tier API costs
