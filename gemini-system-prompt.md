# Gemini AI System Prompt for Image Analysis

This is the optimized system prompt to use in your n8n Gemini AI nodes for analyzing and categorizing images.

## System Prompt for Gemini Node

Copy this into the **"text"** field of your Gemini AI nodes (`6 Analyze image`, `6 Analyze image1`, `6 Analyze image2`):

```
Analyze this image and categorize it into the most appropriate category. Look at the main subject and content to determine the best classification.

CATEGORIES TO CONSIDER:

INDUSTRIAL & EQUIPMENT:
- electrical, mechanical, hvac, instrumentation, safety, piping, vehicles, tools, machinery

PERSONAL & LIFESTYLE:
- family, friends, pets, selfies, portraits, events, celebrations, travel, vacation, food, home

NATURE & OUTDOORS:
- landscapes, wildlife, plants, flowers, trees, beaches, mountains, sky, weather, sunset

ACTIVITIES & HOBBIES:
- sports, exercise, cooking, gardening, crafts, music, art, gaming, reading, projects

WORK & PROFESSIONAL:
- office, meetings, presentations, documents, construction, business, workplace

TRANSPORTATION:
- cars, trucks, motorcycles, boats, planes, trains, parking, roads, traffic

BUILDINGS & ARCHITECTURE:
- houses, buildings, interiors, rooms, architecture, construction, real estate

OBJECTS & ITEMS:
- products, purchases, collections, belongings, technology, electronics, appliances

EDUCATION & LEARNING:
- school, books, classes, training, workshops, certificates, studying

MEDICAL & HEALTH:
- medical equipment, hospitals, health records, injuries, treatments, wellness

INSTRUCTIONS:
1. Analyze the image carefully
2. Identify the primary category and a specific subcategory
3. Extract any visible text from the image
4. Determine if people are present
5. Identify the setting (indoor/outdoor)
6. Detect any brand logos or trademarks
7. Assess your confidence level (0-100)

CRITICAL: Respond ONLY with valid JSON. No markdown formatting, no code blocks, no explanations. Just the JSON object.

Required JSON format:
{
  "primaryCategory": "main_category_name",
  "subcategory": "specific_subcategory",
  "confidence": 85,
  "description": "detailed_description_of_image_content",
  "keywords": ["keyword1", "keyword2", "keyword3", "keyword4", "keyword5"],
  "extractedText": "any_visible_text_in_image_or_empty_string",
  "isIndustrial": false,
  "mainSubjects": ["subject1", "subject2"],
  "setting": "indoor",
  "timeOfDay": "afternoon",
  "peoplePresent": true,
  "brandLogos": ["brand1", "brand2"],
  "actionHappening": "description_of_activity_or_none"
}

FIELD REQUIREMENTS:
- primaryCategory: Choose from the main categories listed above
- subcategory: More specific classification (e.g., "portraits", "electrical", "landscapes")
- confidence: Number from 0 to 100 (no quotes)
- description: Detailed 1-2 sentence description of what's in the image
- keywords: Array of 5-10 relevant single-word or hyphenated keywords, ordered by importance/relevance
  * Use lowercase, simple words
  * Prefer single words (e.g., "family", "beach", "sunset")
  * Use hyphens for compound concepts (e.g., "safety-equipment", "beach-vacation")
  * NO spaces in individual keywords
  * Order from most important to least important
  * First 2-3 keywords should be most descriptive
- extractedText: Any text visible in the image, use empty string "" if none
- isIndustrial: true or false (no quotes)
- mainSubjects: Array of 1-3 main subjects in the image
- setting: Must be "indoor", "outdoor", or "unknown"
- timeOfDay: Must be "morning", "afternoon", "evening", "night", or "unknown"
- peoplePresent: true or false (no quotes)
- brandLogos: Array of brand names visible, empty array [] if none
- actionHappening: Brief description of action/activity, or "none"

VALIDATION RULES:
✓ Use lowercase for category names (e.g., "family" not "Family")
✓ Numbers should NOT be in quotes (confidence: 85, not "85")
✓ Booleans should NOT be in quotes (true, not "true")
✓ Empty arrays should be [] not null
✓ Empty strings should be "" not null
✓ All string values must use double quotes
✓ Do not include trailing commas

RESPOND WITH ONLY THE JSON OBJECT. NO OTHER TEXT.
```

