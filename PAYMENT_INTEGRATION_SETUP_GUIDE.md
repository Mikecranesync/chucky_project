# Payment & Billing Integration Setup Guide

**Based on:** Grok PDF Recommendation #2
**Created:** 2025-11-03
**Workflows:** `Payment_Management_Workflow.json` + `Stripe_Webhook_Handler.json`

---

## Overview

This implements **Recommendation #2** from the Grok monetization report: **Payment and Billing Integration**. It enables direct revenue through subscriptions and pay-per-use models using Stripe.

### What These Workflows Do

**Workflow 1: Payment Management** (11 nodes)
1. ✅ Handles `/upgrade` and `/pricing` commands
2. ✅ Shows pricing plans with inline buttons
3. ✅ Creates Stripe checkout sessions
4. ✅ Sends payment links to users
5. ✅ Logs payment sessions in database

**Workflow 2: Stripe Webhook Handler** (14 nodes)
1. ✅ Receives Stripe payment events
2. ✅ Updates user subscription status
3. ✅ Creates invoice records
4. ✅ Notifies users of payment status
5. ✅ Handles cancellations and expirations
6. ✅ Logs all webhook events

### Pricing Tiers Implemented

| Tier | Price | Mode | Features |
|------|-------|------|----------|
| **Free** | $0 | N/A | Image categorization only |
| **Basic** | $4.99/month | Subscription | Unlimited analyses, PDF delivery, 50 queries/month |
| **Pro** | $19.99/month | Subscription | Everything + unlimited queries, custom reports, priority support |
| **Pay-Per-Use** | $0.10/PDF | One-time | Perfect for occasional use, no subscription |

---

## Prerequisites

### 1. Completed Workflow #1
- User Authentication workflow must be deployed and working
- `users` table must exist in Supabase
- Telegram bot must be configured

### 2. Stripe Account
- Sign up at https://stripe.com
- Complete account verification
- Get API keys (test mode for development)

### 3. Public n8n Instance
- Webhooks require publicly accessible URL
- Use ngrok for local testing or deploy to cloud

---

## Step-by-Step Setup

### PART 1: Stripe Setup

#### Step 1: Create Stripe Products & Prices

1. Log into Stripe Dashboard → **Products**
2. Click **+ Add Product**

**Create 3 Products:**

**Product 1: Chucky Basic Plan**
- Name: `Chucky Basic`
- Description: `Unlimited image analyses, PDF delivery, 50 queries/month`
- Pricing:
  - Price: `$4.99`
  - Billing period: `Monthly`
  - Recurring
- Click **Save Product**
- **Copy the Price ID** (format: `price_xxxxx`) → You'll need this!

**Product 2: Chucky Pro Plan**
- Name: `Chucky Pro`
- Description: `Unlimited queries, custom reports, priority support, advanced analytics`
- Pricing:
  - Price: `$19.99`
  - Billing period: `Monthly`
  - Recurring
- Click **Save Product**
- **Copy the Price ID** → You'll need this!

**Product 3: Pay-Per-Use PDF Analysis**
- Name: `Single PDF Analysis`
- Description: `One-time PDF analysis and delivery`
- Pricing:
  - Price: `$0.10`
  - One-time payment
- Click **Save Product**
- **Copy the Price ID** → You'll need this!

#### Step 2: Get Stripe API Keys

1. Stripe Dashboard → **Developers** → **API Keys**
2. Copy your keys:
   - **Publishable key**: `pk_test_xxxxx` (not needed for n8n)
   - **Secret key**: `sk_test_xxxxx` ⚠️ **COPY THIS** - you'll need it!

#### Step 3: Set Up Webhook Endpoint

1. Stripe Dashboard → **Developers** → **Webhooks**
2. Click **+ Add endpoint**
3. Endpoint URL: `https://your-n8n-domain.com/webhook/stripe-webhook`
   - Replace with your actual n8n webhook URL
   - For local testing with ngrok: `https://xxxxx.ngrok.io/webhook/stripe-webhook`
