# Email Setup Walkthrough - Step by Step

**Time Required:** 5-10 minutes
**Difficulty:** Easy
**Result:** Working email notifications for Chucky photo analysis!

---

## Part 1: Get Gmail App Password (3 minutes)

### Step 1: Enable 2-Step Verification (if not already enabled)

1. **Go to:** https://myaccount.google.com/security
2. **Look for:** "2-Step Verification" section
3. **If it says "Off":** Click it and follow steps to enable
4. **If it says "On":** ✅ Great! Continue to next step

### Step 2: Generate App Password

1. **Go to:** https://myaccount.google.com/apppasswords

   (Or search "Google App Passwords" in Google)

2. **You'll see:** "App passwords" page

3. **Click:** "Select app" dropdown
   - Choose: **"Mail"**

4. **Click:** "Select device" dropdown
   - Choose: **"Other (Custom name)"**
   - Type: **"n8n Chucky"**

5. **Click:** "Generate"

6. **You'll see:** A 16-character password like: `abcd efgh ijkl mnop`

7. **IMPORTANT:** Copy this password and save it somewhere
   - You'll need it in a moment
   - You won't be able to see it again!

---

## Part 2: Add Email Node to n8n Workflow (7 minutes)

### Step 1: Open Your Workflow

1. **Go to:** http://localhost:5679
2. **Click:** "Workflows" in left sidebar
3. **Click:** "Chucky" workflow to open it

### Step 2: Find Where to Add Email Node

We want to send email AFTER the image is analyzed. Look for:

**The flow should be:**
```
Google Drive Trigger → Download → Analyze Image → Code (parser) → [ADD EMAIL HERE]
```

**Find the "Code" node** (the one that parses Gemini response into JSON)
- It should be around position 688,464 in the workflow
- It outputs the structured data with category, confidence, etc.

### Step 3: Add Send Email Node

1. **Click the "+" button** on the connection AFTER the "Code" node
   - Or click anywhere on canvas and click "+"

2. **Search for:** "Send Email"

3. **Select:** "Send Email" node (n8n-nodes-base.emailSend)

4. **The node will appear** on your canvas

### Step 4: Position It Correctly

**Connect it like this:**
```
Code node → Send Email → Supabase (or other existing nodes)
```

The email will send AFTER analysis but BEFORE storage (or after, your choice!)

### Step 5: Configure the Email Node

Click on the "Send Email" node to open its settings.

**Fill in these fields:**

#### Credential Section:
1. **Click:** "Credential to connect with" dropdown
2. **Click:** "+ Create New Credential"
3. **Select:** "SMTP"

#### SMTP Credential Settings:
```
User: your-email@gmail.com
Password: [paste the 16-char app password from Part 1]
Host: smtp.gmail.com
Port: 587
Secure: No (STARTTLS will be used)
```

4. **Click:** "Save" on credential

#### Email Message Settings:

**From Email:**
```
your-email@gmail.com
```

**To Email:**
```
your-email@gmail.com
```
(or any email you want to receive notifications)

**Subject:**
```
📸 Photo Analyzed: {{ $json.primaryCategory }}
```

**Message Type:** Choose "Text"

**Text:**
```
✅ New Photo Analyzed by Chucky!

📁 Category: {{ $json.primaryCategory }}
📊 Confidence: {{ $json.confidence }}%

📝 Description:
{{ $json.description }}

🏷️ Keywords:
{{ $json.keywords.join(', ') }}

📍 Folder: {{ $json.folderName }}

⏰ Processed: {{ $json.processedAt }}
🎯 Confidence Level: {{ $json.confidenceLevel }}

---
🤖 Chucky Photo Analyzer
```

### Step 6: Save the Workflow

1. **Click:** Save button (top right)
2. **Or press:** Ctrl+S / Cmd+S

---

## Part 3: Enable the Workflow (2 minutes)

### Step 1: Make Sure You Have an Active Trigger

**Check if you have ANY active trigger:**
- Google Drive trigger (enable it)
- OR add a Manual Trigger for testing

**To enable Google Drive trigger:**
1. Find "Google Drive IFTTT" node
2. Click on it
3. Uncheck "Disabled" if checked
4. Make sure Google Drive credential is selected
5. Click away to save

### Step 2: Activate the Workflow

1. **Look at top right** corner
2. **Find the toggle switch** that says "Inactive"
3. **Click it** to turn it on
4. **It should turn green** and say "Active" ✅

If it doesn't activate, tell me the error message!

---

## Part 4: Test It! (2 minutes)

### Method 1: Manual Test (Fastest)

1. **Find a node** in your workflow (like "Code" node)
2. **Click "Execute Node"** button
3. **Check your email!**

### Method 2: Full Workflow Test (More realistic)

1. **Upload a test image** to your Google Drive "Unprophoto" folder
2. **Wait 1 minute** (polling interval)
3. **Watch workflow execute** in n8n
4. **Check your email inbox!**

---

## Expected Result

**You should receive an email like this:**

```
From: your-email@gmail.com
To: your-email@gmail.com
Subject: 📸 Photo Analyzed: Personal & Lifestyle

✅ New Photo Analyzed by Chucky!

📁 Category: Personal & Lifestyle
📊 Confidence: 87%

📝 Description:
A photo showing a family gathering with people smiling outdoors during daytime

🏷️ Keywords:
family, people, outdoor, celebration, portrait

📍 Folder: personal-lifestyle

⏰ Processed: 2025-11-02T20:30:45.123Z
🎯 Confidence Level: high

---
🤖 Chucky Photo Analyzer
```

---

## Troubleshooting

### Issue: "Invalid login" error

**Cause:** Wrong password or not using app password

**Fix:**
1. Make sure you're using the 16-character app password
2. NOT your regular Gmail password
3. Copy-paste it carefully (no extra spaces)

### Issue: "Connection refused"

**Cause:** Firewall blocking SMTP

**Fix:**
1. Check Docker network settings
2. Try port 465 with SSL instead of 587

### Issue: Email not sending

**Cause:** Node not executed

**Fix:**
1. Check workflow execution logs
2. Make sure the workflow reached the email node
3. Check for errors in previous nodes

### Issue: "Recipient rejected"

**Cause:** Email address typo

**Fix:**
1. Double-check email addresses
2. Make sure they're valid

---

## Advanced: Add Photo Attachment (Optional)

If you want to include the photo in the email:

1. **In Send Email node settings**
2. **Enable "Attachments"**
3. **Add attachment:**
   ```
   Property Name: data
   Binary Property: data
   ```

This will attach the actual photo file to the email!

---

## Next Steps

Once email works:

### Option 1: Add More Recipients
- Send to multiple emails
- CC yourself and family
- BCC for privacy

### Option 2: Conditional Emails
- Only send for certain categories
- Only high-confidence results
- Error notifications only

### Option 3: Add Discord Too!
- Set up Discord webhooks
- Post to category-specific channels
- Beautiful rich formatting

---

## What We've Accomplished

✅ Gmail SMTP configured
✅ Email node added to workflow
✅ Notifications set up
✅ Workflow can activate (no HTTPS needed!)
✅ You get instant notifications on phone/computer

**No more Telegram HTTPS headaches!** 🎉

---

**Created:** 2025-11-02
**Status:** Ready to implement NOW
