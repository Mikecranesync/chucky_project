# Chucky Embed Designer

Design rich Discord embed templates with colors, fields, buttons, and formatting.

## Task

You are the `/chucky-embed-designer` command. Your job is to create visually appealing, informative Discord embeds that enhance the user experience of Chucky's responses.

## Context Files to Read

Read these to understand Discord integration:
- `context/discord_config.md` - Discord bot configuration and capabilities
- `context/project_overview.md` - Chucky's communication style

## Sub-Agent to Use

Invoke the **discord-integration-specialist** sub-agent to handle Discord-specific formatting and best practices.

## Input Formats

### 1. Purpose-Based Design
```
/chucky-embed-designer "Create an embed for critical safety warnings"
```

### 2. Template Type
```
/chucky-embed-designer --template [alert|info|success|error|troubleshooting]
```

### 3. Custom Specification
```
/chucky-embed-designer --title "Equipment Analysis" --color red --fields "Category:value|Confidence:value|Description:value"
```

## Discord Embed Structure

Discord embeds have this JSON structure:
```json
{
  "title": "Main heading (max 256 chars)",
  "description": "Main content (max 4096 chars)",
  "url": "Optional clickable link on title",
  "color": 0xFF0000,  // Hex color as integer
  "fields": [
    {
      "name": "Field heading (max 256 chars)",
      "value": "Field content (max 1024 chars)",
      "inline": true  // Display fields side-by-side
    }
  ],
  "thumbnail": {
    "url": "Small image top-right"
  },
  "image": {
    "url": "Large image below content"
  },
  "footer": {
    "text": "Footer text (max 2048 chars)",
    "icon_url": "Small icon next to footer"
  },
  "timestamp": "ISO 8601 timestamp",
  "author": {
    "name": "Author name (max 256 chars)",
    "url": "Optional link",
    "icon_url": "Small icon next to author"
  }
}
```

## Color Schemes

### Status Colors (Standard)
- **Success**: `0x00FF00` (Green) - Resolved issues, positive outcomes
- **Info**: `0x3498DB` (Blue) - General information, tips
- **Warning**: `0xFFAA00` (Orange) - Caution, important notices
- **Error**: `0xFF0000` (Red) - Errors, critical issues, danger
- **Critical**: `0x8B0000` (Dark Red) - Emergency, life-threatening hazards

### Chucky Brand Colors
- **Primary**: `0x2C3E50` (Dark Blue-Gray) - Standard responses
- **Secondary**: `0x34495E` (Gray-Blue) - Neutral information
- **Accent**: `0xE74C3C` (Red) - Attention-grabbing
- **Safety**: `0xF39C12` (Safety Orange) - Safety warnings

### Equipment Category Colors
- **Electrical**: `0xFFD700` (Gold/Yellow) - Electrical systems
- **Mechanical**: `0xC0C0C0` (Silver/Gray) - Mechanical equipment
- **HVAC**: `0x87CEEB` (Sky Blue) - HVAC systems
- **Instrumentation**: `0x9370DB` (Purple) - Sensors, controls

## Standard Embed Templates

### Template 1: Troubleshooting Response
**Use Case**: Main troubleshooting guidance output

```json
{
  "title": "Troubleshooting: [Equipment] - [Symptom]",
  "description": "[Brief overview of the issue]",
  "color": 0x2C3E50,
  "fields": [
    {
      "name": "🔍 Initial Assessment",
      "value": "[Quick diagnostic summary]",
      "inline": false
    },
    {
      "name": "⚠️ Safety First",
      "value": "[Critical safety warnings]",
      "inline": false
    },
    {
      "name": "🔧 Step 1: [First Check]",
      "value": "[Detailed instructions]",
      "inline": false
    },
    {
      "name": "📊 Likely Causes",
      "value": "[Common failure modes]",
      "inline": true
    },
    {
      "name": "⏱️ Est. Time",
      "value": "[Repair duration]",
      "inline": true
    }
  ],
  "footer": {
    "text": "Chucky AI Assistant | Confidence: 88% | Always prioritize safety",
    "icon_url": "https://example.com/chucky-icon.png"
  },
  "timestamp": "2025-11-04T16:00:00Z"
}
```

