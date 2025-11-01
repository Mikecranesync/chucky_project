# Enhanced Code Node for Chucky

This code extracts ALL fields from the Gemini AI response and makes them available for use in the rest of your n8n workflow.

## JavaScript Code for Code Nodes

Copy and paste this into your **Code** and **Code2** nodes in n8n:

```javascript
// Get the response from previous node
const item = $input.first().json;

// Get the text - try multiple possible locations for different Gemini response formats
let rawText = '';
try {
    // Try different response structures
    rawText = item.candidates?.[0]?.content?.parts?.[0]?.text ||  // Gemini API format
              item.content?.parts?.[0]?.text ||                    // Alternative format
              item.rawContent ||
              item.text ||
              '';

    // If still empty, stringify the whole item as fallback
    if (!rawText) {
        rawText = JSON.stringify(item);
    }
} catch (e) {
    rawText = JSON.stringify(item);
}

// Strip markdown code blocks if present (```json ... ``` or ``` ... ```)
rawText = rawText.replace(/```json\s*/g, '').replace(/```\s*/g, '');

// Helper function to safely extract string values
function extractString(pattern, defaultValue = '') {
    try {
        const match = rawText.match(pattern);
        return match ? match[1] : defaultValue;
    } catch (e) {
        return defaultValue;
    }
}

// Helper function to safely extract arrays
function extractArray(pattern) {
    try {
        const match = rawText.match(pattern);
        if (!match) return [];
        return match[1]
            .split(',')
            .map(item => item.trim().replace(/['"]/g, ''))
            .filter(item => item.length > 0);
    } catch (e) {
        return [];
    }
}

// Helper function to safely extract booleans
function extractBoolean(pattern, defaultValue = false) {
    try {
        const match = rawText.match(pattern);
        return match ? match[1] === 'true' : defaultValue;
    } catch (e) {
        return defaultValue;
    }
}

// Helper function to safely extract numbers
function extractNumber(pattern, defaultValue = 0) {
    try {
        const match = rawText.match(pattern);
        return match ? parseInt(match[1]) : defaultValue;
    } catch (e) {
        return defaultValue;
    }
}

// Extract all fields using helper functions
const subcategory = extractString(/"subcategory"\s*:\s*"([^"]+)"/, 'uncategorized');
const primaryCategory = extractString(/"primaryCategory"\s*:\s*"([^"]+)"/, '');
const confidence = extractNumber(/"confidence"\s*:\s*(\d+)/, 0);
const description = extractString(/"description"\s*:\s*"([^"]+)"/, '');
const keywords = extractArray(/"keywords"\s*:\s*\[([^\]]+)\]/);
const extractedText = extractString(/"extractedText"\s*:\s*"([^"]+)"/, '').replace(/\\n/g, ' ');
const isIndustrial = extractBoolean(/"isIndustrial"\s*:\s*(true|false)/, false);
const mainSubjects = extractArray(/"mainSubjects"\s*:\s*\[([^\]]+)\]/);
const setting = extractString(/"setting"\s*:\s*"([^"]+)"/, 'unknown');
const timeOfDay = extractString(/"timeOfDay"\s*:\s*"([^"]+)"/, 'unknown');
const peoplePresent = extractBoolean(/"peoplePresent"\s*:\s*(true|false)/, false);
const brandLogos = extractArray(/"brandLogos"\s*:\s*\[([^\]]+)\]/);
const actionHappening = extractString(/"actionHappening"\s*:\s*"([^"]+)"/, 'none');

// Extract individual keywords as separate fields (up to 10)
const keyword1 = keywords[0] || '';
const keyword2 = keywords[1] || '';
const keyword3 = keywords[2] || '';
const keyword4 = keywords[3] || '';
const keyword5 = keywords[4] || '';
const keyword6 = keywords[5] || '';
const keyword7 = keywords[6] || '';
const keyword8 = keywords[7] || '';
const keyword9 = keywords[8] || '';
const keyword10 = keywords[9] || '';

// Determine final category
let category = subcategory;
if (category === 'uncategorized' && primaryCategory) {
    category = primaryCategory;
}

// Clean up for folder name
const folderName = category
    .toLowerCase()
    .replace(/[&\s]+/g, '-')
    .replace(/[^a-z0-9-]/g, '')
    .replace(/--+/g, '-')
    .trim() || 'uncategorized';

// Return structured data
return [{
    json: {
        // Main categorization
        category: category,
        primaryCategory: primaryCategory,
        subcategory: subcategory,
        folderName: folderName,
        confidence: confidence,
        confidenceLevel: confidence > 80 ? 'high' : confidence > 50 ? 'medium' : 'low',

        // Full analysis from Gemini - ALL fields now available
        description: description,
        keywords: keywords,
        extractedText: extractedText,
        isIndustrial: isIndustrial,
        mainSubjects: mainSubjects,
        setting: setting,
        timeOfDay: timeOfDay,
        peoplePresent: peoplePresent,
        brandLogos: brandLogos,
        actionHappening: actionHappening,

        // Individual keyword fields for easy n8n access
        keyword1: keyword1,
        keyword2: keyword2,
        keyword3: keyword3,
        keyword4: keyword4,
        keyword5: keyword5,
        keyword6: keyword6,
        keyword7: keyword7,
        keyword8: keyword8,
        keyword9: keyword9,
        keyword10: keyword10,

        // Keep the original response too
        originalGeminiResponse: rawText,

        // Metadata for your database/tracking
        processedAt: new Date().toISOString()
    }
}];
```

## Available Output Fields

After this code node runs, these fields are available via `{{ $json.fieldName }}`:

### Basic Fields
- `category` - The subcategory name
- `primaryCategory` - Main category from AI
- `subcategory` - Same as category
- `folderName` - URL-safe folder name
- `confidence` - Confidence score (0-100)
- `confidenceLevel` - "high", "medium", or "low"

### AI Analysis Fields
- `description` - Detailed description of the image
- `keywords` - Array of all keywords
- `extractedText` - Text found in the image
- `isIndustrial` - Boolean: is this an industrial image?
- `mainSubjects` - Array of main subjects in the image
- `setting` - "indoor", "outdoor", or "unknown"
- `timeOfDay` - "morning", "afternoon", "evening", "night", or "unknown"
- `peoplePresent` - Boolean: are people in the image?
- `brandLogos` - Array of brand logos detected
- `actionHappening` - Description of action/activity in the image

### Individual Keyword Fields (Easy n8n Access)
- `keyword1` - First keyword (or empty string)
- `keyword2` - Second keyword (or empty string)
- `keyword3` - Third keyword (or empty string)
- `keyword4` - Fourth keyword (or empty string)
- `keyword5` - Fifth keyword (or empty string)
- `keyword6` - Sixth keyword (or empty string)
- `keyword7` - Seventh keyword (or empty string)
- `keyword8` - Eighth keyword (or empty string)
- `keyword9` - Ninth keyword (or empty string)
- `keyword10` - Tenth keyword (or empty string)

### Metadata
- `originalGeminiResponse` - Full raw response from Gemini
- `processedAt` - ISO timestamp when processed

## Usage Examples in n8n

### In Expressions
```javascript
{{ $json.isIndustrial }}                    // Access boolean
{{ $json.setting }}                          // Access string
{{ $json.keyword1 }}                         // Access first keyword directly
{{ $json.keyword2 }}                         // Access second keyword directly
{{ $json.keywords[0] }}                      // Access first keyword from array (alternative)
{{ $json.mainSubjects.join(', ') }}          // Join array to string
```

### In Conditionals (IF node)
```javascript
{{ $json.peoplePresent === true }}           // Photos with people
{{ $json.setting === "outdoor" }}            // Only outdoor photos
{{ $json.confidence > 80 }}                  // High confidence only
{{ $json.isIndustrial && $json.setting === "indoor" }}  // Indoor industrial
{{ $json.keyword1 === "family" }}            // Filter by first keyword
```

### In Set Node / Edit Fields
```
Field Name: photo_setting
Value: {{ $json.setting }}

Field Name: has_people
Value: {{ $json.peoplePresent }}

Field Name: primary_keyword
Value: {{ $json.keyword1 }}

Field Name: secondary_keyword
Value: {{ $json.keyword2 }}

Field Name: all_keywords
Value: {{ $json.keywords.join(', ') }}
```

### Using Individual Keywords in Database Inserts
```javascript
// In Supabase/Postgres/Airtable nodes
keyword_1: {{ $json.keyword1 }}
keyword_2: {{ $json.keyword2 }}
keyword_3: {{ $json.keyword3 }}
keyword_4: {{ $json.keyword4 }}
keyword_5: {{ $json.keyword5 }}
```

### Building Dynamic Folder Names with Keywords
```javascript
{{ $json.folderName }}/{{ $json.keyword1 }}/{{ $json.keyword2 }}
// Example output: "family/vacation/beach"
```

## Notes

- This code uses regex to parse the Gemini AI response
- Default values are provided for all fields if not found in the response
- Arrays are automatically parsed and split
- Boolean values are properly converted from strings
- The original response is preserved in `originalGeminiResponse` for debugging
