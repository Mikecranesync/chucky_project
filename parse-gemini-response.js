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