4. Select events to listen to:
   - ✅ `checkout.session.completed`
   - ✅ `checkout.session.expired`
   - ✅ `customer.subscription.created`
   - ✅ `customer.subscription.updated`
   - ✅ `customer.subscription.deleted`
   - ✅ `payment_intent.succeeded`
   - ✅ `payment_intent.payment_failed`
5. Click **Add endpoint**
6. **Copy the Signing Secret** (`whsec_xxxxx`) → You'll need this for webhook verification!

---

### PART 2: Database Setup

#### Step 4: Create Payment Tables in Supabase

1. Open Supabase SQL Editor
2. Copy entire contents of `supabase_payment_schema.sql`
3. Paste and execute
4. Verify tables created:

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('payment_sessions', 'invoices', 'webhook_logs', 'usage_tracking')
ORDER BY table_name;
```

Should return 4 tables.

5. Check users table updated:

```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'users'
  AND column_name IN ('stripe_customer_id', 'stripe_subscription_id');
```

Should return 2 columns.

---

### PART 3: n8n Workflow Setup

#### Step 5: Import Payment Management Workflow

1. Open n8n workflow editor
2. Click **Add Workflow** → **Import from File**
3. Select `Payment_Management_Workflow.json`
4. Workflow loads with 11 nodes

#### Step 6: Configure Stripe API Credentials

1. n8n → **Settings** → **Credentials**
2. Click **Add Credential** → Search "HTTP Header Auth"
3. Create new credential:
   - **Name**: `Stripe API Key`
   - **Name** (header): `Authorization`
   - **Value**: `Bearer sk_test_YOUR_SECRET_KEY`
     - Replace `sk_test_YOUR_SECRET_KEY` with your actual Stripe secret key
4. Click **Save**

#### Step 7: Update Stripe Price IDs in Workflow

1. In the workflow, find node: **"Prepare Stripe Session"** (Code node)
2. Click to edit
3. Update the Price IDs in the code:

```javascript
// Find these lines and replace with YOUR Price IDs:
let priceId = 'price_basic_monthly'; // Replace with actual Basic Price ID
// ...
if (command.includes('pro')) {
  priceId = 'price_pro_monthly'; // Replace with actual Pro Price ID
}
// ...
priceId = 'price_pay_per_use'; // Replace with actual Pay-per-use Price ID
```

Replace:
- `price_basic_monthly` → Your Basic plan Price ID from Step 1
- `price_pro_monthly` → Your Pro plan Price ID from Step 1
- `price_pay_per_use` → Your Pay-per-use Price ID from Step 1

4. Click **Save**

#### Step 8: Update Success/Cancel URLs

In the same **"Prepare Stripe Session"** node, update the URLs:

```javascript
success_url: `https://your-domain.com/payment-success?session_id={CHECKOUT_SESSION_ID}`,
cancel_url: `https://your-domain.com/payment-cancelled`,
```

Replace with your actual URLs or use placeholder pages.

#### Step 9: Assign Credentials to Nodes

Assign credentials to these nodes in Payment Management workflow:
- **Telegram Trigger** → Telegram credential
- **Get User Subscription** (Supabase) → Supabase credential
- **Show Pricing Plans** (Telegram) → Telegram credential
- **Create Stripe Checkout** (HTTP Request) → Stripe API Key (HTTP Header Auth)
- **Send Payment Link** (Telegram) → Telegram credential
- **Log Payment Session** (Supabase) → Supabase credential
- **Unknown Command** (Telegram) → Telegram credential

#### Step 10: Import Stripe Webhook Handler

1. Click **Add Workflow** → **Import from File**
2. Select `Stripe_Webhook_Handler.json`
3. Workflow loads with 14 nodes

#### Step 11: Configure Webhook URL

1. Find node: **"Stripe Webhook"** (Webhook Trigger)
2. Note the webhook path: `/stripe-webhook`
3. Your full webhook URL will be: `https://your-n8n-domain.com/webhook/stripe-webhook`
4. This should match what you entered in Stripe Dashboard (Step 3)

#### Step 12: Assign Credentials to Webhook Handler Nodes

Assign credentials to all Supabase and Telegram nodes:
- All **Supabase nodes** (7 total) → Supabase credential
- All **Telegram nodes** (3 total) → Telegram credential