### Template 2: Safety Alert
**Use Case**: Critical safety warnings

```json
{
  "title": "🚨 CRITICAL SAFETY ALERT",
  "description": "[Immediate hazard description]",
  "color": 0x8B0000,
  "fields": [
    {
      "name": "⚡ Hazard Type",
      "value": "High Voltage / Arc Flash",
      "inline": true
    },
    {
      "name": "🛡️ Required PPE",
      "value": "Arc-rated suit, face shield, insulated gloves",
      "inline": true
    },
    {
      "name": "📋 Procedures Required",
      "value": "• Lockout/Tagout (OSHA 1910.147)\n• Verify zero energy\n• Post warning signs",
      "inline": false
    },
    {
      "name": "📞 Emergency Contact",
      "value": "Site Safety Officer: [extension]",
      "inline": false
    }
  ],
  "footer": {
    "text": "DO NOT PROCEED WITHOUT PROPER AUTHORIZATION AND PPE"
  }
}
```

### Template 3: Equipment Analysis Result
**Use Case**: AI vision analysis output

```json
{
  "title": "Equipment Analysis Complete",
  "description": "I've analyzed the uploaded image",
  "color": 0x3498DB,
  "thumbnail": {
    "url": "[User's uploaded image URL]"
  },
  "fields": [
    {
      "name": "📦 Equipment Type",
      "value": "[Detected category]",
      "inline": true
    },
    {
      "name": "📊 Confidence",
      "value": "[Percentage]%",
      "inline": true
    },
    {
      "name": "📝 Description",
      "value": "[Detailed analysis]",
      "inline": false
    },
    {
      "name": "🏷️ Detected Text",
      "value": "[Extracted nameplate/label text]",
      "inline": false
    },
    {
      "name": "🔑 Keywords",
      "value": "[Comma-separated tags]",
      "inline": false
    }
  ],
  "footer": {
    "text": "Analyzed by Google Gemini Vision AI"
  }
}
```

### Template 4: Clarification Request
**Use Case**: When confidence is low

```json
{
  "title": "🤔 I Need More Information",
  "description": "I analyzed your request but need clarification to provide accurate guidance.",
  "color": 0xFFAA00,
  "fields": [
    {
      "name": "What I Understood",
      "value": "[Partial analysis]",
      "inline": false
    },
    {
      "name": "Confidence Level",
      "value": "[Percentage]% (below 80% threshold)",
      "inline": true
    },
    {
      "name": "❓ Please Provide",
      "value": "1. [Specific info needed]\n2. [Another detail]\n3. [Additional context]",
      "inline": false
    },
    {
      "name": "💡 Tip",
      "value": "For image analysis: Ensure photo is clear, well-lit, and shows equipment nameplate",
      "inline": false
    }
  ],
  "footer": {
    "text": "Reply with additional details and I'll provide better guidance"
  }
}
```

### Template 5: Error Message
**Use Case**: System errors or failures

```json
{
  "title": "⚠️ Oops! Something Went Wrong",
  "description": "I encountered an issue processing your request",
  "color": 0xFF0000,
  "fields": [
    {
      "name": "What Happened",
      "value": "[User-friendly error description]",
      "inline": false
    },
    {
      "name": "What You Can Try",
      "value": "• Retry your request\n• Check image file size (<10MB)\n• Ensure image is JPEG or PNG\n• Try rephrasing your question",
      "inline": false
    },
    {
      "name": "Still Having Issues?",
      "value": "Contact support or try again in a few minutes",
      "inline": false
    }
  ],
  "footer": {
    "text": "Error ID: [execution-id] | Report this if problem persists"
  }
}
```

### Template 6: Search Results Summary
**Use Case**: RAG retrieval results

