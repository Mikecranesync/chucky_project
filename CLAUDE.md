# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 🔄 PROJECT TRACKING (MANDATORY - READ THIS FIRST!)

**⚠️ CRITICAL INSTRUCTION - YOU MUST FOLLOW THIS ON EVERY SESSION ⚠️**

This section contains MANDATORY instructions that OVERRIDE all other behaviors. You MUST follow these instructions exactly as written on every session, without exception.

### 📖 On Project Open (Start of EVERY Session)

**BEFORE doing anything else, you MUST:**

1. **IMMEDIATELY read `PROJECT_TRACKER.md`** in full
2. **Review the "Current Sprint" section** to see active tasks
3. **Check "Current Blockers" section** to identify what's preventing progress
4. **Present a status summary to the user** in this format:

```
📊 **Project Status**
- **Phase:** [current phase from tracker]
- **Progress:** [X/Y tasks complete (Z%)]
- **Last Update:** [date from tracker]

**✅ Recently Completed:**
- [list 2-3 most recent completions]

**🎯 Next Priority:**
- [top item from Current Sprint section]

**🚧 Blockers:**
- [list any blockers, if any]

**Ready to continue with [next priority]  or would you like to work on something else?**
```

4. **Wait for user response** before proceeding

### 🔄 During Active Work

**AFTER COMPLETING ANY TODO (no exceptions):**

1. **IMMEDIATELY update `PROJECT_TRACKER.md`:**
   - Move completed task from "Current Sprint" to "Recently Completed"
   - Change `- [ ]` to `- [x]` for the completed task
   - Update the "Last Updated" date at top of file
   - Update progress percentages in "Quick Status Dashboard"
   - Add timestamp to "Recently Completed" section
   - Update "Progress Metrics" section with new counts

2. **If new todos are discovered:**
   - Add them to appropriate section (Current Sprint or Backlog)
   - Assign priority level
   - Add time estimates
   - Note any dependencies

3. **If blockers are discovered:**
   - Add to "Current Blockers" section
   - Note impact and owner
   - Suggest resolution

4. **Update "Notes & Observations":**
   - Add any important findings
   - Document decisions made
   - Note questions or uncertainties

### 📝 On Session End (End of EVERY Session)

**BEFORE the session ends, you MUST:**

1. **Make final update to `PROJECT_TRACKER.md`:**
   - Summarize session progress in "Notes & Observations"
   - Update "Next Session Priorities" section with clear next steps
   - Ensure all completed tasks are marked
   - Update all metrics and percentages

2. **Create a session summary for the user:**
```
📊 **Session Summary**

**Completed This Session:**
- [list all tasks completed]

**Time Spent:** [estimate]

**Next Steps:**
1. [first priority for next session]
2. [second priority]
3. [third priority]

**Blockers to Resolve:**
- [list any blocking items]

**Updated:** PROJECT_TRACKER.md
```

3. **Commit the tracker update:**
```bash
git add PROJECT_TRACKER.md
git commit -m "chore: update project tracker [session end YYYY-MM-DD]"
```

### 🔔 On Major File Modifications

**WHEN these types of changes happen:**

| Change Type | Action Required |
|-------------|-----------------|
| **Workflow Added/Modified** | Update "Workflows" section in tracker |
| **Documentation Added** | Update "Documentation" checklist |
| **Credentials Rotated** | Update "Security" section, note rotation date |
| **Deployment Completed** | Update "Deployment Status" section |
| **Blocker Resolved** | Remove from "Current Blockers", note resolution |
| **New Integration Added** | Add to backlog, update infrastructure docs |

### ❌ NEVER Do These Things

1. **NEVER start working without reading PROJECT_TRACKER.md first**
2. **NEVER complete a task without updating PROJECT_TRACKER.md immediately after**
3. **NEVER let PROJECT_TRACKER.md become stale (>1 hour old during active work)**
4. **NEVER ask "what should we work on?" without first consulting PROJECT_TRACKER.md**
5. **NEVER end a session without updating "Next Session Priorities"**
6. **NEVER commit code changes without also committing tracker updates**

### ✅ Best Practices

1. **Treat PROJECT_TRACKER.md as the single source of truth** for project status
2. **Update it in real-time**, not at end of session
3. **Be specific** in notes and observations
4. **Keep metrics accurate** - they drive planning
5. **Note time estimates vs actual** to improve future estimates
6. **Document WHY decisions were made**, not just what was done
7. **Update immediately when blockers are discovered or resolved**
8. **Keep "Next Session Priorities" always accurate and actionable**

### 🎯 Examples of Good Updates

