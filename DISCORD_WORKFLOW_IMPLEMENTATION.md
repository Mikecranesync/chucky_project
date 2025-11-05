# Discord Workflow Implementation Guide

Complete technical specifications for implementing Discord nodes in the Chucky workflow for industrial maintenance troubleshooting.

## Table of Contents

1. [Discord Trigger Node Configuration](#discord-trigger-node-configuration)
2. [Discord Switch Node Logic](#discord-switch-node-logic)
3. [Rich Embed Templates](#rich-embed-templates)
4. [Character Limit Handling](#character-limit-handling)
5. [Slash Command Configurations](#slash-command-configurations)
6. [Button-Based Workflows](#button-based-workflows)
7. [Thread Management](#thread-management)
8. [Node-by-Node Implementation](#node-by-node-implementation)

---

## Discord Trigger Node Configuration

### Primary Discord Trigger

**Node Type:** Community Discord Trigger (`n8n-nodes-discord`)

**Configuration:**

```json
{
  "name": "Discord Trigger - Main",
  "type": "n8n-nodes-discord-trigger",
  "typeVersion": 1,
  "position": [-2608, 2688],
  "parameters": {
    "events": ["message", "command", "interaction"],
    "channelRestrictions": {
      "enabled": true,
      "channels": [
        "EQUIPMENT_ANALYSIS_CHANNEL_ID",
        "TROUBLESHOOTING_CHANNEL_ID",
        "BOT_COMMANDS_CHANNEL_ID"
      ]
    },
    "messageFilters": {
      "ignoreBot": true,
      "ignoreSelf": true
    }
  },
  "credentials": {
    "discordBotToken": {
      "id": "DISCORD_CREDENTIAL_ID",
      "name": "Chucky Discord Bot"
    }
  }
}
```

**Events to Monitor:**

1. **Message** - Regular text messages and file attachments
2. **Command** - Slash command executions (`/troubleshoot`, `/analyze`, etc.)
3. **Interaction** - Button clicks and select menu interactions

### Channel ID Reference

After creating Discord channels, fill these in:

```javascript
const DISCORD_CHANNELS = {
  EQUIPMENT_ANALYSIS: "INSERT_CHANNEL_ID_HERE",  // #equipment-analysis
  TROUBLESHOOTING: "INSERT_CHANNEL_ID_HERE",     // #troubleshooting
  MAINTENANCE_LOGS: "INSERT_CHANNEL_ID_HERE",    // #maintenance-logs
  ALERTS: "INSERT_CHANNEL_ID_HERE",              // #alerts
  SEARCH_RESULTS: "INSERT_CHANNEL_ID_HERE",      // #search-results
  BOT_COMMANDS: "INSERT_CHANNEL_ID_HERE"         // #bot-commands
};
```

---

## Discord Switch Node Logic

### Switch Node: Message Router

Replaces the existing `Switch1` node to handle Discord message types.

**Node Configuration:**

```json
{
  "name": "Discord Message Router",
  "type": "n8n-nodes-base.switch",
  "typeVersion": 3.2,
  "position": [-2096, 3232],
  "parameters": {
    "rules": {
      "values": [
        {
          "conditions": {
            "combinator": "and",
            "conditions": [
              {
                "leftValue": "={{ $json.type }}",
                "rightValue": "2",
                "operator": {
                  "type": "number",
                  "operation": "equals"
                }
              }
            ]
          }
        },
        {
          "conditions": {
            "combinator": "and",
            "conditions": [
              {
                "leftValue": "={{ $json.type }}",
                "rightValue": "3",
                "operator": {
                  "type": "number",
                  "operation": "equals"
                }
              }
            ]
          }
        },
        {
          "conditions": {
            "combinator": "and",
            "conditions": [
              {
                "leftValue": "={{ $json.attachments[0].content_type }}",
                "rightValue": "image",
                "operator": {
                  "type": "string",
                  "operation": "contains"
                }
              }
            ]
          }
        },
        {
          "conditions": {
            "combinator": "and",
            "conditions": [
              {
                "leftValue": "={{ $json.attachments[0] }}",
                "rightValue": "",
                "operator": {
                  "type": "object",
                  "operation": "exists"
                }
              },
              {
                "leftValue": "={{ $json.attachments[0].content_type }}",
                "rightValue": "image",
                "operator": {
                  "type": "string",
                  "operation": "notContains"
                }
              }
            ]
          }
        },
        {
          "conditions": {
            "combinator": "and",
            "conditions": [
              {
                "leftValue": "={{ $json.content }}",
                "rightValue": "",
                "operator": {
                  "type": "string",
                  "operation": "exists"
                }
              }
            ]
          }
        }
      ]
    }
  }
}
```

### Routing Logic

| Output | Condition | Discord Type | Telegram Equivalent | Next Node |
|--------|-----------|--------------|---------------------|-----------|
| **0** | `type === 2` | Slash Command | N/A | Command Handler |
| **1** | `type === 3` | Button/Select Interaction | N/A | Interaction Handler |
| **2** | `attachments[0].content_type` contains "image" | Image Attachment | `message.photo[0]` | HTTP Request → Download Image |
| **3** | `attachments[0]` exists AND NOT image | Document Attachment | `message.document` | HTTP Request → Download File |
| **4** | `content` exists | Text Message | `message.text` | Edit Fields → AI Agent |

### Discord Event Type Reference

```javascript
// Discord interaction types
const INTERACTION_TYPES = {
  PING: 1,
  APPLICATION_COMMAND: 2,        // Slash commands
  MESSAGE_COMPONENT: 3,          // Buttons, selects
  APPLICATION_COMMAND_AUTOCOMPLETE: 4,
  MODAL_SUBMIT: 5
};

// Message types
const MESSAGE_TYPES = {
  DEFAULT: 0,                    // Regular message
  REPLY: 19,                     // Reply to message
  APPLICATION_COMMAND: 20,       // Slash command result
  THREAD_STARTER_MESSAGE: 21
};
```

---

## Rich Embed Templates

### Template 1: Equipment Analysis Result

**Use Case:** Display Gemini AI analysis of equipment photos

**Code Node:** `Format Discord Equipment Analysis Embed`

```javascript
// Input: Gemini analysis result from previous node
const analysis = $json;

// Color codes
const COLORS = {
  info: 3447003,       // Blue
  success: 3066993,    // Green
  warning: 16776960,   // Yellow
  critical: 15158332   // Red
};

// Determine color based on confidence
let embedColor = COLORS.info;
if (analysis.confidence >= 80) {
  embedColor = COLORS.success;
} else if (analysis.confidence >= 50) {
  embedColor = COLORS.info;
} else {
  embedColor = COLORS.warning;
}

// Format keywords
const keywords = (analysis.keywords || []).join(', ') || 'None detected';

// Format brands
const brands = (analysis.brandLogos || []).join(', ') || 'None detected';

// Format subjects
const subjects = (analysis.mainSubjects || []).join(', ') || 'None detected';

// Build embed
const embed = {
  title: "🔧 Equipment Analysis Complete",
  description: "AI-powered analysis using Google Gemini Vision",
  color: embedColor,
  thumbnail: {
    url: analysis.image_url || ""
  },
  fields: [
    {
      name: "Equipment Type",
      value: analysis.primaryCategory || "Unknown",
      inline: true
    },
    {
      name: "Subcategory",
      value: analysis.subcategory || "N/A",
      inline: true
    },
    {
      name: "Confidence",
      value: `${analysis.confidence}% - ${analysis.confidenceLevel || 'Unknown'}`,
      inline: true
    },
    {
      name: "Description",
      value: (analysis.description || "No description available").substring(0, 1024)
    },
    {
      name: "Detected Components",
      value: subjects.substring(0, 1024)
    },
    {
      name: "Keywords",
      value: keywords.substring(0, 1024),
      inline: true
    },
    {
      name: "Visible Text",
      value: (analysis.extractedText || "None detected").substring(0, 1024),
      inline: true
    },
    {
      name: "Setting",
      value: analysis.setting || "Unknown",
      inline: true
    },
    {
      name: "Time of Day",
      value: analysis.timeOfDay || "Unknown",
      inline: true
    },
    {
      name: "Brand Logos",
      value: brands.substring(0, 1024),
      inline: true
    },
    {
      name: "Industrial Equipment",
      value: analysis.isIndustrial ? "✅ Yes" : "❌ No",
      inline: true
    }
  ],
  footer: {
    text: `Saved to Supabase • ID: ${analysis.photo_id || 'pending'} • Analyzed by Chucky AI`,
    icon_url: "https://i.imgur.com/AfFp7pu.png" // Replace with Chucky logo URL
  },
  timestamp: new Date().toISOString()
};

// Action recommendations if issues detected
if (analysis.detectedIssues && analysis.detectedIssues.length > 0) {
  embed.fields.push({
    name: "⚠️ Detected Issues",
    value: analysis.detectedIssues.join('\n')
  });
}

return {
  json: {
    channelId: $('Discord Trigger - Main').item.json.channel_id,
    messageType: "embed",
    embeds: [embed],
    components: [
      {
        type: 1, // Action Row
        components: [
          {
            type: 2, // Button
            style: 1, // Primary (blue)
            label: "View in Database",
            custom_id: `view_db_${analysis.photo_id}`
          },
          {
            type: 2,
            style: 2, // Secondary (gray)
            label: "Edit Category",
            custom_id: `edit_category_${analysis.photo_id}`
          },
          {
            type: 2,
            style: 3, // Success (green)
            label: "Generate Report",
            custom_id: `generate_report_${analysis.photo_id}`
          }
        ]
      }
    ]
  }
};
```

### Template 2: Search Results

**Use Case:** Display SerpAPI or RAG search results

**Code Node:** `Format Discord Search Results`

```javascript
const searchResults = $json;
const query = searchResults.search_parameters?.q || "Unknown query";
const results = searchResults.organic_results || [];

// Build fields for top 5 results
const fields = results.slice(0, 5).map((result, index) => {
  const emoji = ['1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣'][index];
  return {
    name: `${emoji} ${result.title}`,
    value: `[Click to view](${result.link})\n${(result.snippet || '').substring(0, 200)}...`
  };
});

const embed = {
  title: "🔍 Search Results",
  description: `**Query:** ${query}\n**Found:** ${results.length} results`,
  color: 3447003, // Blue
  fields: fields,
  footer: {
    text: "Powered by SerpAPI • Showing top 5 results"
  },
  timestamp: new Date().toISOString()
};

return {
  json: {
    channelId: $('Discord Trigger - Main').item.json.channel_id,
    messageType: "embed",
    embeds: [embed],
    components: [
      {
        type: 1,
        components: [
          {
            type: 2,
            style: 2,
            label: "Show More Results",
            custom_id: "more_results"
          },
          {
            type: 2,
            style: 2,
            label: "Refine Search",
            custom_id: "refine_search"
          }
        ]
      }
    ]
  }
};
```

### Template 3: Safety Alert (Critical)

**Use Case:** Critical safety issues detected by AI

**Code Node:** `Format Discord Safety Alert`

```javascript
const alert = $json;

const embed = {
  title: "🚨 CRITICAL SAFETY ALERT",
  description: "**IMMEDIATE ACTION REQUIRED**",
  color: 15158332, // Red
  fields: [
    {
      name: "Equipment",
      value: alert.equipment_id || "Unknown",
      inline: true
    },
    {
      name: "Location",
      value: alert.location || "Unknown",
      inline: true
    },
    {
      name: "Severity",
      value: "🔴 CRITICAL",
      inline: true
    },
    {
      name: "Issue Detected",
      value: alert.safety_issue || "Unknown safety issue"
    },
    {
      name: "Required Actions",
      value: (alert.actions || ["Investigate immediately"]).map((action, i) => `${i+1}. ${action}`).join('\n')
    },
    {
      name: "Detection Method",
      value: `AI Image Analysis (${alert.confidence || 0}% confidence)`
    }
  ],
  image: {
    url: alert.evidence_image_url || ""
  },
  footer: {
    text: "Auto-detected by Chucky AI • Report to safety officer immediately"
  },
  timestamp: new Date().toISOString()
};

return {
  json: {
    channelId: process.env.DISCORD_ALERTS_CHANNEL_ID,
    content: "@here", // Mention everyone
    messageType: "embed",
    embeds: [embed],
    components: [
      {
        type: 1,
        components: [
          {
            type: 2,
            style: 4, // Danger (red)
            label: "Confirm Lockout/Tagout",
            custom_id: `confirm_lockout_${alert.alert_id}`
          },
          {
            type: 2,
            style: 1, // Primary (blue)
            label: "Dispatch Emergency Tech",
            custom_id: `dispatch_emergency_${alert.alert_id}`
          },
          {
            type: 2,
            style: 2, // Secondary (gray)
            label: "False Alarm - Override",
            custom_id: `false_alarm_${alert.alert_id}`
          }
        ]
      }
    ]
  }
};
```

### Template 4: Error Notification

**Use Case:** Workflow execution errors

**Code Node:** `Format Discord Error Embed`

```javascript
const error = $('Error Trigger').item.json.execution?.error || {};

const embed = {
  title: "⚠️ Workflow Error",
  description: "An error occurred during workflow execution",
  color: 16776960, // Yellow
  fields: [
    {
      name: "Error Message",
      value: `\`\`\`${(error.message || 'Unknown error').substring(0, 900)}\`\`\``
    },
    {
      name: "Error Type",
      value: error.name || "Unknown",
      inline: true
    },
    {
      name: "Failed Node",
      value: error.node || "Unknown",
      inline: true
    },
    {
      name: "Execution ID",
      value: $('Error Trigger').item.json.execution?.id || "Unknown",
      inline: true
    },
    {
      name: "Timestamp",
      value: new Date().toISOString()
    }
  ],
  footer: {
    text: "Check n8n logs for detailed stack trace"
  }
};

return {
  json: {
    channelId: process.env.DISCORD_MAINTENANCE_LOGS_CHANNEL_ID,
    messageType: "embed",
    embeds: [embed],
    components: [
      {
        type: 1,
        components: [
          {
            type: 2,
            style: 2,
            label: "View Full Logs",
            custom_id: `view_logs_${$('Error Trigger').item.json.execution?.id}`
          },
          {
            type: 2,
            style: 1,
            label: "Retry Workflow",
            custom_id: "retry_workflow"
          }
        ]
      }
    ]
  }
};
```

---

## Character Limit Handling

### Code Node: Discord Output Limiter

Replaces the existing `Code6` node that handles Telegram's 4096 character limit.

**Node Name:** `Discord Character Limit Handler`

```javascript
// Input: AI Agent output or long text content
let output = $json.output || $json.text || $json.message || "";

// Discord limits
const MESSAGE_LIMIT = 2000;
const EMBED_DESCRIPTION_LIMIT = 4096;
const EMBED_FIELD_VALUE_LIMIT = 1024;
const TOTAL_EMBED_LIMIT = 6000;

// Decide whether to use embed or regular message
const useEmbed = output.length > MESSAGE_LIMIT;

if (useEmbed) {
  // Use embed for longer content
  if (output.length > EMBED_DESCRIPTION_LIMIT) {
    output = output.substring(0, EMBED_DESCRIPTION_LIMIT - 50) + '...\n\n[Content truncated due to length]';
  }

  return {
    json: {
      messageType: "embed",
      channelId: $('Discord Trigger - Main').item.json.channel_id,
      embeds: [{
        description: output,
        color: 3447003, // Blue
        footer: {
          text: "Response from Chucky AI"
        },
        timestamp: new Date().toISOString()
      }]
    }
  };
} else {
  // Use regular message for shorter content
  if (output.length > MESSAGE_LIMIT) {
    output = output.substring(0, MESSAGE_LIMIT - 50) + '...\n\n[Content truncated due to length]';
  }

  return {
    json: {
      messageType: "message",
      channelId: $('Discord Trigger - Main').item.json.channel_id,
      content: output
    }
  };
}
```

### Code Node: Split Long Messages

For very long content, split into multiple messages or embed fields.

```javascript
const content = $json.output || $json.text || "";
const CHUNK_SIZE = 1900; // Leave room for formatting

// Split content into chunks
const chunks = [];
for (let i = 0; i < content.length; i += CHUNK_SIZE) {
  chunks.push(content.substring(i, i + CHUNK_SIZE));
}

// Return array of messages
return chunks.map((chunk, index) => ({
  json: {
    messageType: "message",
    channelId: $('Discord Trigger - Main').item.json.channel_id,
    content: `**Part ${index + 1} of ${chunks.length}:**\n\n${chunk}`
  }
}));
```

---

## Slash Command Configurations

### Command 1: /troubleshoot

**Purpose:** Initiate equipment troubleshooting workflow

**Discord Trigger Configuration:**

```json
{
  "eventType": "command",
  "commandName": "troubleshoot",
  "commandDescription": "Start equipment troubleshooting workflow",
  "options": [
    {
      "name": "equipment",
      "description": "Equipment ID or type (e.g., 'Motor-Pump-A23' or 'HVAC')",
      "type": 3,
      "required": true
    },
    {
      "name": "issue",
      "description": "Brief description of the issue",
      "type": 3,
      "required": true
    }
  ]
}
```

**Response Handler Code Node:**

```javascript
const interaction = $json;
const equipment = interaction.data.options.find(opt => opt.name === "equipment")?.value || "Unknown";
const issue = interaction.data.options.find(opt => opt.name === "issue")?.value || "Unknown issue";

// Acknowledge interaction immediately (Discord 3-second rule)
return {
  json: {
    interactionId: interaction.id,
    interactionToken: interaction.token,
    type: 4, // CHANNEL_MESSAGE_WITH_SOURCE
    data: {
      embeds: [{
        title: "⚙️ Starting Troubleshooting Workflow",
        description: `**Equipment:** ${equipment}\n**Issue:** ${issue}\n\nInitializing diagnostic wizard...`,
        color: 3447003,
        footer: {
          text: "Please wait while Chucky analyzes the equipment..."
        }
      }]
    }
  }
};
```

### Command 2: /analyze

**Purpose:** Analyze uploaded equipment photo

```json
{
  "eventType": "command",
  "commandName": "analyze",
  "commandDescription": "Analyze equipment photo with AI",
  "options": [
    {
      "name": "image",
      "description": "Upload equipment photo",
      "type": 11,
      "required": true
    },
    {
      "name": "equipment_id",
      "description": "Optional equipment ID for logging",
      "type": 3,
      "required": false
    }
  ]
}
```

### Command 3: /inspect

**Purpose:** Start safety inspection checklist

```json
{
  "eventType": "command",
  "commandName": "inspect",
  "commandDescription": "Start equipment safety inspection",
  "options": [
    {
      "name": "type",
      "description": "Inspection type",
      "type": 3,
      "required": true,
      "choices": [
        { "name": "Electrical Panels", "value": "electrical_panels" },
        { "name": "HVAC Systems", "value": "hvac" },
        { "name": "Mechanical Equipment", "value": "mechanical" },
        { "name": "Safety Equipment", "value": "safety" },
        { "name": "General Walkthrough", "value": "general" }
      ]
    },
    {
      "name": "area",
      "description": "Location or area being inspected",
      "type": 3,
      "required": false
    }
  ]
}
```

### Command 4: /status

**Purpose:** Check equipment maintenance status

```json
{
  "eventType": "command",
  "commandName": "status",
  "commandDescription": "Check equipment maintenance history and status",
  "options": [
    {
      "name": "equipment_id",
      "description": "Equipment ID to look up",
      "type": 3,
      "required": true
    }
  ]
}
```

**Response Handler Code Node:**

```javascript
const interaction = $json;
const equipmentId = interaction.data.options.find(opt => opt.name === "equipment_id")?.value || "Unknown";

// Query Supabase for equipment status (connect to Supabase node)
// For now, return placeholder response

return {
  json: {
    interactionId: interaction.id,
    interactionToken: interaction.token,
    type: 4,
    data: {
      embeds: [{
        title: `📊 Equipment Status: ${equipmentId}`,
        description: "Retrieving maintenance history...",
        color: 3066993,
        fields: [
          {
            name: "Status",
            value: "⏳ Looking up equipment...",
            inline: true
          }
        ]
      }]
    },
    passToSupabaseQuery: {
      equipmentId: equipmentId
    }
  }
};
```

### Slash Command Option Types Reference

```javascript
const COMMAND_OPTION_TYPES = {
  SUB_COMMAND: 1,
  SUB_COMMAND_GROUP: 2,
  STRING: 3,
  INTEGER: 4,
  BOOLEAN: 5,
  USER: 6,
  CHANNEL: 7,
  ROLE: 8,
  MENTIONABLE: 9,
  NUMBER: 10,
  ATTACHMENT: 11
};
```

---

## Button-Based Workflows

### Workflow 1: Equipment Troubleshooting Decision Tree

**Initial Button Prompt:**

**Code Node:** `Create Troubleshooting Buttons`

```javascript
const equipment = $json.equipment || "Unknown";
const issue = $json.issue || "Unknown issue";

return {
  json: {
    channelId: $json.channel_id,
    messageType: "buttonPrompt",
    prompt: {
      title: "⚙️ Motor Troubleshooting Wizard",
      description: `**Equipment:** ${equipment}\n**Issue:** ${issue}\n\nLet's diagnose the problem step by step. Choose a diagnostic test to begin:`,
      color: 3447003,
      buttons: [
        {
          label: "Check Power Supply",
          value: "check_power",
          style: "primary"
        },
        {
          label: "Check Motor Rotation",
          value: "check_rotation",
          style: "primary"
        },
        {
          label: "Inspect Connections",
          value: "inspect_connections",
          style: "primary"
        },
        {
          label: "Test Capacitor",
          value: "test_capacitor",
          style: "primary"
        },
        {
          label: "View Wiring Diagram",
          value: "view_diagram",
          style: "secondary"
        }
      ]
    },
    restrictToUser: true,
    timeout: 0
  }
};
```

**Button Interaction Handler:**

**Code Node:** `Handle Troubleshooting Button Click`

```javascript
const interaction = $json;
const selectedOption = interaction.data.custom_id;

// Define responses for each button
const responses = {
  "check_power": {
    title: "🔌 Power Supply Check",
    description: "Let's verify the power supply to your equipment.",
    color: 3447003,
    fields: [
      {
        name: "Step 1: Check Main Breaker",
        value: "Locate the main breaker panel and verify the breaker is in the ON position (not tripped)."
      },
      {
        name: "Step 2: Check Disconnect Switch",
        value: "Verify the disconnect switch near the equipment is closed (handle down)."
      },
      {
        name: "Step 3: Measure Voltage",
        value: "Using a multimeter, measure voltage at the equipment terminals.\n**Expected:** 230V ±10% (207-253V)\n**Danger:** Ensure proper lockout/tagout before accessing terminals!"
      }
    ],
    buttons: [
      { label: "✓ Power OK", value: "power_ok", style: "success" },
      { label: "✗ No Power", value: "no_power", style: "danger" },
      { label: "⚠️ Low Voltage", value: "low_voltage", style: "primary" },
      { label: "📷 Upload Multimeter Photo", value: "upload_voltage_photo", style: "secondary" }
    ]
  },
  "check_rotation": {
    title: "🔄 Motor Rotation Check",
    description: "Verify motor rotation direction",
    color: 3447003,
    fields: [
      {
        name: "Step 1: Mark Shaft",
        value: "Using a marker or tape, mark the motor shaft for rotation direction visibility."
      },
      {
        name: "Step 2: Bump Start",
        value: "**Warning:** Ensure area is clear!\nBriefly energize motor (0.5 seconds) and observe rotation direction."
      },
      {
        name: "Step 3: Verify Direction",
        value: "Motor should rotate in direction indicated by arrow on motor housing.\nWrong rotation = reversed phase wiring."
      }
    ],
    buttons: [
      { label: "✓ Correct Rotation", value: "rotation_correct", style: "success" },
      { label: "✗ Wrong Direction", value: "rotation_wrong", style: "danger" },
      { label: "Motor Won't Start", value: "wont_start", style: "primary" }
    ]
  },
  "inspect_connections": {
    title: "🔧 Connection Inspection",
    description: "Inspect electrical connections",
    color: 16776960,
    fields: [
      {
        name: "⚠️ Safety Warning",
        value: "**LOCKOUT/TAGOUT REQUIRED**\nDe-energize equipment before inspecting connections!"
      },
      {
        name: "Check Points",
        value: "1. Terminal tightness (use torque wrench if available)\n2. Wire condition (no fraying, burns, or damage)\n3. Overheating signs (discoloration, melted insulation)\n4. Corrosion on terminals"
      }
    ],
    buttons: [
      { label: "✓ All Connections OK", value: "connections_ok", style: "success" },
      { label: "Found Loose Connection", value: "loose_connection", style: "danger" },
      { label: "Found Damaged Wire", value: "damaged_wire", style: "danger" },
      { label: "📷 Upload Photo", value: "upload_connection_photo", style: "secondary" }
    ]
  },
  "no_power": {
    title: "⚡ No Power Detected",
    description: "Equipment has no power supply",
    color: 15158332,
    fields: [
      {
        name: "Recommended Actions",
        value: "1. Check if breaker is tripped → Reset if safe\n2. Inspect disconnect switch → Close if open\n3. Check for blown fuses → Replace if needed\n4. If breaker trips repeatedly → **Call electrician**"
      },
      {
        name: "Next Steps",
        value: "Select an action below:"
      }
    ],
    buttons: [
      { label: "Reset Breaker", value: "reset_breaker", style: "primary" },
      { label: "Call Electrician", value: "call_electrician", style: "danger" },
      { label: "Document Issue", value: "document_no_power", style: "secondary" }
    ]
  },
  "loose_connection": {
    title: "✅ Issue Identified: Loose Connection",
    description: "A loose electrical connection was found",
    color: 3066993,
    fields: [
      {
        name: "Resolution Steps",
        value: "1. Ensure equipment is de-energized (locked out)\n2. Tighten connection using proper torque\n3. Verify all other connections\n4. Re-energize and test equipment\n5. Document repair in maintenance log"
      },
      {
        name: "Documentation",
        value: "Would you like to log this repair?"
      }
    ],
    buttons: [
      { label: "Log to Maintenance System", value: "log_repair", style: "success" },
      { label: "Generate Work Order", value: "generate_wo", style: "primary" },
      { label: "Close Issue", value: "close_issue", style: "secondary" }
    ]
  }
};

const response = responses[selectedOption] || {
  title: "Unknown Option",
  description: "Invalid selection",
  color: 15158332,
  fields: [],
  buttons: []
};

return {
  json: {
    interactionId: interaction.id,
    interactionToken: interaction.token,
    type: 7, // UPDATE_MESSAGE
    data: {
      embeds: [{
        title: response.title,
        description: response.description,
        color: response.color,
        fields: response.fields,
        footer: {
          text: "Chucky Troubleshooting Assistant"
        },
        timestamp: new Date().toISOString()
      }],
      components: response.buttons.length > 0 ? [{
        type: 1,
        components: response.buttons.map(btn => ({
          type: 2,
          style: btn.style === "primary" ? 1 : btn.style === "secondary" ? 2 : btn.style === "success" ? 3 : 4,
          label: btn.label,
          custom_id: btn.value
        }))
      }] : []
    }
  }
};
```

### Button Style Reference

```javascript
const BUTTON_STYLES = {
  PRIMARY: 1,    // Blurple
  SECONDARY: 2,  // Gray
  SUCCESS: 3,    // Green
  DANGER: 4,     // Red
  LINK: 5        // URL button
};
```

---

## Thread Management

### Code Node: Create Troubleshooting Thread

**Purpose:** Create a dedicated thread for equipment troubleshooting to keep conversations organized.

```javascript
const interaction = $json;
const equipment = interaction.data.options.find(opt => opt.name === "equipment")?.value || "Unknown";
const issue = interaction.data.options.find(opt => opt.name === "issue")?.value || "Unknown";

// Generate thread name (max 100 characters)
const threadName = `${equipment} - ${issue}`.substring(0, 95) + " [OPEN]";

return {
  json: {
    channelId: interaction.channel_id,
    threadName: threadName,
    autoArchiveDuration: 1440, // Archive after 24 hours of inactivity
    message: {
      embeds: [{
        title: "🧵 Troubleshooting Thread Created",
        description: `Equipment: **${equipment}**\nIssue: **${issue}**\n\nAll diagnostic steps will be tracked in this thread.`,
        color: 3447003,
        footer: {
          text: "Thread will auto-archive after 24 hours of inactivity"
        }
      }]
    },
    equipment: equipment,
    issue: issue
  }
};
```

### Discord Send Node: Create Thread

**Node Type:** Community Discord (`n8n-nodes-discord`)
**Operation:** Channel → Create Thread

```json
{
  "resource": "channel",
  "operation": "createThread",
  "channelId": "={{ $json.channelId }}",
  "name": "={{ $json.threadName }}",
  "autoArchiveDuration": "={{ $json.autoArchiveDuration }}",
  "type": 11,
  "message": "={{ $json.message }}"
}
```

### Code Node: Close Thread When Resolved

```javascript
const threadId = $json.thread_id;
const resolution = $json.resolution || "Issue resolved";

return {
  json: {
    threadId: threadId,
    archived: true,
    locked: false,
    finalMessage: {
      embeds: [{
        title: "✅ Issue Resolved",
        description: resolution,
        color: 3066993,
        fields: [
          {
            name: "Resolution Time",
            value: new Date().toLocaleString()
          },
          {
            name: "Status",
            value: "Thread archived. Can be reopened if needed."
          }
        ]
      }]
    }
  }
};
```

---

## Node-by-Node Implementation

### Complete Node Flow

```
Discord Trigger - Main
  │
  ├─ Discord Message Router (Switch)
  │   │
  │   ├─ Output 0: Slash Command
  │   │   └─ Command Handler (Switch by command name)
  │   │       ├─ /troubleshoot → Create Thread → Initial Button Prompt
  │   │       ├─ /analyze → Extract Attachment → Download → Gemini Analysis
  │   │       ├─ /inspect → Inspection Checklist Generator
  │   │       └─ /status → Supabase Query → Format Status Embed
  │   │
  │   ├─ Output 1: Button/Select Interaction
  │   │   └─ Interaction Router (Switch by custom_id prefix)
  │   │       ├─ check_power, check_rotation, etc → Troubleshooting Flow
  │   │       ├─ log_repair, generate_wo → Maintenance Logging
  │   │       └─ view_db, edit_category → Database Operations
  │   │
  │   ├─ Output 2: Image Attachment
  │   │   └─ HTTP Request (Download) → Code (Extract URL) → Gemini Analysis → Format Equipment Embed → Discord Send
  │   │
  │   ├─ Output 3: Document Attachment
  │   │   └─ HTTP Request (Download) → File Processing → Upload to Storage
  │   │
  │   └─ Output 4: Text Message
  │       └─ Edit Fields → Chucky's Brain (AI Agent) → Discord Character Limiter → Discord Send
```

### Node Replacement Map

| Old Telegram Node | New Discord Node | Changes |
|-------------------|------------------|---------|
| Chucky Telegram Trigger | Discord Trigger - Main | Add command/interaction events |
| Switch1 | Discord Message Router | Update conditions for Discord message structure |
| Telegram2 (get photo) | HTTP Request | Download from attachment URL directly |
| Get a file (document) | HTTP Request | Download from attachment URL directly |
| Chucky's Voice | Discord Send (Button Prompt) | Add interactive buttons |
| Send a text message (search) | Discord Send (Embed) | Format as rich embed |
| Send a text message1 (error) | Discord Send (Embed) | Color-coded error embed |
| Send a text message2 | Discord Send (Message/Embed) | Based on content length |
| Code6 (character limit) | Discord Character Limiter | Adjust for 2000/4096 limits |

### New Nodes to Add

1. **Command Handler (Switch)** - Routes slash commands by name
2. **Interaction Router (Switch)** - Routes button clicks by custom_id
3. **Create Thread Node** - Creates Discord threads for troubleshooting
4. **Format Equipment Embed** - Builds rich embed for analysis results
5. **Format Search Embed** - Builds rich embed for search results
6. **Format Safety Alert** - Builds critical safety alert embed
7. **Troubleshooting Button Generator** - Creates initial diagnostic buttons
8. **Button Interaction Handler** - Processes button clicks and updates messages

---

## Environment Variables

Add these to your n8n environment or workflow settings:

```bash
# Discord Channel IDs
DISCORD_EQUIPMENT_ANALYSIS_CHANNEL_ID=INSERT_CHANNEL_ID
DISCORD_TROUBLESHOOTING_CHANNEL_ID=INSERT_CHANNEL_ID
DISCORD_MAINTENANCE_LOGS_CHANNEL_ID=INSERT_CHANNEL_ID
DISCORD_ALERTS_CHANNEL_ID=INSERT_CHANNEL_ID
DISCORD_SEARCH_RESULTS_CHANNEL_ID=INSERT_CHANNEL_ID
DISCORD_BOT_COMMANDS_CHANNEL_ID=INSERT_CHANNEL_ID

# Discord Bot
DISCORD_BOT_TOKEN=YOUR_BOT_TOKEN_HERE
DISCORD_APPLICATION_ID=YOUR_APPLICATION_ID_HERE

# Optional: Discord webhook for errors
DISCORD_ERROR_WEBHOOK_URL=https://discord.com/api/webhooks/...
```

---

## Testing Checklist

### Phase 1: Basic Connectivity
- [ ] Discord bot appears online in server
- [ ] Bot can send simple message to #bot-commands
- [ ] Bot responds to @mentions
- [ ] Embed messages display correctly

### Phase 2: Message Routing
- [ ] Text messages route to AI Agent
- [ ] Image uploads trigger Gemini analysis
- [ ] Document uploads are downloaded correctly
- [ ] Unknown message types are handled gracefully

### Phase 3: Slash Commands
- [ ] /troubleshoot command appears in Discord
- [ ] /analyze accepts image upload
- [ ] /inspect shows inspection type choices
- [ ] /status queries equipment correctly
- [ ] Commands respond within 3 seconds

### Phase 4: Interactive Features
- [ ] Initial troubleshooting buttons display
- [ ] Button clicks update message correctly
- [ ] Multiple button interactions work in sequence
- [ ] Persistent buttons remain after workflow completes

### Phase 5: Threads
- [ ] Troubleshooting creates new thread
- [ ] Messages post to correct thread
- [ ] Threads archive after resolution
- [ ] Thread names are descriptive

### Phase 6: Embeds
- [ ] Equipment analysis embed shows all fields
- [ ] Search results embed formats links correctly
- [ ] Safety alerts use correct red color
- [ ] Error embeds include stack trace
- [ ] Thumbnail images display

### Phase 7: Parallel Operation
- [ ] Both Telegram and Discord trigger simultaneously
- [ ] No cross-contamination between platforms
- [ ] Each platform receives appropriate formatting
- [ ] Performance remains acceptable

---

## Next Steps After Implementation

1. **User Training**
   - Create slash command quick reference
   - Document button interaction workflows
   - Explain thread usage

2. **Monitoring**
   - Track slash command usage
   - Monitor button interaction success rate
   - Analyze response times

3. **Iteration**
   - Gather user feedback
   - Refine button workflows based on usage
   - Add new slash commands as needed

4. **Migration Completion**
   - Evaluate Discord adoption rate
   - Plan Telegram deprecation timeline
   - Archive Telegram nodes when ready

---

## Resources

- **Discord Developer Portal:** https://discord.com/developers/applications
- **Discord API Docs:** https://discord.com/developers/docs/intro
- **Interaction Types:** https://discord.com/developers/docs/interactions/receiving-and-responding
- **Embed Builder Tool:** https://autocode.com/tools/discord/embed-builder/
- **Community Node GitHub:** https://github.com/edbrdi/n8n-nodes-discord

---

**Document Version:** 1.0
**Last Updated:** 2025-11-03
**Author:** Claude AI
**Project:** Chucky Discord Migration