#### Step 13: Activate Both Workflows

1. **Payment Management** workflow → Toggle **Active** (top right)
2. **Stripe Webhook Handler** workflow → Toggle **Active**
3. Check n8n logs for successful activation

---

### PART 4: Testing

#### Test 1: View Pricing Plans

1. Send to Telegram bot: `/upgrade`
2. **Expected**: Receive pricing message with 3 inline buttons
3. **Verify**: Message shows Free, Basic, and Pro plans

#### Test 2: Create Payment Session

1. Click **"⭐ Basic $4.99/mo"** button (or send `/upgrade_basic`)
2. **Expected**: Receive message with Stripe payment link
3. **Verify in Supabase**:

```sql
SELECT * FROM payment_sessions ORDER BY created_at DESC LIMIT 1;
```

Should show new session with `status = 'pending'`.

#### Test 3: Complete Test Payment

**Option A: Use Stripe Test Cards**

1. Click the payment link from Test 2
2. On Stripe checkout page, use test card:
   - Card number: `4242 4242 4242 4242`
   - Expiry: Any future date (e.g., `12/34`)
   - CVC: Any 3 digits (e.g., `123`)
   - ZIP: Any ZIP code
3. Complete payment

**Option B: Use Stripe CLI for Testing**

```bash
stripe listen --forward-to https://your-n8n-domain.com/webhook/stripe-webhook
stripe trigger checkout.session.completed
```

#### Test 4: Verify Subscription Updated

1. After completing payment (Test 3), check Telegram
2. **Expected**: Receive "🎉 Payment Successful!" message
3. **Verify in Supabase**:

```sql
SELECT telegram_id, subscription_status, stripe_customer_id
FROM users
WHERE telegram_id = 'YOUR_TELEGRAM_ID';
```

Should show:
- `subscription_status` = `basic` or `pro`
- `stripe_customer_id` populated
- `stripe_subscription_id` populated

4. Check payment_sessions table:

```sql
SELECT * FROM payment_sessions WHERE status = 'completed' ORDER BY created_at DESC LIMIT 1;
```

5. Check invoices table:

```sql
SELECT * FROM invoices ORDER BY invoice_date DESC LIMIT 1;
```

Should have new invoice with generated invoice number (format: `INV-20251103-000001`).

#### Test 5: Expired Payment Link

1. In Supabase, manually expire a session:

```sql
UPDATE payment_sessions
SET expires_at = NOW() - INTERVAL '1 hour'
WHERE session_id = 'YOUR_SESSION_ID';
```

2. Wait a minute, or use Stripe CLI:

```bash
stripe trigger checkout.session.expired
```

3. **Expected**: User receives "⏱️ Payment Link Expired" message
4. **Verify**: Session status updated to `expired`

#### Test 6: Subscription Cancellation

1. In Stripe Dashboard, go to **Customers**
2. Find test customer and click their subscription
3. Click **Actions** → **Cancel subscription**
4. **Expected**: User receives "📢 Subscription Cancelled" message
5. **Verify in Supabase**:

```sql
SELECT subscription_status FROM users WHERE telegram_id = 'YOUR_TELEGRAM_ID';
```

Should be reverted to `free`.

---

## Workflow Logic Explained

### Payment Management Workflow

```
[User sends /upgrade]
    ↓
[Parse Command] (extract user info)
    ↓
[Is Payment Command?] (check if upgrade/pricing)
    ├─ YES → [Get User Subscription]
    └─ NO → [Unknown Command]
    ↓
[Show Pricing Plans] + [Prepare Stripe Session]
    ↓
[Create Stripe Checkout] (API call to Stripe)
    ↓
[Send Payment Link] + [Log Payment Session]
```

### Stripe Webhook Handler Workflow

