# Keyword Variables Guide for n8n

This guide shows you how to use the individual keyword variables in your n8n workflow.

## Overview

Keywords from the AI analysis are now available in **TWO formats**:

1. **Array format**: `keywords` - All keywords in an array
2. **Individual variables**: `keyword1`, `keyword2`, `keyword3`, etc. - Up to 10 individual fields

## Available Keyword Variables

After the Code node processes the image, you have access to:

```javascript
{{ $json.keyword1 }}   // First keyword
{{ $json.keyword2 }}   // Second keyword
{{ $json.keyword3 }}   // Third keyword
{{ $json.keyword4 }}   // Fourth keyword
{{ $json.keyword5 }}   // Fifth keyword
{{ $json.keyword6 }}   // Sixth keyword
{{ $json.keyword7 }}   // Seventh keyword
{{ $json.keyword8 }}   // Eighth keyword
{{ $json.keyword9 }}   // Ninth keyword
{{ $json.keyword10 }}  // Tenth keyword

{{ $json.keywords }}   // Array of all keywords: ["keyword1", "keyword2", ...]
```

## Why Individual Variables?

Individual keyword variables make it easier to:
- ✅ Map keywords to specific database columns
- ✅ Use keywords in conditional logic
- ✅ Build dynamic folder structures
- ✅ Create tags or labels in external systems
- ✅ Filter and route workflows based on specific keywords

## Usage Examples

### 1. Database Insert (Supabase/Postgres/Airtable)

Instead of joining keywords into a single string, map them to individual columns:

```javascript
// Supabase/Postgres Insert
Table: photos
Fields:
  - name: {{ $('4 Download file1').item.json.name }}
  - category: {{ $json.primaryCategory }}
  - description: {{ $json.description }}
  - keyword_1: {{ $json.keyword1 }}
  - keyword_2: {{ $json.keyword2 }}
  - keyword_3: {{ $json.keyword3 }}
  - keyword_4: {{ $json.keyword4 }}
  - keyword_5: {{ $json.keyword5 }}
```

### 2. Conditional Routing with IF Node

Route photos based on specific keywords:

```javascript
// IF node condition - Check if "family" is in any keyword
{{ $json.keyword1 === "family" || $json.keyword2 === "family" || $json.keyword3 === "family" }}
```

```javascript
// IF node condition - Check first keyword for category routing
{{ $json.keyword1 === "industrial" }}
```

### 3. Dynamic Folder/File Naming

Build organized folder structures using keywords:

```javascript
// Google Drive folder path
{{ $json.folderName }}/{{ $json.keyword1 }}/{{ $json.keyword2 }}

// Example outputs:
// "family/vacation/beach"
// "industrial/electrical/safety"
// "nature-outdoors/sunset/ocean"
```

### 4. Airtable Tags

Create linked tags in Airtable:

```javascript
// Airtable node
Table: Photos
Fields:
  - Photo Name: {{ $json.category }}
  - Tags: {{ $json.keyword1 }}, {{ $json.keyword2 }}, {{ $json.keyword3 }}
```

### 5. Email/Notification Templates

Include specific keywords in notifications:

```
Subject: New photo categorized as {{ $json.primaryCategory }}

Details:
- Primary Tag: {{ $json.keyword1 }}
- Secondary Tag: {{ $json.keyword2 }}
- Category: {{ $json.category }}
- Confidence: {{ $json.confidence }}%
```

### 6. Search Index Building

Build search metadata with individual keyword fields:

```javascript
// HTTP Request to search index API
{
  "id": "{{ $json.fileName }}",
  "title": "{{ $json.description }}",
  "tags": [
    "{{ $json.keyword1 }}",
    "{{ $json.keyword2 }}",
    "{{ $json.keyword3 }}",
    "{{ $json.keyword4 }}",
    "{{ $json.keyword5 }}"
  ]
}
```

### 7. Set Node - Transform Data

Create new fields combining keywords:

```javascript
// Set Node
Mode: Manual Mapping
Fields:
  - primary_tag: {{ $json.keyword1 }}
  - secondary_tag: {{ $json.keyword2 }}
  - all_tags: {{ $json.keywords.join(' | ') }}
  - searchable_text: {{ $json.keyword1 }} {{ $json.keyword2 }} {{ $json.keyword3 }}
```

### 8. Filter Photos by Multiple Keywords

Complex filtering logic:

