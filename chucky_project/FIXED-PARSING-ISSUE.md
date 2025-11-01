# Fixed: Keyword Parsing Issue

## Problem Identified

The code was not extracting keywords because:

1. **Wrong data structure path**: Gemini API returns data in `candidates[0].content.parts[0].text`, not `content.parts[0].text`
2. **Markdown wrapper**: Gemini wraps JSON response in markdown code blocks (` ```json ... ``` `)

### Before (Broken)
```javascript
// Only checked item.content.parts[0].text
rawText = item.content?.parts?.[0]?.text || ...
// Result: Falls through to JSON.stringify(item) → double-escaped strings
```

### After (Fixed)
```javascript
// Now checks the correct Gemini API structure
rawText = item.candidates?.[0]?.content?.parts?.[0]?.text || ...
// Then strips markdown wrappers
rawText = rawText.replace(/```json\s*/g, '').replace(/```\s*/g, '');
```

## What Was Fixed

### 1. **Added Gemini API Structure Support** ✅
```javascript
item.candidates?.[0]?.content?.parts?.[0]?.text  // NEW: Gemini API format
item.content?.parts?.[0]?.text                    // Fallback format
```

### 2. **Strip Markdown Code Blocks** ✅
Removes ` ```json ` and ` ``` ` wrappers that Gemini adds

### 3. **Better Fallback Logic** ✅
Only uses `JSON.stringify()` if all other paths fail

## Expected Output (Fixed)

Using your test input, the code should now extract:

```json
{
  "category": "electrical",
  "primaryCategory": "industrial & equipment",
  "subcategory": "electrical",
  "folderName": "industrial-equipment",
  "confidence": 99,
  "confidenceLevel": "high",

  "description": "Two Siemens Sinamics S120 drive controllers...",

  "keywords": [
    "siemens",
    "sinamics",
    "drive controller",
    "electrical cabinet",
    "industrial automation",
    "vfd",
    "inverter"
  ],

  "keyword1": "siemens",
  "keyword2": "sinamics",
  "keyword3": "drive controller",
  "keyword4": "electrical cabinet",
  "keyword5": "industrial automation",
  "keyword6": "vfd",
  "keyword7": "inverter",
  "keyword8": "",
  "keyword9": "",
  "keyword10": "",

  "extractedText": "SINAMICS SIEMENS DANGER RISK OF ELECTRIC SHOCK!...",
  "isIndustrial": true,
  "mainSubjects": ["siemens sinamics drive", "electrical cabinet"],
  "setting": "indoor",
  "timeOfDay": "unknown",
  "peoplePresent": false,
  "brandLogos": ["Siemens", "Sinamics"],
  "actionHappening": "none",

  "processedAt": "2025-11-01T08:46:32.685Z"
}
```

## Files Updated

All files have been updated with the fix:

- ✅ `parse-gemini-response.js` - Ready to copy/paste
- ✅ `Chucky (30).json` - Both Code nodes updated
- ✅ `code-node-enhanced.md` - Documentation updated

## Testing Your Fix

### Test with Your Data

Your input was:
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "```json\n{\n  \"primaryCategory\": \"industrial & equipment\", ..."
          }
        ]
      }
    }
  ]
}
```

**Before Fix:**
- category: "uncategorized" ❌
- keywords: [] ❌
- All fields empty ❌

**After Fix:**
- category: "electrical" ✅
- keywords: ["siemens", "sinamics", "drive controller", ...] ✅
- keyword1: "siemens" ✅
- All 7 keywords extracted ✅

## How to Apply the Fix

### Option 1: Copy/Paste JavaScript
1. Open `parse-gemini-response.js`
2. Select all (Ctrl+A)
3. Copy (Ctrl+C)
4. Paste into n8n Code node (Ctrl+V)

### Option 2: Re-import Workflow
1. Import updated `Chucky (30).json` into n8n
2. Both Code nodes are already fixed

## Verification Checklist

After applying the fix, verify:

- [ ] `keywords` array is populated (not empty)
- [ ] `keyword1` through `keyword7` contain values
- [ ] `category` is NOT "uncategorized"
- [ ] `primaryCategory` is populated
- [ ] `confidence` is > 0
- [ ] `description` has text
- [ ] `isIndustrial` is true (for your test image)

## Why This Happened

Gemini API has two response formats:

**LangChain/n8n Integration Format:**
```json
{
  "content": {
    "parts": [{"text": "..."}]
  }
}
```

**Direct Gemini API Format:** (Your case)
```json
{
  "candidates": [{
    "content": {
      "parts": [{"text": "..."}]
    }
  }]
}
```

The code now supports **both formats** automatically.

## Additional Notes

### Markdown Wrapper Handling

Gemini often returns JSON wrapped in markdown:
```
```json
{
  "field": "value"
}
```
```

The fix strips these wrappers automatically:
```javascript
rawText.replace(/```json\s*/g, '').replace(/```\s*/g, '')
```

### Multi-word Keywords

Note: Your Gemini response included multi-word keywords:
- "drive controller" ✅ (allowed with spaces)
- "electrical cabinet" ✅
- "industrial automation" ✅

This is fine, but for better n8n usage, consider updating the Gemini prompt to prefer hyphenated single-word keywords:
- "drive-controller"
- "electrical-cabinet"
- "industrial-automation"

See `gemini-system-prompt.md` for the recommended prompt that generates better keywords.

---

**The fix is complete and ready to use!** 🎉
