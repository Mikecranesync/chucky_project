# Chucky Discord RAG Agent - Setup Guide

**Version:** 1.0
**Based on:** Grok Chucky Redo 1 PRD
**Platform:** Discord (using built-in n8n nodes)
**Type:** Advanced RAG Agent with Multi-Modal Input

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Installation Steps](#installation-steps)
5. [Configuration](#configuration)
6. [Usage Examples](#usage-examples)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)

---

## Overview

Chucky is an advanced Retrieval-Augmented Generation (RAG) agent implemented as an n8n workflow for industrial maintenance troubleshooting. It combines:

- **Multi-modal input processing** (text, images, PDFs)
- **Vision AI** (Google Gemini) for equipment fault detection
- **Vector database** (Supabase) for industrial documentation retrieval
- **Agentic reasoning** (xAI Grok or Claude) with ReAct pattern
- **Discord integration** for real-time team collaboration

### Key Capabilities

✅ Analyze equipment photos to detect faults
✅ Retrieve relevant manuals/procedures from knowledge base
✅ Generate step-by-step troubleshooting guidance
✅ Multi-step iterative problem-solving with user feedback
✅ Session memory for contextual conversations
✅ External search fallback for unknown issues

---

## Architecture

### Workflow Flow

```
Discord (!command)
  ↓
Extract Data (query, sessionID, attachments)
  ↓
Route by Type (Switch)
  ├─ Has Attachment → Download → Gemini Vision → Parse JSON → Confidence Check
  │                                                               ├─ <80% → Ask Clarification
  │                                                               └─ ≥80% → RAG Retrieval
  └─ Text Only → RAG Retrieval
       ↓
Merge (Analysis + Documents)
  ↓
AI Agent (with Tools: Vector Store, Code, HTTP)
  ├─ Memory: Postgres Chat
  ├─ LLM: xAI Grok
  └─ Agent Type: ReAct (10 iterations max)
  ↓
Iteration Loop (SplitInBatches)
  ↓
Format Response (Markdown)
  ↓
Discord Send (Troubleshooting Steps)

[Error Trigger] → Send Error + Log
```

### Node Count: 25 Core Nodes

| Category | Nodes | Purpose |
|----------|-------|---------|
| **Trigger** | 2 | Discord Trigger, Error Trigger |
| **Data Processing** | 4 | Extract Data, Switch, Set Text Query, Code Parse |
| **Vision Analysis** | 2 | Download Attachment, Gemini Vision |
| **RAG Pipeline** | 2 | Vector Store Retrieval, Gemini Embeddings |
| **AI Agent** | 5 | Agent, Memory, LLM, 3 Tools |
| **Logic** | 3 | If Confidence, Merge, Iteration Loop |
| **Output** | 4 | Format Response, Send Response, Send Clarification, Send Error |
| **Error Handling** | 1 | Log Error to External Service |
| **Connections** | 2 | Tool Connections (Vector, Code, HTTP to Agent) |

---

## Prerequisites

### Required Services & Credentials

1. **Discord**
   - Discord server (or channel access)
   - Discord bot with OAuth2 credentials
   - Bot token with permissions: `Send Messages`, `Read Message History`, `Embed Links`, `Attach Files`

2. **Google Cloud**
   - Google Cloud project with APIs enabled:
     - Google Drive API (for file downloads)
     - Google PaLM API (for Gemini models)
   - OAuth2 credentials or API key

3. **Supabase**
   - Supabase project with Vector extension enabled
   - Table: `learnable_content` with vector embeddings
   - Supabase API key and URL

4. **xAI** (or Anthropic)
   - xAI account with API access (for Grok)
   - OR Anthropic account (for Claude 3.5 Sonnet)
   - API key

5. **PostgreSQL**
   - Postgres database for chat memory
   - Connection details (host, database, username, password)
   - Auto-creates `n8n_chat_histories` table

6. **Optional: External Search**
   - Brave Search API key (for fallback searches)
   - OR SerpAPI key

### n8n Requirements

- n8n version: **1.17.0+** (for latest AI nodes)
- Installed packages:
  - `@n8n/n8n-nodes-langchain` (AI nodes)
  - Core Discord nodes (built-in)

### Knowledge Base Preparation

**IMPORTANT:** Before using Chucky, you must populate the Supabase vector store with industrial documentation.

**Recommended approach:**
1. Create a separate n8n workflow for PDF ingestion
2. Use Google Drive polling to detect new PDFs
3. Parse PDFs with Unstructured or LlamaIndex nodes
4. Chunk documents (500-1000 tokens per chunk)
5. Generate embeddings with Gemini Embeddings
6. Insert into Supabase table `learnable_content`

**Sample ingestion workflow structure:**
```
Google Drive Trigger (poll for PDFs)
  ↓
Download PDF
  ↓
Parse with Unstructured
  ↓
Code (chunk into sections)
  ↓
Loop through chunks
  ↓
Gemini Embeddings
  ↓
Supabase Insert (mode: insert)
```

---

## Installation Steps

### Step 1: Import Workflow

1. Open your n8n instance
2. Click **Workflows** → **Import from File**
3. Select `ChuckyDiscordRAG.json`
4. Click **Import**

The workflow will appear with placeholder credential IDs marked in red (unconfigured).

### Step 2: Configure Discord Bot

**A) Create Discord Bot:**

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Click **New Application** → Name it "Chucky"
3. Go to **Bot** tab → **Add Bot**
4. Enable **Message Content Intent** (CRITICAL)
5. Copy **Bot Token** (save securely)

**B) Invite Bot to Server:**

1. Go to **OAuth2** → **URL Generator**
2. Select scopes:
   - `bot`
3. Select bot permissions:
   - Send Messages
   - Read Message History
   - Embed Links
   - Attach Files
4. Copy generated URL and open in browser
5. Select your Discord server
6. **Authorize**

**C) Get Channel ID:**