```javascript
// Filter for outdoor family photos
{{
  ($json.keyword1 === "outdoor" || $json.keyword2 === "outdoor") &&
  ($json.keyword1 === "family" || $json.keyword2 === "family")
}}
```

### 9. WordPress/CMS Integration

Create post tags automatically:

```javascript
// WordPress node - Create Post
Title: {{ $json.description }}
Content: Photo uploaded and categorized as {{ $json.category }}
Tags: {{ $json.keyword1 }},{{ $json.keyword2 }},{{ $json.keyword3 }},{{ $json.keyword4 }}
Categories: {{ $json.primaryCategory }}
```

### 10. Google Sheets Row

Map each keyword to a separate column:

```
| File Name | Category | Keyword 1 | Keyword 2 | Keyword 3 | Keyword 4 | Keyword 5 |
|-----------|----------|-----------|-----------|-----------|-----------|-----------|
| photo.jpg | family   | vacation  | beach     | sunset    | happy     | summer    |
```

```javascript
// Google Sheets Append Row
Values:
  - {{ $json.fileName }}
  - {{ $json.category }}
  - {{ $json.keyword1 }}
  - {{ $json.keyword2 }}
  - {{ $json.keyword3 }}
  - {{ $json.keyword4 }}
  - {{ $json.keyword5 }}
```

## Handling Empty Keywords

Keywords default to empty strings if not present:

```javascript
// Check if keyword exists before using
{{ $json.keyword1 ? $json.keyword1 : 'untagged' }}

// Or use ?? operator
{{ $json.keyword5 ?? 'no-tag' }}
```

## Best Practices

### ✅ DO:
- Use `keyword1` and `keyword2` for primary tagging/filtering
- Store individual keywords in separate database columns for better querying
- Use the `keywords` array when you need all keywords together
- Check if a keyword is empty before using it in paths or URLs

### ❌ DON'T:
- Don't assume all 10 keywords will always be populated
- Don't use keyword variables in file paths without sanitization
- Don't forget that keywords can be empty strings

## Example Output

When Gemini analyzes a family beach photo:

```json
{
  "keywords": ["family", "beach", "vacation", "sunset", "ocean"],
  "keyword1": "family",
  "keyword2": "beach",
  "keyword3": "vacation",
  "keyword4": "sunset",
  "keyword5": "ocean",
  "keyword6": "",
  "keyword7": "",
  "keyword8": "",
  "keyword9": "",
  "keyword10": ""
}
```

You can now use:
- `{{ $json.keyword1 }}` → `"family"`
- `{{ $json.keyword2 }}` → `"beach"`
- `{{ $json.keyword5 }}` → `"ocean"`
- `{{ $json.keyword6 }}` → `""` (empty)
- `{{ $json.keywords }}` → `["family", "beach", "vacation", "sunset", "ocean"]`

## Database Schema Example

Recommended Supabase schema for individual keywords:

```sql
CREATE TABLE photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    category TEXT,
    description TEXT,

    -- Individual keyword columns
    keyword_1 TEXT,
    keyword_2 TEXT,
    keyword_3 TEXT,
    keyword_4 TEXT,
    keyword_5 TEXT,

    -- Other fields
    confidence INTEGER,
    setting TEXT,
    people_present BOOLEAN,

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create index for keyword searches
CREATE INDEX idx_keyword_1 ON photos(keyword_1);
CREATE INDEX idx_keyword_2 ON photos(keyword_2);
CREATE INDEX idx_keyword_3 ON photos(keyword_3);
```

Now you can query:
```sql
SELECT * FROM photos WHERE keyword_1 = 'family' OR keyword_2 = 'family';
SELECT * FROM photos WHERE keyword_1 = 'industrial' AND keyword_2 = 'safety';
```

## Quick Reference

| Variable | Type | Example Value | Use Case |
|----------|------|---------------|----------|
| `keyword1` | string | "family" | Primary tag, main category |
| `keyword2` | string | "vacation" | Secondary tag |
| `keyword3` | string | "beach" | Tertiary tag |
| `keyword4` | string | "sunset" | Additional context |
| `keyword5` | string | "happy" | Additional context |
| `keywords` | array | ["family", "vacation", "beach"] | Full list, joining, counting |

---

**Note**: Keywords are extracted from the AI response and can be up to 10 individual values. Always check for empty strings when using keyword6-keyword10 as they may not be populated for every image.