```
[Stripe sends webhook event]
    ↓
[Parse Webhook Event] (extract event data)
    ↓
[Route Event Type] (Switch node)
    ├─ checkout.session.completed
    │   ↓
    │   [Update User Subscription]
    │   [Update Payment Session]
    │   [Create Invoice]
    │   [Notify Payment Success]
    │
    ├─ checkout.session.expired
    │   ↓
    │   [Mark Session Expired]
    │   [Notify Payment Expired]
    │
    └─ customer.subscription.deleted
        ↓
        [Downgrade User to Free]
        [Notify Cancellation]
    ↓
[Respond to Stripe] (200 OK)
[Log Webhook Event]
```

---

## Security Best Practices

### 1. Webhook Signature Verification

⚠️ **IMPORTANT**: The current workflow does NOT verify Stripe webhook signatures. For production, add signature verification:

1. Add Code node after Webhook Trigger:

```javascript
const crypto = require('crypto');

const signature = $input.first().headers['stripe-signature'];
const payload = $input.first().body;
const webhookSecret = 'whsec_YOUR_SIGNING_SECRET'; // From Stripe Dashboard

// Verify signature
const expectedSignature = crypto
  .createHmac('sha256', webhookSecret)
  .update(payload)
  .digest('hex');

if (signature !== expectedSignature) {
  throw new Error('Invalid webhook signature!');
}

return { json: JSON.parse(payload) };
```

### 2. Use Environment Variables

Don't hardcode secrets! Use n8n environment variables:
- Set in n8n: Settings → Environment → Variables
- Access in workflows: `{{ $env.STRIPE_SECRET_KEY }}`

### 3. Enable HTTPS

- Always use HTTPS for webhooks
- Stripe requires TLS 1.2+
- Use valid SSL certificate (not self-signed)

### 4. Limit Webhook IP Access

- Whitelist Stripe webhook IPs in firewall
- Stripe IPs: https://stripe.com/docs/ips

### 5. Log Everything

The workflow logs all webhook events to `webhook_logs` table for audit trail and debugging.

---

## Troubleshooting

### Problem: Stripe checkout fails with "Invalid Price ID"

**Solution:**
- Verify Price IDs in "Prepare Stripe Session" node
- Ensure you copied full Price ID from Stripe (format: `price_xxxxxxxxxxxxx`)
- Check Price IDs are from the correct Stripe account (test vs live)

### Problem: Webhook not firing

**Solution:**
- Check n8n workflow is **Active**
- Verify webhook URL is publicly accessible (test with `curl`)
- Check Stripe Dashboard → Webhooks → Recent Events for errors
- Ensure n8n webhook path matches Stripe endpoint URL
- Check n8n logs for incoming requests

### Problem: User subscription not updating

**Solution:**
- Check `webhook_logs` table for received events
- Verify telegram_id is passed in checkout metadata
- Check Switch node routing in webhook handler
- Look for errors in n8n execution history

### Problem: "Table payment_sessions does not exist"

**Solution:**
- Run `supabase_payment_schema.sql` in Supabase SQL Editor
- Verify execution completed without errors
- Check table created: `\dt payment_sessions`

### Problem: Payment links expire too quickly

**Solution:**
- Update expiration time in payment_sessions table:

```sql
ALTER TABLE payment_sessions
ALTER COLUMN expires_at SET DEFAULT NOW() + INTERVAL '48 hours';
```

### Problem: Invoice numbers not generating

**Solution:**
- Check sequence exists:

```sql
SELECT * FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'invoice_number_seq';
```

- Reset if needed:

```sql
ALTER SEQUENCE invoice_number_seq RESTART WITH 1;
```

---

## Revenue Tracking & Analytics

### Key Metrics to Monitor

1. **Monthly Recurring Revenue (MRR)**

```sql
SELECT
    SUM(CASE WHEN subscription_status = 'basic' THEN 4.99 ELSE 0 END) +
    SUM(CASE WHEN subscription_status = 'pro' THEN 19.99 ELSE 0 END) as mrr
FROM users
WHERE subscription_status IN ('basic', 'pro');
```

2. **Conversion Rate**

```sql
SELECT
    COUNT(CASE WHEN subscription_status = 'free' THEN 1 END) as free_users,
    COUNT(CASE WHEN subscription_status IN ('basic', 'pro') THEN 1 END) as paid_users,
    ROUND(
        100.0 * COUNT(CASE WHEN subscription_status IN ('basic', 'pro') THEN 1 END) /
        NULLIF(COUNT(*), 0),
        2
    ) as conversion_rate_percent
FROM users;
```