## Alternative Compact Version

If you need a shorter version with the same effectiveness:

```
Analyze this image and respond ONLY with valid JSON (no markdown, no code blocks):

{
  "primaryCategory": "choose: industrial-equipment, personal-lifestyle, nature-outdoors, activities-hobbies, work-professional, transportation, buildings-architecture, objects-items, education-learning, medical-health",
  "subcategory": "specific_type",
  "confidence": 85,
  "description": "detailed_description",
  "keywords": ["keyword1", "keyword2", "keyword3"],
  "extractedText": "text_from_image_or_empty",
  "isIndustrial": false,
  "mainSubjects": ["subject1", "subject2"],
  "setting": "indoor|outdoor|unknown",
  "timeOfDay": "morning|afternoon|evening|night|unknown",
  "peoplePresent": true,
  "brandLogos": ["logo1"],
  "actionHappening": "activity_description_or_none"
}

CRITICAL RULES:
- Numbers without quotes (confidence: 85)
- Booleans without quotes (true/false)
- No trailing commas
- No markdown formatting
- Use lowercase for categories
- Empty arrays as []
- Empty strings as ""
```

## Implementation Notes

### Where to Use This Prompt

Update these nodes in your n8n workflow:
1. **6 Analyze image** (line ~40 in Chucky (30).json)
2. **6 Analyze image1** (line ~204 in Chucky (30).json)
3. **6 Analyze image2** (if you have it)

### Model Settings

Recommended settings for the Gemini node:
- **Model**: `models/gemini-2.5-pro-preview-03-25` (or latest)
- **Max Output Tokens**: 400-500 (increased from 300 to allow complete responses)
- **Temperature**: 0.1-0.3 (lower = more consistent JSON formatting)
- **Input Type**: binary (for image analysis)

### Testing the Prompt

After updating:
1. Run a test with a sample image
2. Check the Code node output
3. Verify all 13 fields are populated
4. Look at `originalGeminiResponse` field to see raw response
5. If JSON parsing fails, increase Max Output Tokens

## Troubleshooting

### If Gemini Returns Markdown-Wrapped JSON

The Code node will still extract the JSON from markdown blocks like:
```json
{ ... }
```

The regex patterns handle this automatically.

### If Fields Are Missing

- Increase `maxOutputTokens` to 500
- Check that the prompt hasn't been truncated
- Verify the model supports vision/image analysis

### If Confidence is Always Low

- Add example images to the prompt (advanced)
- Adjust the categories to better match your use case
- Use a newer Gemini model version

## Example Expected Response

When working correctly, Gemini should respond with:

```json
{
  "primaryCategory": "personal-lifestyle",
  "subcategory": "family",
  "confidence": 92,
  "description": "A family photo showing four people smiling at a beach during sunset",
  "keywords": ["family", "beach", "sunset", "vacation", "happy", "ocean", "summer", "portrait"],
  "extractedText": "",
  "isIndustrial": false,
  "mainSubjects": ["people", "beach", "sunset"],
  "setting": "outdoor",
  "timeOfDay": "evening",
  "peoplePresent": true,
  "brandLogos": [],
  "actionHappening": "posing for photo"
}
```

**Example - Industrial Photo:**
```json
{
  "primaryCategory": "industrial-equipment",
  "subcategory": "electrical",
  "confidence": 95,
  "description": "Industrial electrical control panel with multiple circuit breakers and safety labels",
  "keywords": ["electrical", "control-panel", "safety", "industrial", "circuit-breaker", "equipment", "power", "maintenance"],
  "extractedText": "DANGER HIGH VOLTAGE",
  "isIndustrial": true,
  "mainSubjects": ["control-panel", "circuit-breakers", "safety-labels"],
  "setting": "indoor",
  "timeOfDay": "unknown",
  "peoplePresent": false,
  "brandLogos": ["Siemens", "ABB"],
  "actionHappening": "none"
}
```

This clean JSON will be perfectly parsed by your Code nodes!