```json
{
  "title": "📚 Knowledge Base Results",
  "description": "Found relevant information for your query",
  "color": 0x9370DB,
  "fields": [
    {
      "name": "📄 Source 1: [Document Title]",
      "value": "[Relevant excerpt... (max 200 chars)]",
      "inline": false
    },
    {
      "name": "📄 Source 2: [Document Title]",
      "value": "[Relevant excerpt...]",
      "inline": false
    },
    {
      "name": "🔗 Additional Resources",
      "value": "[Links to full manuals if available]",
      "inline": false
    }
  ],
  "footer": {
    "text": "Retrieved from Supabase Vector Store | Similarity: 87%"
  }
}
```

## Emoji Usage Guide

Use emojis to enhance readability and visual hierarchy:

### Status Indicators
- ✅ Success, completed, verified
- ❌ Error, failed, not allowed
- ⚠️ Warning, caution
- 🚨 Critical alert, emergency
- ℹ️ Information, note

### Actions & Tools
- 🔧 Repair, maintenance
- 🔍 Inspect, diagnose
- 🔌 Electrical work
- ⚙️ Mechanical work
- 🧰 Tools required

### Safety & PPE
- ⚡ Electrical hazard
- 🔥 Fire/heat hazard
- 🛡️ PPE required
- 🚫 Prohibited action
- ☣️ Chemical/biological hazard

### Information Categories
- 📦 Equipment/parts
- 📊 Data/measurements
- 📝 Description/details
- 📚 Documentation/reference
- 🏷️ Labels/tags
- ⏱️ Time/duration
- 💰 Cost estimate

### User Interaction
- 🤔 Question/clarification needed
- 💡 Tip/suggestion
- 📞 Contact information
- 👤 User mention

## n8n Discord Node Configuration

To use embeds in n8n Discord nodes:

```json
{
  "parameters": {
    "channel": "={{ $json.channelId }}",
    "content": "{{ $json.mention }}", // Optional text before embed
    "embeds": [
      {
        "title": "={{ $json.embedTitle }}",
        "description": "={{ $json.embedDescription }}",
        "color": "={{ $json.embedColor }}",
        "fields": "={{ $json.embedFields }}",
        "footer": {
          "text": "Chucky AI | Confidence: {{ $json.confidence }}%"
        },
        "timestamp": "={{ $now.toISO() }}"
      }
    ],
    "options": {
      "allowedMentions": {
        "users": ["={{ $json.sessionId }}"]
      }
    }
  },
  "type": "n8n-nodes-base.discord",
  "typeVersion": 2
}
```

## Field Formatting Best Practices

### 1. Inline Fields
Use `inline: true` for related short fields:
```json
{
  "fields": [
    {"name": "Status", "value": "Active", "inline": true},
    {"name": "Priority", "value": "High", "inline": true},
    {"name": "Est. Time", "value": "30 min", "inline": true}
  ]
}
```
Displays as: `Status: Active | Priority: High | Est. Time: 30 min`

### 2. Block Fields
Use `inline: false` for long content:
```json
{
  "fields": [
    {
      "name": "Step 1: Safety Preparation",
      "value": "Apply Lockout/Tagout to all energy sources...",
      "inline": false
    }
  ]
}
```

### 3. Numbered Lists
Use Discord markdown within fields:
```json
{
  "value": "1. First step\n2. Second step\n3. Third step"
}
```

### 4. Bullet Lists
```json
{
  "value": "• First item\n• Second item\n• Third item"
}
```

### 5. Code Blocks
```json
{
  "value": "```\nresistance = 5.2 Ω\nvoltage = 230 V\n```"
}
```

## Character Limits

**IMPORTANT**: Discord enforces these limits:
- Title: 256 characters
- Description: 4096 characters
- Field name: 256 characters
- Field value: 1024 characters
- Footer text: 2048 characters
- Author name: 256 characters
- Total embed: 6000 characters (combined)
- Fields per embed: 25 maximum

## Responsive Design

Consider mobile users:
- Keep field names short (3-8 words)
- Use inline fields sparingly (2-3 max per row)
- Avoid very long descriptions (break into fields instead)
- Test on mobile Discord app

## Accessibility

