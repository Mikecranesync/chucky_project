# Code Node Setup for Chucky

## Quick Start

1. **Copy the code**: Open `parse-gemini-response.js` and copy all the code
2. **Paste into n8n**: Open your Code node in n8n and paste the code
3. **Rename the node**: Use one of the suggested names below

## Suggested Node Names

Choose a descriptive name for your Code node:

### ⭐ Recommended Names:
- **`Parse AI Response`** - Clear and concise
- **`Extract Image Analysis`** - Descriptive of what it does
- **`Parse Gemini Output`** - Specific to the AI service

### Other Good Options:
- `AI Response Parser`
- `Extract AI Fields`
- `Parse Image Data`
- `Gemini Field Extractor`
- `Image Analysis Parser`
- `Extract Photo Metadata`

### ❌ Names to Avoid:
- `Code` (too generic)
- `Code2` (not descriptive)
- `Parser` (unclear what it parses)
- `Extract` (incomplete)

## Workflow Naming Convention

For consistency across your workflow, use the same pattern:

**Pattern 1: Action + Object**
```
Analyze Image     → Parse AI Response
Download File     → Parse AI Response
Create Row        → ...
```

**Pattern 2: Verb + Noun + Descriptor**
```
6 Analyze image1  → Parse Gemini Response
4 Download file1  → Parse Gemini Response
```

**Pattern 3: Numbered Flow**
```
1. Download Image
2. Analyze with Gemini
3. Parse AI Response    ← This is your Code node
4. Save to Database
```

## File Structure

```
chucky_project/
├── Chucky (30).json              # Main workflow file
├── parse-gemini-response.js      # ⭐ CODE TO COPY (this file!)
├── code-node-enhanced.md         # Documentation
├── gemini-system-prompt.md       # AI prompt
├── keyword-variables-guide.md    # Keyword usage guide
└── CLAUDE.md                     # Project documentation
```

## How to Use

### Step 1: Open n8n Workflow
1. Open your Chucky workflow in n8n
2. Find the Code node (currently named "Code" or "Code2")

### Step 2: Replace Code
1. Click on the Code node
2. Delete all existing code in the JavaScript editor
3. Open `parse-gemini-response.js`
4. Copy ALL the code (Ctrl+A, Ctrl+C)
5. Paste into the n8n Code node (Ctrl+V)

### Step 3: Rename Node
1. Right-click the node or click the gear icon
2. Change the name to one of the suggested names above
3. We recommend: **`Parse AI Response`**

### Step 4: Test
1. Execute the node with test data
2. Check the output has all fields:
   - category, primaryCategory, subcategory
   - confidence, confidenceLevel
   - description, keywords, extractedText
   - keyword1, keyword2, ..., keyword10
   - isIndustrial, mainSubjects, setting, timeOfDay
   - peoplePresent, brandLogos, actionHappening

## Expected Output Structure

After running the Code node, you'll have access to:

```javascript
{
  // Categorization
  "category": "family",
  "primaryCategory": "personal-lifestyle",
  "subcategory": "family",
  "folderName": "family",
  "confidence": 92,
  "confidenceLevel": "high",

  // Analysis
  "description": "A family photo showing four people...",
  "keywords": ["family", "beach", "sunset", "vacation"],
  "extractedText": "",

  // Detailed fields
  "isIndustrial": false,
  "mainSubjects": ["people", "beach"],
  "setting": "outdoor",
  "timeOfDay": "evening",
  "peoplePresent": true,
  "brandLogos": [],
  "actionHappening": "posing for photo",

  // Individual keywords (NEW!)
  "keyword1": "family",
  "keyword2": "beach",
  "keyword3": "sunset",
  "keyword4": "vacation",
  "keyword5": "",
  // ... keyword6-10

  // Metadata
  "originalGeminiResponse": "{ ... }",
  "processedAt": "2025-01-15T10:30:00.000Z"
}
```

## Multiple Code Nodes?

If you have multiple Code nodes (Code, Code2, etc.), rename them descriptively:

```
Code   → Parse AI Response (Main)
Code2  → Parse AI Response (Backlog)
Code6  → Parse PDF Response
```

Or use location-based names:
```
Code   → Parse AI Response - IFTTT
Code2  → Parse AI Response - Backlog
```

## Troubleshooting

### Code node shows "Unknown error"
- Make sure you copied ALL the code from `parse-gemini-response.js`
- Check there are no syntax errors
- Verify the previous node (Gemini AI) is outputting data

### Fields are empty
- Check `originalGeminiResponse` field to see raw AI output
- Verify Gemini is returning proper JSON format
- Review `gemini-system-prompt.md` for proper AI prompt

### Keywords not populating
- Check if Gemini is returning keywords in the response
- Increase `maxOutputTokens` in Gemini node to 400-500
- Verify the Gemini prompt includes keyword instructions

## Quick Copy Command

**Windows:**
```powershell
Get-Content parse-gemini-response.js | clip
```

**Mac/Linux:**
```bash
cat parse-gemini-response.js | pbcopy
```

Then paste directly into n8n Code node!

---

**Pro Tip**: Bookmark this file and `parse-gemini-response.js` for quick access when updating your workflow!