1. In Discord, enable Developer Mode (Settings → Advanced → Developer Mode)
2. Right-click the channel where Chucky should operate
3. **Copy Channel ID**
4. Save this ID for workflow configuration

### Step 3: Configure n8n Credentials

Open the workflow and configure each credential:

#### 3.1 Discord OAuth2

- **Credential Type:** Discord OAuth2 API
- **Name:** Discord OAuth2
- **OAuth Callback URL:** (Copy from n8n)
- **Client ID:** Your Discord Application ID
- **Client Secret:** Your Discord Application Secret
- **Bot Token:** Your Discord Bot Token

**How to get:**
- Client ID & Secret: Discord Developer Portal → OAuth2
- Bot Token: Discord Developer Portal → Bot

#### 3.2 Google OAuth2 / PaLM API

- **Credential Type:** Google PaLM API
- **Name:** Google PaLM API
- **API Key:** Your Google AI Studio API key

**How to get:**
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create API key
3. Enable Gemini API for your project

**Alternative: Google OAuth2**
- If using Google Drive integration, also configure Google OAuth2 credential
- Enable Google Drive API in Google Cloud Console

#### 3.3 Supabase API

- **Credential Type:** Supabase API
- **Name:** Supabase API
- **Host:** `https://YOUR_PROJECT.supabase.co`
- **Service Role Secret:** Your Supabase service role key

**How to get:**
1. Go to your Supabase project
2. Settings → API
3. Copy **Project URL** (Host)
4. Copy **service_role** key (NOT anon key - service role has full access)

**Vector Store Setup:**

In Supabase SQL Editor, run:

```sql
-- Enable vector extension
create extension if not exists vector;

-- Create learnable_content table
create table learnable_content (
  id uuid primary key default gen_random_uuid(),
  content text,
  metadata jsonb,
  embedding vector(768),  -- Gemini embedding dimension
  created_at timestamp with time zone default now()
);

-- Create index for vector similarity search
create index on learnable_content
using ivfflat (embedding vector_cosine_ops)
with (lists = 100);

-- Create function for similarity search
create or replace function match_documents (
  query_embedding vector(768),
  match_threshold float,
  match_count int
)
returns table (
  id uuid,
  content text,
  metadata jsonb,
  similarity float
)
language sql stable
as $$
  select
    learnable_content.id,
    learnable_content.content,
    learnable_content.metadata,
    1 - (learnable_content.embedding <=> query_embedding) as similarity
  from learnable_content
  where 1 - (learnable_content.embedding <=> query_embedding) > match_threshold
  order by learnable_content.embedding <=> query_embedding
  limit match_count;
$$;
```

#### 3.4 xAI API (or Anthropic)

- **Credential Type:** xAI API
- **Name:** xAI account
- **API Key:** Your xAI API key