**Good Task Completion Update:**
```markdown
- [x] **[MANUAL]** Rotate Discord Credentials
  - **Status:** ✅ COMPLETED (2025-11-05 14:23)
  - **Time Actual:** 12 minutes (estimate was 10)
  - **Completed By:** User
  - **Notes:** New bot token and client secret generated, updated in n8n Cloud credentials. Old tokens confirmed revoked in Discord Developer Portal. All webhooks tested and working.
  - **Unblocks:** Tasks #14 (Discord bot deployment), #18 (Discord RAG workflow)
```

**Good Session Notes:**
```markdown
### Session 2 (Nov 6, 2025)
- User completed Discord credential rotation successfully
- Discovered that Supabase pgvector extension was already enabled
- Repository cleanup took 45 minutes (thorough manual approach)
- Pushed to GitHub, all CI workflows triggered successfully
- **Decision:** Use ChuckyDiscordRAG.json as primary workflow (simpler than interactive approach)
- **Blocker Resolved:** Discord credentials rotated, can now proceed with deployment
- **New Blocker:** GitHub Actions failing due to missing N8N_API_KEY secret
```

---

## Project Overview

**Chucky** is an intelligent photo organization and management n8n workflow that automatically categorizes and organizes images using AI. The workflow monitors Google Drive folders, analyzes images with Google Gemini AI, stores metadata in Supabase, and provides conversational querying capabilities through a RAG (Retrieval Augmented Generation) system.

## Core Functionality

### 1. Automated Photo Processing Pipeline

The workflow processes images through this sequence:
- **Trigger**: Google Drive folder monitoring (uses webhooks/push notifications for instant processing)
- **Download**: Fetches images from Google Drive
- **AI Analysis**: Uses Google Gemini (models: gemini-1.5-pro-latest, gemini-2.5-pro-preview) to categorize images
- **Parsing**: JavaScript code node extracts structured data from AI response
- **Storage**: Saves metadata to Supabase `photos` table
- **Organization**: Searches/creates appropriate folders based on categories

### 2. Image Categorization System

The AI categorizes images into these primary categories:
- **Industrial & Equipment**: electrical, mechanical, hvac, instrumentation, safety, piping, vehicles, tools, machinery
- **Personal & Lifestyle**: family, friends, pets, selfies, portraits, events, celebrations, travel, vacation, food, home
- **Nature & Outdoors**: landscapes, wildlife, plants, flowers, trees, beaches, mountains, sky, weather, sunset
- **Activities & Hobbies**: sports, exercise, cooking, gardening, crafts, music, art, gaming, reading, projects
- **Work & Professional**: office, meetings, presentations, documents, construction, business, workplace
- **Transportation**: cars, trucks, motorcycles, boats, planes, trains, parking, roads, traffic
- **Buildings & Architecture**: houses, buildings, interiors, rooms, architecture, construction, real estate
- **Objects & Items**: products, purchases, collections, belongings, technology, electronics, appliances
- **Education & Learning**: school, books, classes, training, workshops, certificates, studying
- **Medical & Health**: medical equipment, hospitals, health records, injuries, treatments, wellness

### 3. AI Response Schema

The Gemini model returns structured JSON with:
```json
{
  "primaryCategory": "main_category_name",
  "subcategory": "specific_subcategory",
  "confidence": "0-100",
  "description": "detailed_description",
  "keywords": ["keyword1", "keyword2"],
  "extractedText": "any_visible_text",
  "isIndustrial": boolean,
  "mainSubjects": ["subject1", "subject2"],
  "setting": "indoor|outdoor|unknown",
  "timeOfDay": "morning|afternoon|evening|night|unknown",
  "peoplePresent": boolean,
  "brandLogos": ["brand1", "brand2"],
  "actionHappening": "description_or_none"
}
```

### 4. RAG System - "Chucky's Brain"

The workflow includes a conversational AI system powered by:
- **Vector Store**: Supabase pgvector for semantic search of photo metadata
- **Embeddings**: Google Gemini embeddings
- **Chat Model**: xAI Grok for natural language interactions
- **Memory**: Postgres-based chat memory for conversation context
- **Capability**: Users can ask questions about their photos and get intelligent responses based on the indexed metadata

### 5. Additional Integrations

- **Airtable**: Status tracking with custom fields (Todo/In progress/Done)
- **PDF Processing**: Parse and process PDF documents
- **HTTP APIs**: External file upload and polling capabilities

## Technical Architecture

### Data Flow

1. **Image Processing Branch** (multiple parallel paths):
   - Google Drive Trigger → Download → Limit → Gemini Analysis → Code Parser → Supabase Insert
   - Folder search and organization happens in parallel