3. **Revenue by Plan**

```sql
SELECT * FROM revenue_by_month
ORDER BY month DESC
LIMIT 12;
```

4. **Customer Lifetime Value (LTV)**

```sql
SELECT
    telegram_id,
    username,
    calculate_user_ltv(telegram_id) as lifetime_value
FROM users
WHERE subscription_status != 'free'
ORDER BY lifetime_value DESC
LIMIT 50;
```

5. **Churn Rate**

```sql
SELECT
    DATE_TRUNC('month', subscription_end_date) as month,
    COUNT(*) as churned_users
FROM users
WHERE subscription_end_date IS NOT NULL
GROUP BY month
ORDER BY month DESC;
```

---

## Next Steps

### Phase 1: Testing (This Week)
- [ ] Test all payment flows with test cards
- [ ] Verify webhook events are processed correctly
- [ ] Test subscription upgrades and cancellations
- [ ] Ensure invoice generation works

### Phase 2: Connect to Main Workflow
- [ ] Add payment check before PDF delivery
- [ ] Route free users to limited features only
- [ ] Track usage for pay-per-use billing
- [ ] Implement quota enforcement (Recommendation #3)

### Phase 3: Invoice Delivery (Optional)
- [ ] Generate PDF invoices using n8n
- [ ] Email invoices to users via Gmail
- [ ] Store PDF URLs in invoices table

### Phase 4: Production Deployment
- [ ] Switch from Stripe test mode to live mode
- [ ] Update all Price IDs to live versions
- [ ] Enable webhook signature verification
- [ ] Set up monitoring and alerts
- [ ] Implement PCI DSS compliance measures

---

## Integration with Chucky Main Workflow

To connect payment gating to your main Chucky workflow:

1. **Add Authentication Check at Start**

```
[Telegram Trigger]
    ↓
[Authenticate User] (call User Auth workflow)
    ↓
[Check Subscription] (query users table)
    ↓
[Route by Tier]
    ├─ Free → [Basic Image Categorization Only]
    ├─ Basic → [Image + PDF Delivery]
    └─ Pro → [All Features + Priority]
```

2. **Track Usage for Billing**

After each image analysis or PDF generation:

```javascript
// Code node to log usage
const user = $json.telegram_id;
const cost = 0.10; // Cost per operation

return {
  json: {
    telegram_id: user,
    action_type: 'pdf_generation',
    cost: cost,
    timestamp: new Date().toISOString()
  }
};
```

Then insert into `usage_tracking` table.

3. **Enforce Quotas**

Before processing, check usage limits:

```javascript
// Get user and usage count
const user = $('Get User').item.json[0];
const limits = {
  free: 5,
  basic: 50,
  pro: 999999
};

const limit = limits[user.subscription_status] || 5;

if (user.usage_count >= limit) {
  // Send upgrade prompt
  return { json: { blocked: true, reason: 'quota_exceeded' } };
}

// Allow processing
return { json: { blocked: false } };
```

---

## File Reference

- **Payment Management Workflow**: `Payment_Management_Workflow.json`
- **Stripe Webhook Handler**: `Stripe_Webhook_Handler.json`
- **Database Schema**: `supabase_payment_schema.sql`
- **Setup Guide**: `PAYMENT_INTEGRATION_SETUP_GUIDE.md` (this file)

---

## Support Resources

- **Stripe Documentation**: https://stripe.com/docs/api
- **Stripe Webhooks Guide**: https://stripe.com/docs/webhooks
- **Stripe Test Cards**: https://stripe.com/docs/testing
- **n8n HTTP Request Node**: https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest/
- **Stripe Node (community)**: https://www.npmjs.com/package/n8n-nodes-stripe

---

**🎉 Payment integration complete! You can now accept payments and generate revenue from Chucky!**

**Estimated Implementation**: 2-3 hours (per Grok: 2-3 days)
**Estimated Revenue Impact**: $5-20/user/month with 10-20% conversion rate