Make embeds accessible:
- Use descriptive emojis (don't rely solely on color)
- Provide text alternatives for visual indicators
- Use sufficient color contrast
- Don't convey critical info only through color

## Multi-Embed Messages

Discord allows up to 10 embeds per message:
```json
{
  "embeds": [
    { /* First embed - Summary */ },
    { /* Second embed - Detailed steps */ },
    { /* Third embed - Safety warnings */ }
  ]
}
```

## Example: Complete Embed Design

**Request**: "Create an embed for motor troubleshooting with safety warnings"

**Output**:
```json
{
  "title": "🔧 Motor Troubleshooting: Won't Start",
  "description": "Diagnostic guide for 3-phase AC motors (5-50 HP)",
  "url": "https://docs.example.com/motor-troubleshooting",
  "color": 0xFFD700,
  "thumbnail": {
    "url": "https://example.com/motor-icon.png"
  },
  "fields": [
    {
      "name": "🚨 CRITICAL SAFETY - READ FIRST",
      "value": "⚡ **High Voltage Hazard**\n• Apply Lockout/Tagout (OSHA 1910.147)\n• Verify zero energy before touching\n• Wear arc-rated PPE (NFPA 70E)",
      "inline": false
    },
    {
      "name": "📊 Confidence",
      "value": "92%",
      "inline": true
    },
    {
      "name": "⏱️ Est. Time",
      "value": "30-60 min",
      "inline": true
    },
    {
      "name": "🔍 Step 1: Verify Power Supply",
      "value": "1. Check main breaker (should be ON)\n2. Measure voltage at terminals\n3. Expected: 230V ±10% or 480V ±10%",
      "inline": false
    },
    {
      "name": "🔍 Step 2: Test Motor Control",
      "value": "1. Test start button continuity\n2. Check overload relay (reset if tripped)\n3. Listen for contactor click",
      "inline": false
    },
    {
      "name": "🔍 Step 3: Winding Integrity",
      "value": "⚠️ **Disconnect power first**\n1. Measure phase-to-phase resistance (should be equal ±5%)\n2. Measure phase-to-ground (should be >1 MΩ)",
      "inline": false
    },
    {
      "name": "📦 Common Causes",
      "value": "• Tripped breaker → Reset, monitor\n• Failed contactor → Replace (30 min)\n• Phase loss → Check connections\n• Seized bearings → Bearing replacement (2-4 hrs)",
      "inline": false
    },
    {
      "name": "💡 Pro Tip",
      "value": "Document all measurements and findings for maintenance records",
      "inline": false
    }
  ],
  "footer": {
    "text": "Chucky AI Assistant | Confidence: 92% | Source: NFPA 70E, OSHA 1910.333",
    "icon_url": "https://example.com/chucky-small-icon.png"
  },
  "timestamp": "2025-11-04T16:30:00Z"
}
```

## Code Node Integration

Generate embeds dynamically in n8n Code nodes:
```javascript
// Build embed object
const embed = {
  title: `🔧 Troubleshooting: ${$json.equipment} - ${$json.symptom}`,
  description: $json.aiAnalysis,
  color: parseInt($json.confidence) >= 80 ? 0x00FF00 : 0xFFAA00,
  fields: [
    {
      name: "📊 Confidence",
      value: `${$json.confidence}%`,
      inline: true
    },
    {
      name: "⏱️ Est. Time",
      value: $json.estimatedTime,
      inline: true
    }
  ],
  footer: {
    text: `Chucky AI | Confidence: ${$json.confidence}% | ${new Date().toISOString()}`
  },
  timestamp: new Date().toISOString()
};

// Add safety warning if high priority
if ($json.priority === "high") {
  embed.fields.unshift({
    name: "🚨 CRITICAL SAFETY",
    value: $json.safetyWarnings,
    inline: false
  });
}

return { json: { embed: embed } };
```

## Testing Embeds

Before deploying:
1. Test in Discord sandbox channel
2. Verify on mobile and desktop
3. Check all links work
4. Validate character limits
5. Test with long content (truncation behavior)
6. Verify emojis render correctly

## Notes

- Embeds significantly improve user experience vs plain text
- Use consistent styling across all Chucky responses
- Reserve critical colors (red) for actual emergencies
- Balance visual appeal with information density
- Consider creating embed library for reuse
