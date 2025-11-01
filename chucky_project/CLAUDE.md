# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