2. **Vector Store Indexing**:
   - Documents → Embeddings (Gemini) → Supabase Vector Store
   - Enables semantic search across photo metadata

3. **Query/Chat Interface**:
   - User question → Vector Store retrieval → xAI Grok → Response with context from photos

### Key Nodes

- **Google Drive nodes**: Triggers, file operations, folder management
- **Gemini AI nodes**: Image analysis, embeddings generation
- **Code nodes**: JavaScript for parsing AI responses, data transformation
- **Supabase nodes**: Database operations, vector store
- **xAI Grok**: Chat model for conversational interface
- **Postgres**: Chat memory storage
- **Airtable**: Project/status tracking

### Database Schema

**Supabase tables**:
- `photos`: Stores photo metadata (name, category, description, source_url)
- `folders`: Maps folder names to Google Drive folder IDs (name PRIMARY KEY, drive_folder_id, created_at)
- Vector embeddings stored in Supabase pgvector

## Development Notes

### Working with n8n Workflows

This is an **n8n workflow JSON export**. To work with it:

1. **Import into n8n**:
   - Open n8n instance
   - Go to Workflows → Import from File
   - Select `Chucky (30).json`

2. **Required Credentials**:
   - Google Drive OAuth2 (account 7)
   - Google Gemini/PaLM API (account 3)
   - Supabase API
   - Postgres database
   - Airtable Personal Access Token (account 2)
   - xAI account
   - Custom Header Auth for file uploads

3. **Configuration**:
   - Update folder IDs to match your Google Drive structure
   - Adjust Gemini model versions as needed
   - Set appropriate maxOutputTokens for AI responses (currently 300)

### Google Drive Webhook Setup

The workflow uses **Google Drive push notifications (webhooks)** instead of polling for instant, efficient file processing:

**Benefits**:
- **Instant processing**: Files are processed immediately when added to Google Drive (no 1-minute polling delay)
- **Lower costs**: No continuous API polling - only triggered when files are actually added
- **Better reliability**: Google's push notification system is more reliable than periodic polling
- **Reduced API quota usage**: Webhooks don't count against Drive API rate limits like polling does

**How it works**:
- Google Drive trigger nodes without `pollTimes` automatically use Google's push notification API
- When a file is created/updated in the monitored folder, Google sends a webhook to n8n
- n8n immediately starts processing the file through the workflow

**Setup Requirements**:
1. n8n must be accessible from the internet (webhooks require public URL)
2. Google Drive OAuth2 credentials must have proper permissions
3. On first activation, n8n registers the webhook with Google Drive API
4. Google automatically manages webhook renewal (typically 24-hour expiration, auto-renewed by n8n)

**Active Triggers** (configured for webhooks):
- `Google Drive IFTTT`: Monitors "Unprophoto" folder for updates
- `Google Drive Backlog`: Monitors "Unprophoto" folder for new files
- `Unprophoto to supabase vector`: Monitors "Unprophoto" for vector indexing
- `Parse PDF` / `Parse PDF1`: Monitors "Unpropdf" folder for PDF processing

**Troubleshooting**:
- If triggers don't fire: Re-activate the workflow to re-register webhooks with Google
- Check n8n logs for webhook registration errors
- Ensure n8n URL is publicly accessible and uses HTTPS
- Verify Google Drive credentials have required scopes

### Code Node Logic

The JavaScript parsing code in the Code nodes:
- Extracts JSON fields from Gemini's text response using regex
- Handles multiple possible response formats
- Generates folder-safe names (lowercase, dash-separated)
- Adds confidence levels (high >80, medium >50, low ≤50)
- Preserves original AI response for debugging

### Disabled Nodes

Some nodes are marked as `"disabled": true`:
- Original Google Drive IFTTT trigger
- Google Drive Backlog trigger
- SQL table creation query

These may be experimental or replaced by newer implementations.

### Extending the Workflow

To add new categories:
1. Update the Gemini prompt in the "Analyze image" nodes
2. Ensure the Code node regex parsing handles new category names
3. Update Airtable or database schemas if storing additional metadata

To modify AI behavior:
- Adjust `maxOutputTokens` in Gemini nodes
- Update the system prompt for different categorization logic
- Change model IDs to use newer Gemini versions

To add processing steps:
- Insert nodes between existing connections
- Maintain data flow: Download → Analyze → Parse → Store
- Test with Limit nodes to avoid processing all files during development

## File Structure

```
chucky_project/
└── Chucky (30).json    # Complete n8n workflow definition
```

The JSON contains the complete workflow including:
- Node definitions and configurations
- Connection mappings between nodes
- Credential references
- Position data for visual workflow layout