**How to get:**
1. Go to [xAI Console](https://console.x.ai/)
2. Create account / login
3. Generate API key

**Alternative: Use Claude instead of Grok:**

If you prefer Anthropic Claude:
1. Replace "xAI Grok Model" node with "Anthropic Chat Model" node
2. Configure credential:
   - **Credential Type:** Anthropic API
   - **API Key:** Your Anthropic API key
3. Model: `claude-3-5-sonnet-20241022`

#### 3.5 Postgres (for Chat Memory)

- **Credential Type:** Postgres
- **Name:** Postgres account
- **Host:** Your Postgres host
- **Database:** Your database name
- **User:** Your Postgres username
- **Password:** Your Postgres password
- **Port:** 5432 (default)
- **SSL:** Enable if required

**How to get:**
- Use your existing Postgres instance
- OR create free Postgres on Supabase (same project):
  - Supabase provides Postgres by default
  - Connection string in Settings → Database → Connection String

**Automatic table creation:**
The Postgres Chat Memory node will auto-create the `n8n_chat_histories` table on first use.

#### 3.6 Optional: Brave Search API

- **Credential Type:** Header Auth
- **Name:** Brave Search API
- **Header Name:** `X-Subscription-Token`
- **Header Value:** Your Brave API key

**How to get:**
1. Go to [Brave Search API](https://api.search.brave.com/)
2. Sign up for free tier (2,000 queries/month)
3. Get API key from dashboard

**Alternative: SerpAPI**

Replace HTTP node configuration:
- URL: `https://serpapi.com/search?api_key=YOUR_KEY&q={{ encodeURIComponent($json.query) }}&num=5`

### Step 4: Update Workflow Configuration

After adding credentials, update these placeholders in the workflow:

#### 4.1 Discord Trigger Node

- **Channel:** Enter your Discord channel ID (from Step 2C)
- **Filter:** Leave as `!` (triggers on commands starting with `!`)
- **Match Starts With:** `true`

#### 4.2 Vector Store Nodes (2 locations)

**RAG Retrieval node:**
- **Table Name:** `learnable_content` (or your table name)
- **Top K:** `5` (number of results)
- **Similarity Threshold:** `0.7` (minimum relevance)

**Vector Store Tool node:** (Same settings)

#### 4.3 Postgres Chat Memory Node

- **Session Key:** `={{ $json.sessionId }}` (already configured)
- **Context Window Length:** `10` (number of messages to remember)

#### 4.4 Error Logging (Optional)

**HTTP Log Error node:**
- **URL:** Replace `https://your-logging-service.com/errors` with your error logging endpoint
- OR remove this node if you don't use external error logging

**Alternative:** Use Sentry, Logtail, or your preferred logging service.

### Step 5: Activate Workflow

1. Click **Save** in workflow editor
2. Toggle **Active** switch (top right)
3. Workflow status should show "Active" with green indicator

**Webhook registration:**
- n8n will automatically register the Discord webhook
- Check execution log for "Webhook registered" message

---

## Configuration

### Workflow Settings

**Settings Tab:**
- **Execution Order:** v1 (sequential)
- **Save Manual Executions:** ✅ Enabled (for debugging)
- **Error Workflow:** (Optional) Link to error handling workflow

### Advanced Tuning

#### AI Agent Parameters

**Chucky AI Agent node → Settings:**

- **Max Iterations:** `10` (how many reasoning loops)
  - Increase for complex problems (up to 20)
  - Decrease for faster responses (minimum 3)

- **System Message:** (Customize personality)
  ```
  You are Chucky, an expert industrial maintenance assistant.
  Provide clear, actionable troubleshooting steps based on
  equipment analysis, retrieved manuals, and industry best practices.
  Always prioritize safety. Format responses as numbered markdown
  lists with detailed explanations.
  ```

#### LLM Temperature

**xAI Grok Model node → Options:**

- **Temperature:** `0.5` (default - balanced creativity/accuracy)
  - Lower (0.1-0.3): More deterministic, factual
  - Higher (0.7-0.9): More creative, varied responses

- **Max Tokens:** `2000` (response length limit)

#### Vision Analysis Prompt

**Gemini Vision Analysis node → Prompt:**

Customize the system message for your industry:

```
You are an industrial equipment analysis expert specializing in
[YOUR_INDUSTRY: HVAC/Electrical/Mechanical/etc.].

Analyze images and PDFs to identify:
- Equipment type and model
- Potential faults and safety hazards
- Visible text, diagrams, and labels
- Initial troubleshooting steps based on [YOUR_STANDARDS: OSHA/NFPA/ASME]

Output structured JSON with:
{
  "category": "equipment_type",
  "description": "detailed_analysis",
  "keywords": ["tag1", "tag2"],
  "extractedText": "visible_text",
  "faults": ["issue1", "issue2"],
  "suggestedSteps": ["step1", "step2"],
  "confidence": 85
}
```

#### Confidence Threshold

**Check Confidence node → Conditions:**

- **Threshold:** `80` (default)
  - Increase (90+): Fewer clarification requests, but may miss ambiguous cases
  - Decrease (60-70): More clarification requests, higher accuracy

#### Vector Search Parameters

**RAG Retrieval node → Options:**

- **Top K:** `5` (number of documents retrieved)
  - Increase for broader context (7-10)
  - Decrease for focused results (3)

- **Similarity Threshold:** `0.7` (minimum relevance score)
  - Increase for stricter matching (0.8-0.9)
  - Decrease for more lenient matching (0.5-0.6)

---

## Usage Examples

### Example 1: Text Query

**User in Discord:**
```
!troubleshoot HVAC system not cooling, compressor won't start
```

**Chucky's Process:**
1. Detects `!troubleshoot` command
2. Extracts query: "HVAC system not cooling, compressor won't start"
3. Searches vector store for HVAC troubleshooting docs
4. Retrieves top 5 relevant manual sections
5. AI Agent reasons through the problem using RAG context
6. Generates numbered troubleshooting steps
7. Sends formatted response to Discord

**Expected Response:**
```
**Chucky's Analysis** for @username

Based on your HVAC troubleshooting query, here are the diagnostic steps:

1. **Check Power Supply**
   - Verify main breaker is ON (not tripped)
   - Check disconnect switch near unit is closed
   - Measure voltage at unit: should read 230V ±10%
   - ⚠️ **Safety:** Lockout/tagout before accessing electrical

2. **Inspect Thermostat**
   - Verify thermostat set to COOL mode
   - Set temperature 5°F below current room temp
   - Check thermostat wiring connections
   - Replace batteries if applicable

3. **Check Compressor Capacitor**
   - De-energize unit completely
   - Discharge capacitor with insulated screwdriver
   - Inspect for bulging, leaking, or burn marks
   - Test capacitance: should match label (±6%)
   - Replace if failed

4. **Test Contactor**
   - Verify 24V signal to contactor coil
   - Check for worn/pitted contacts
   - Listen for "click" when thermostat calls for cooling
   - Replace if contacts are welded or burnt

5. **Compressor Assessment**
   - If all above OK but compressor silent, check:
     - Compressor windings for open circuit
     - Starting relay/overload functionality
   - ⚠️ **If compressor hums but won't start:** STOP - May be seized

**Retrieved Documentation:**
- HVAC Troubleshooting Manual Section 4.2 (Compressor Faults)
- OSHA Safety Guidelines for HVAC Service

**Next Steps:**
If these steps don't resolve the issue, please provide:
- Equipment model number
- Age of system
- Any error codes displayed

---
*Troubleshooting powered by Chucky AI | Industrial Maintenance Assistant*
```

### Example 2: Image Upload + Query

**User in Discord:**
```
!troubleshoot electrical panel issue
[Uploads photo of electrical panel with visible damage]
```

**Chucky's Process:**
1. Detects attachment + query
2. Downloads image from Discord CDN
3. Sends to Gemini Vision for analysis
4. Gemini detects: "Burnt bus bar, arc flash damage, missing panel cover"
5. Parses JSON response, confidence: 92%
6. Confidence ≥80% → Proceeds to RAG
7. Retrieves electrical safety docs
8. AI Agent generates safety-first response

**Expected Response:**
```
**Chucky's Analysis** for @username

⚠️ **CRITICAL SAFETY ALERT** ⚠️

**Image Analysis:**
- Equipment: 480V 3-Phase Electrical Panel
- Detected Issues:
  - Burnt bus bar (severe arcing damage)
  - Missing arc flash warning label
  - Panel cover not installed
- Confidence: 92%

**IMMEDIATE ACTIONS REQUIRED:**

1. **LOCKOUT/TAGOUT IMMEDIATELY**
   - De-energize panel at upstream source
   - Apply lockout devices to all disconnects
   - Verify zero energy with meter
   - Post danger tags

2. **Evacuate Area**
   - Clear 10-foot radius around panel
   - Notify all personnel of hazard
   - Do NOT attempt repair without proper PPE

3. **Contact Licensed Electrician**
   - This requires professional repair
   - Arc flash damage indicates fault current event
   - Panel integrity may be compromised

4. **Report to Facility Manager**
   - Document incident with photos
   - File near-miss report if applicable
   - Review arc flash study for this equipment

**Why This Is Critical:**
- Arc flash can cause severe burns, fire, explosion
- Damaged bus bar may cause catastrophic failure
- Missing labels violate NFPA 70E safety standards

**Retrieved Safety Docs:**
- NFPA 70E: Electrical Safety in the Workplace (Section 130.5)
- OSHA 1910.333: Selection and use of work practices

**DO NOT proceed with energizing this equipment until:**
✅ Professional electrician inspects and certifies repair
✅ Arc flash labels installed
✅ Panel cover replaced
✅ Safety clearances verified

Stay safe!

---
*Troubleshooting powered by Chucky AI | Industrial Maintenance Assistant*
```

### Example 3: Low Confidence → Clarification

**User in Discord:**
```
!troubleshoot motor problem
[Uploads blurry photo of motor]
```

**Chucky's Process:**
1. Image analysis returns confidence: 65%
2. Confidence <80% → Triggers clarification branch

**Expected Response:**
```
**Clarification Needed** (<@username>)

I analyzed the image but only have 65% confidence. Can you provide more details?

**What I detected:**
- Category: Electric Motor (possibly 3-phase)
- Description: Motor assembly with visible nameplate, but image quality limits detailed analysis

Please specify:
1. Exact equipment model/type (check nameplate)
2. What specific issue you're experiencing (won't start, overheating, noise, vibration, etc.)
3. Any error codes or symptoms

Also, if possible, upload a clearer photo focusing on:
- Motor nameplate with specifications
- Any visible damage or abnormalities
- Control panel or starter

This will help me provide accurate troubleshooting steps!
```

### Example 4: Multi-Step Iteration

**User in Discord:**
```
!troubleshoot bearing noise in pump motor
```

**Chucky (Initial Response):**
```
**Chucky's Analysis** for @username

Bearing noise in pump motors can indicate several issues. Let's diagnose step-by-step:

**Step 1: Identify Noise Type**

Please describe the sound:
A) High-pitched squeal or screech
B) Grinding or rumbling
C) Clicking or knocking
D) Intermittent chirping

Reply with your selection (A, B, C, or D).

---
*I'll provide specific troubleshooting based on your answer.*
```

**User replies:**
```
B - grinding noise
```

**Chucky (Follow-up):**
```
**Chucky's Analysis** for @username

Grinding/rumbling indicates **bearing wear or failure**. Here's the diagnostic procedure:

**Immediate Actions:**
1. **Stop pump if possible**
   - Continued operation may cause catastrophic failure
   - Risk of shaft seizure or coupling damage

2. **Vibration Analysis**
   - Use vibration meter on motor housing
   - Normal: <0.2 in/sec
   - Caution: 0.2-0.5 in/sec
   - Danger: >0.5 in/sec
   - Do you have access to a vibration meter? (Yes/No)

3. **Temperature Check**
   - Feel bearing housing (use infrared thermometer if available)
   - Normal: Ambient + 20-40°F
   - Hot: >180°F indicates imminent failure
   - What's the bearing temperature?

Please provide:
- Vibration level (if measured)
- Bearing temperature
- How long has noise been present?

I'll then provide bearing replacement or lubrication guidance.
```

**This demonstrates:**
- Iterative problem-solving
- Session memory (Chucky remembers previous context)
- User-guided troubleshooting path

---

## Troubleshooting

### Common Issues

#### 1. Workflow Not Triggering

**Symptoms:** Chucky doesn't respond to `!` commands in Discord

**Fixes:**
- ✅ Verify workflow is **Active** (green switch)
- ✅ Check Discord Trigger node has correct channel ID
- ✅ Ensure bot has "Read Messages" permission in channel
- ✅ Confirm "Message Content Intent" is enabled in Discord Developer Portal
- ✅ Check n8n execution log for webhook registration errors

**Debug:**
- Send test message: `!test`
- Check n8n Executions tab → Should see new execution
- If no execution, webhook registration failed

**Fix webhook:**
1. Deactivate workflow
2. Wait 10 seconds
3. Activate again
4. Check logs for "Webhook registered successfully"

#### 2. Vision Analysis Errors

**Symptoms:** "Failed to analyze image" or timeout errors

**Fixes:**
- ✅ Verify Google PaLM API credential is valid
- ✅ Check Gemini API quota (free tier: 60 requests/minute)
- ✅ Ensure image is under 20MB
- ✅ Confirm Gemini 1.5 Pro is available in your region

**Debug:**
- Test Gemini node manually with sample image
- Check error message for specific API error code

**Common API errors:**
- `429 Too Many Requests`: Wait and retry, or upgrade quota
- `403 Forbidden`: API key invalid or API not enabled
- `400 Bad Request`: Image format not supported (use JPEG/PNG/WEBP)

#### 3. RAG Retrieval Returns No Results

**Symptoms:** Agent says "No relevant documentation found"

**Fixes:**
- ✅ Verify Supabase vector store is populated with documents
- ✅ Check table name is `learnable_content` (or update workflow)
- ✅ Lower similarity threshold (try 0.5 instead of 0.7)
- ✅ Increase Top K (try 10 instead of 5)
- ✅ Verify Gemini Embeddings node is connected

**Debug:**
- Query Supabase directly:
  ```sql
  SELECT COUNT(*) FROM learnable_content;
  ```
  Should return > 0
- Check embedding dimension matches (768 for Gemini)

**Solution if empty:**
- Create PDF ingestion workflow (see Prerequisites)
- Populate knowledge base before using Chucky

#### 4. AI Agent Timeout

**Symptoms:** Workflow execution times out after 2 minutes

**Fixes:**
- ✅ Reduce max iterations (try 5 instead of 10)
- ✅ Simplify agent tools (remove HTTP tool if not needed)
- ✅ Increase n8n execution timeout:
  - Settings → Workflows → Execution Timeout (set to 5 minutes)

**Debug:**
- Check which node is timing out in execution log
- If Vector Store Tool times out, optimize Supabase queries

#### 5. Discord Response Not Formatted

**Symptoms:** Response appears as plain text, not markdown

**Fixes:**
- ✅ Discord auto-formats markdown in messages
- ✅ Ensure no extra backticks breaking formatting
- ✅ Check "Format Discord Response" node code

**Debug:**
- Test response manually in Discord
- Verify markdown syntax (e.g., `**bold**`, `1.` for lists)

#### 6. Chat Memory Not Persisting

**Symptoms:** Chucky doesn't remember previous conversation

**Fixes:**
- ✅ Verify Postgres connection is working
- ✅ Check session ID is correctly set:
  ```
  ={{ $json.sessionId }}
  ```
  Should be Discord user ID, not channel ID
- ✅ Confirm `n8n_chat_histories` table exists in Postgres

**Debug:**
- Query Postgres:
  ```sql
  SELECT * FROM n8n_chat_histories LIMIT 10;
  ```
  Should show stored conversations
- If table doesn't exist, Postgres Chat Memory node will auto-create on first execution

#### 7. External Search Tool Fails

**Symptoms:** Agent says "External search unavailable"

**Fixes:**
- ✅ Verify Brave API key is valid
- ✅ Check API quota (free tier: 2,000/month)
- ✅ Ensure HTTP tool URL is correct
- ✅ Test Brave API directly: `curl -H "X-Subscription-Token: YOUR_KEY" "https://api.search.brave.com/res/v1/web/search?q=test"`

**Alternative:**
- Replace with SerpAPI or remove tool entirely (agent will work without it)

---

## FAQ

### General

**Q: Can I use Chucky without Discord?**
A: Yes, but you'll need to replace the Discord Trigger and Send nodes with alternatives (Telegram, Slack, webhook, etc.). The core RAG + Agent logic is platform-agnostic.

**Q: How much does it cost to run?**
A: Variable costs:
- **n8n:** Free (self-hosted) or $20-50/month (cloud)
- **Google Gemini:** Free tier (60 RPM) or $7 per 1M tokens (paid)
- **xAI Grok:** Pay-per-use (pricing varies)
- **Supabase:** Free tier (500MB DB + 2GB bandwidth) or $25/month (Pro)
- **Brave Search:** Free tier (2K searches/month) or $5/month (20K)

Estimated: **$0-10/month** for low usage (<1000 queries), **$50-100/month** for moderate usage (5000+ queries).

**Q: Can I use Claude instead of Grok?**
A: Yes! Replace the "xAI Grok Model" node with "Anthropic Chat Model":
- Type: `@n8n/n8n-nodes-langchain.lmChatAnthropic`
- Model: `claude-3-5-sonnet-20241022`
- Credential: Anthropic API

Claude often provides more detailed reasoning and better structured outputs.

**Q: How do I customize Chucky's personality?**
A: Edit the system message in two places:
1. **AI Agent node** → Prompt → System Message
2. **Gemini Vision Analysis node** → Prompt → System role

Example for a more concise personality:
```
You are Chucky, a no-nonsense industrial maintenance expert.
Be direct, concise, and action-oriented. Skip pleasantries.
Provide only essential troubleshooting steps in numbered lists.
Always mention safety hazards upfront.
```

### Technical

**Q: What's the ReAct agent pattern?**
A: ReAct (Reasoning + Acting) is an AI pattern where the agent:
1. **Reason:** Think about the problem
2. **Act:** Use a tool (search docs, run code, etc.)
3. **Observe:** Review tool output
4. **Repeat:** Iterate until solution is found

This allows multi-step problem-solving beyond simple Q&A.

**Q: Why use SplitInBatches for iteration?**
A: SplitInBatches creates a loop that allows the agent to refine its response based on intermediate results. Useful for complex troubleshooting that requires multiple steps.

**Q: Can I add more tools to the AI Agent?**
A: Yes! Add tool nodes and connect them:
- **Calculator Tool:** For engineering calculations
- **Workflow Tool:** Trigger other n8n workflows
- **Custom HTTP Tools:** API integrations (weather, inventory systems, etc.)

Connect any tool's `ai_tool` output to the "Chucky AI Agent" node's `ai_tool` input.

**Q: How do I improve response quality?**
A:
1. **Better knowledge base:** Add more high-quality PDFs (manuals, procedures)
2. **Better embeddings:** Use larger embedding models if available
3. **Better prompts:** Refine system messages with examples
4. **Better context:** Increase Top K (more documents retrieved)
5. **Better LLM:** Use Claude 3.5 Sonnet instead of Grok (often more accurate)

**Q: Can Chucky handle multiple users simultaneously?**
A: Yes! Session management via Discord user IDs ensures:
- Each user has separate chat memory
- Conversations don't mix
- Parallel executions are isolated

n8n can handle ~10-50 concurrent users depending on your instance resources.

**Q: How do I backup/version the knowledge base?**
A: Use Supabase database backups:
- Supabase Dashboard → Database → Backups
- Export table: `pg_dump -h HOST -U USER -t learnable_content > backup.sql`
- Version control: Store PDF sources in Git, re-ingest as needed

### Customization

**Q: Can I restrict Chucky to specific Discord channels?**
A: Yes! In Discord Trigger node:
- **Channel:** Enter specific channel ID
- OR keep empty and use role-based permissions in Discord itself

**Q: How do I add custom commands beyond `!troubleshoot`?**
A: Add a Switch node after "Extract Message Data" to route by command:
- `!troubleshoot` → Existing flow
- `!manual [query]` → Direct RAG retrieval (skip vision)
- `!safety [topic]` → Filter for safety docs only
- `!status` → Check system status

**Q: Can I make Chucky proactive (send alerts)?**
A: Yes, but requires separate trigger:
- Create Schedule Trigger (runs every hour)
- Query equipment monitoring system
- If anomaly detected → Send Discord message
- Keep as separate workflow, or merge into this one

**Q: How do I log all Chucky interactions?**
A: Add HTTP Request node after "Send Troubleshooting Steps":
- URL: Your logging endpoint
- Body: `{ "user": "{{ $json.username }}", "query": "{{ $json.query }}", "response": "{{ $json.formattedMessage }}" }`

OR use Supabase to store in a `chucky_logs` table.

---

## Advanced Configuration

### Multi-Language Support

Add language detection and translation:

1. **After Extract Message Data:**
   - Add Code node to detect language
   - Use HTTP Request to Google Translate API

2. **Before Discord Send:**
   - Translate response back to user's language

### Confidence Tuning by Equipment Type

Replace simple If node with Switch:

```javascript
// Route by equipment category AND confidence
if ($json.category === 'Electrical' && $json.confidence < 90) {
  // Electrical requires higher confidence due to safety
  return [{ json: { action: 'clarify' } }];
} else if ($json.confidence < 80) {
  return [{ json: { action: 'clarify' } }];
} else {
  return [{ json: { action: 'proceed' } }];
}
```

### Role-Based Responses

Customize output based on user role (technician vs. supervisor):

1. **Fetch Discord roles** in Extract Data node
2. **Branch responses:**
   - Technicians: Detailed step-by-step
   - Supervisors: High-level summary + estimated repair time

---

## Support & Resources

### Documentation
- **n8n Docs:** https://docs.n8n.io/
- **n8n AI Nodes:** https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain/
- **Supabase Vector:** https://supabase.com/docs/guides/ai
- **Gemini API:** https://ai.google.dev/docs

### Community
- **n8n Community Forum:** https://community.n8n.io/
- **Discord:** n8n Discord server

### Troubleshooting
- **n8n Execution Logs:** Workflows → Executions → Click on failed execution
- **Supabase Logs:** Dashboard → Logs
- **Discord Developer Portal:** Check bot permissions and intents

---

## Credits

**Workflow Design:** Based on Grok Chucky Redo 1 PRD
**Implementation:** n8n automation specialist + Claude Code
**AI Models:**
- Google Gemini 1.5 Pro (vision)
- xAI Grok (reasoning)
- Google Gemini Embeddings (vectors)

**Open Source Components:**
- n8n (workflow automation)
- Supabase (vector database)
- PostgreSQL (chat memory)

---

## Version History

**v1.0** (2025-11-03)
- Initial release
- 25 core nodes
- Multi-modal input (text, images, PDFs)
- RAG pipeline with Supabase
- ReAct agent with 3 tools
- Discord integration
- Error handling and retry logic

---

**Questions or Issues?** Open an issue in the project repository or contact the development team.

**Want to contribute?** Fork the workflow, make improvements, and submit a pull request with your enhancements!

---

*Chucky Discord RAG Agent - Making industrial troubleshooting intelligent, one query at a time.* 🔧🤖
That is a crucial question. This is the single biggest difference between the self-hosted and cloud versions of n8n.

You are correct to be skeptical. My previous answer was for self-hosted users.

**On the n8n Cloud, you *cannot* install most community nodes.**

For security and stability, n8n Cloud only allows you to use:

1.  The official, built-in nodes.
2.  A small, hand-picked list of "verified" community nodes.

The `n8n-nodes-discord-trigger` node I mentioned is **not** on that verified list, so you cannot install it.

-----

## The Correct Solution for n8n Cloud

Don't worry, there is a standard and very reliable way to do this. Instead of a "Discord Trigger" node, you will use the built-in **`Webhook`** trigger.

The high-level idea is:

1.  Your n8n workflow starts with a **Webhook Trigger**, which gives you a unique URL.
2.  You set up a very simple "helper" bot.
3.  When a message is posted in Discord, the helper bot instantly catches it and forwards it to your n8n Webhook URL.
4.  Your n8n workflow triggers immediately.

### How to Set This Up

You have two options for the "helper bot."

#### Option 1: Invite a Pre-Made "Trigger Bot" (Easiest)

This is the fastest method. There are free, open-source bots built by the n8n community specifically for this purpose. One of the most popular is the "n8n Discord Trigger Bot."

1.  **In n8n:**

      * Create a new workflow.
      * For the first node, select the **`Webhook`** trigger.
      * Copy the **Test URL**. You will need this in a moment.
      * Click **"Listen for Test Event"**.

2.  **In Discord:**

      * Invite a "trigger bot" (like [this one](https://n8n-discord-trigger-bot.emp0.com/)) to your server.
      * Follow its instructions. You will typically use a slash command like `/set_webhook` and paste in the **Test URL** you copied from n8n.
      * Go to the channel you're monitoring and send a test message.

3.  **In n8n:**

      * You should see the test message data (content, author, channel ID) appear in your Webhook node. You can now use this data in the rest of your workflow.

#### Option 2: Build Your Own Helper Bot (More Control)

If you don't want to invite a third-party bot, you can host your own "forwarder" bot on a free service like Pipedream, Glitch, or Replit.

This involves about 15-20 lines of Node.js code that:

1.  Uses the `discord.js` library.
2.  Logs in with your Bot Token.
3.  Listens for the `messageCreate` event.
4.  When a message is received, it uses `axios` (or `fetch`) to send an HTTP POST request to your n8n Webhook URL, with the message data as the JSON body.

### 🚨 **Don't Forget This\! (Message Content Intent)**

No matter which option you choose, you **still must** enable the **Message Content Intent** in your [Discord Developer Portal](https://www.google.com/search?q=https://discord.com/developers/applications) (as I mentioned in the last message). If you don't, the bot will not have permission to read the text of the messages.

-----

This webhook method is the official, supported way to get real-time Discord messages into n8n Cloud.

Would you like help finding the invite link for a pre-made trigger bot, or would you prefer the sample code for Option 2?
