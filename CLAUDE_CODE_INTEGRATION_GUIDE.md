# Claude Code Integration with Chucky - Complete Implementation Guide

**Date:** 2025-11-03
**Purpose:** Enable Claude Code CLI to autonomously generate and maintain Chucky n8n workflows

---

## Quick Start

### 1. Install Claude Code
```bash
# Visit anthropic.com/claudecode and run installation command
# Then verify installation:
claude --version
```

### 2. Navigate to Project
```bash
cd C:\Users\hharp\chucky_project
```

### 3. Initialize Claude Code
```bash
claude
```

---

## Master Setup Prompt

Copy and paste this entire prompt into Claude Code to initialize the Chucky system:

```
I need you to build a comprehensive AI agent system for managing and extending the "Chucky" industrial maintenance troubleshooting workflow.

PROJECT CONTEXT:
Chucky is an n8n workflow that provides AI-powered troubleshooting assistance for industrial maintenance technicians via Discord. It uses:
- Discord bot for user interaction (command prefix: !)
- Google Gemini Vision AI for equipment image analysis
- Supabase pgvector for RAG (retrieval-augmented generation)
- xAI Grok or Claude for agentic reasoning with ReAct pattern
- Postgres for conversation memory

The current workflow is 25 nodes in an n8n JSON file located at: C:\Users\hharp\chucky_project\ChuckyDiscordRAG.json

CONTEXT FILES:
Read these markdown files in the ./context/ directory to understand the system:
- project_overview.md (system capabilities and architecture)
- workflow_architecture.md (detailed n8n node specifications)

YOUR TASK:
Create a complete Claude Code command structure with custom slash commands and specialized sub-agents that can:

1. SLASH COMMANDS TO CREATE:
   - /chucky-node-builder - Generate new n8n nodes from natural language descriptions
   - /chucky-workflow-validator - Validate n8n workflow JSON for errors and suggest fixes
   - /chucky-doc-generator - Auto-generate documentation when workflows change
   - /chucky-troubleshoot-builder - Create troubleshooting decision trees from equipment manuals
   - /chucky-test-scenario - Generate test scenarios for Discord interactions
   - /chucky-embed-designer - Design Discord embed templates with colors, fields, buttons

2. SUB-AGENTS TO CREATE:
   - n8n-workflow-architect: Reads requirements and generates complete n8n workflows
   - industrial-knowledge-curator: Scrapes and formats industrial documentation for RAG
   - discord-integration-specialist: Configures Discord nodes and message routing
   - documentation-maintainer: Auto-updates setup guides and READMEs
   - testing-coordinator: Creates test plans and validation scripts

3. KEY REQUIREMENTS:
   - All generated n8n nodes must be valid JSON with proper:
     * Node type (e.g., n8n-nodes-base.code, @n8n/n8n-nodes-langchain.agent)
     * Parameters matching n8n schema
     * Position coordinates on grid
     * Connection mappings (main, ai_tool, ai_memory, ai_embedding)
     * Unique node IDs

   - Generated documentation must be markdown format with:
     * Step-by-step instructions
     * Code examples
     * Configuration details
     * Troubleshooting sections

   - Troubleshooting trees must follow this structure:
     * Numbered steps (1, 2, 3...)
     * Safety warnings first (⚠️ symbol)
     * Diagnostic questions
     * Action items with expected outcomes
     * Citations to source manuals

4. INTEGRATION POINTS:
   - Generated nodes should integrate with existing ChuckyDiscordRAG.json
   - Maintain compatibility with current credential structure
   - Follow existing naming conventions (node-type-###)
   - Preserve AI tool connection patterns

5. EXAMPLES OF WHAT YOU'LL GENERATE:

Example /chucky-node-builder usage:
Input: "Create a node that parses HVAC error codes from equipment logs and adds context from manufacturer database"
Output: Complete n8n Code node with JavaScript that:
  - Parses error codes via regex
  - Queries external API for error definitions
  - Formats as structured JSON
  - Includes proper error handling

Example /chucky-troubleshoot-builder usage:
Input: "Build troubleshooting tree for centrifugal pump cavitation based on HVAC maintenance manual chapter 7"
Output: Markdown document with:
  - Initial symptoms checklist
  - Diagnostic flowchart (text-based)
  - Step-by-step resolution procedures
  - Safety warnings (lockout/tagout)
  - Parts list if replacement needed

BUILD THE SYSTEM NOW:
1. Analyze the context files to understand Chucky's architecture
2. Create the .claude/commands/ directory structure
3. Define each slash command as a markdown file
4. Create sub-agent definitions in .claude/agents/
5. Configure each command to use appropriate sub-agents
6. Test one command (/chucky-node-builder) with a sample input

START BY BUILDING THE COMMANDS AND AGENTS. MAKE THEM AUTONOMOUS AND POWERFUL.
```

---

## Context File Summaries

### Industrial Standards Reference

For generating safety-compliant troubleshooting steps, Claude Code sub-agents should reference:

**OSHA Standards (Occupational Safety and Health Administration)**
- 1910.147: Lockout/Tagout procedures
- 1910.333: Electrical safety work practices
- 1910.269: Arc flash boundaries and PPE
- 1910.1200: Hazard communication (chemical safety)

**NFPA Standards (National Fire Protection Association)**
- NFPA 70: National Electrical Code (NEC)
- NFPA 70E: Electrical Safety in the Workplace
- NFPA 110: Emergency Power Systems

**ASME Standards (American Society of Mechanical Engineers)**
- B31.3: Process Piping
- Boiler & Pressure Vessel Code (Section VIII)

**ANSI Standards (American National Standards Institute)**
- Z535: Safety Signs and Colors
- B11: Machine Tool Safety

**When generating troubleshooting steps, always include:**
1. Safety warnings FIRST (⚠️ or 🚨 for critical)
2. Required PPE (Personal Protective Equipment)
3. Lockout/Tagout requirements for electrical/mechanical
4. Proper tool specifications
5. Verification steps after repairs

### Discord Configuration Reference

Current Chucky Discord setup (from DISCORD_SETUP_GUIDE.md modifications):

**Bot Credentials:**
- Bot Token: `YOUR_DISCORD_BOT_TOKEN_HERE`
- Client ID: `1435031220009304084`
- Client Secret: `YOUR_CLIENT_SECRET_HERE`
- Server ID: `1435030211442770002`
- Bot User ID: `1435031220009304084`

**Channel IDs:**
- #equipment-analysis: `1435030487637819602`
- #troubleshooting: `1435030564255170640`
- #maintenance-logs: `1435030623977869452`
- #alerts: `1435030771042746542`
- #search-results: `1435030856698953790`
- #bot-commands: `1435030900957118605`

**Important Security Note:** These credentials are exposed in this file for Claude Code context. In production, these should be stored securely in environment variables or n8n's credential manager.

**Intents Enabled:**
- ✅ Message Content Intent (REQUIRED)
- ✅ Server Members Intent
- ✅ Presence Intent (optional)

**Bot Permissions:**
- Send Messages
- Read Message History
- Embed Links
- Attach Files
- Use Slash Commands
- Manage Messages
- Create/Manage Threads

### Example Troubleshooting Scenarios

**Scenario 1: Motor Won't Start**
```markdown
# Motor Startup Failure Troubleshooting

## Initial Assessment
**Equipment:** 3-Phase AC Motor (5-50 HP typical)
**Symptom:** Motor does not start when energized
**Safety Level:** ⚠️ HIGH (480V/230V electrical hazard)

## Step 1: Safety Preparation
⚠️ **CRITICAL - DO FIRST**
1. Apply Lockout/Tagout to all energy sources
2. Verify zero energy with meter
3. Don PPE: Arc-rated clothing, insulated gloves, face shield
4. Reference: NFPA 70E Section 130.7

## Step 2: Power Supply Verification
1. Check main breaker position (should be ON, not tripped)
2. Verify disconnect switch is closed
3. Measure voltage at motor terminals:
   - Expected: 230V ±10% (207-253V) OR 480V ±10% (432-528V)
   - If low voltage → Check upstream connections
   - If no voltage → Check breaker/fuse continuity

## Step 3: Motor Control Check
1. Test start button/switch:
   - Measure continuity when pressed
   - Should close circuit to motor starter coil
2. Inspect overload relay:
   - Check if tripped (reset button popped out)
   - If tripped repeatedly → Motor overheating or overload
3. Verify contactor operation:
   - Listen for "click" when start button pressed
   - If no click → Control voltage issue or coil failure

## Step 4: Motor Winding Test
⚠️ **LOCKOUT/TAGOUT MUST BE VERIFIED**
1. Disconnect motor from power
2. Use multimeter to test windings:
   - Phase-to-phase resistance: Should be equal (±5%)
   - Phase-to-ground: Should be >1 MΩ (infinite preferred)
   - If open circuit → Winding failure (replace motor)
   - If low resistance to ground → Insulation breakdown (replace)

## Step 5: Mechanical Inspection
1. Attempt to rotate shaft by hand:
   - Should turn freely with some resistance
   - If seized → Bearing failure or coupling issue
2. Check coupling alignment
3. Inspect bearings for excessive play

## Decision Tree
```
Motor won't start
├─ No power at terminals
│  ├─ Breaker tripped → Reset, investigate overload
│  └─ Voltage present at disconnect but not motor → Wiring issue
├─ Power present, contactor won't close
│  ├─ No control voltage → Check fuses, transformer
│  └─ Control voltage OK → Replace contactor
├─ Contactor closes, motor doesn't run
│  ├─ Motor hums but doesn't spin → Capacitor failure (single phase) or phase loss (three phase)
│  └─ No sound → Open winding, replace motor
└─ Motor starts but trips immediately
   └─ Check motor current, compare to nameplate, investigate overload cause
```

## Parts Commonly Needed
- Motor starter contactors (size 0-4 depending on HP)
- Overload relay elements
- Start/run capacitors (single phase motors)
- Thermal overload heaters
- Control transformer fuses

## Expected Resolution Time
- Power issue: 15-30 minutes
- Contactor replacement: 30-60 minutes
- Motor replacement: 2-4 hours (depending on mounting)

## References
- NFPA 70E: Electrical Safety Requirements
- Motor nameplate data
- Equipment manufacturer service manual
```

**Scenario 2: HVAC System Not Cooling**
```markdown
# HVAC Troubleshooting: No Cooling

## Initial Assessment
**Equipment:** Rooftop Air Conditioning Unit (5-50 ton typical)
**Symptom:** System running but not producing cold air
**Safety Level:** ⚠️ MEDIUM (electrical + refrigerant hazards)

## Step 1: Quick Checks
1. Verify thermostat settings:
   - Mode: COOL
   - Temperature set below room temp
   - Fan: AUTO or ON
2. Check main disconnect (should be ON)
3. Observe outdoor unit:
   - Compressor running? (listen for hum)
   - Condenser fan spinning?
   - Any unusual noises?

## Step 2: Electrical Verification
1. Measure supply voltage at unit:
   - Expected: 230V ±10% or 460V ±10%
2. Check control voltage (24V AC):
   - At transformer secondary
   - At thermostat
3. Verify contactor closed when thermostat calls for cooling

## Step 3: Compressor Assessment
⚠️ **De-energize before opening panels**
1. Check capacitor (if equipped):
   - Discharge capacitor with insulated screwdriver
   - Test with capacitance meter
   - Compare to label rating (±6%)
   - If failed (bulging, leaking, low reading) → Replace
2. Test compressor windings:
   - Common to Start: Should show resistance
   - Common to Run: Should show resistance
   - Start to Run: Should show resistance
   - Any open or shorted circuit → Compressor failure

## Step 4: Refrigerant System Check
⚠️ **EPA 608 Certification Required**
1. Check refrigerant pressures:
   - Attach manifold gauges to service ports
   - Compare to manufacturer chart for outdoor temp
   - Low pressure: <60 PSI → Possible leak or restriction
   - High pressure: >350 PSI → Airflow issue or overcharge
2. Look for frost on lines (indicates restriction)

## Step 5: Airflow Verification
1. Check air filters (both return and supply)
   - Replace if dirty/clogged
2. Verify blower operation
3. Inspect evaporator coil for dirt/ice buildup
4. Check for obstructions at outdoor condenser

## Common Causes & Solutions
| Cause | Symptoms | Solution | Time |
|-------|----------|----------|------|
| Dirty filter | Weak airflow, ice on evaporator | Replace filter | 5 min |
| Failed capacitor | Compressor hums but won't start | Replace capacitor | 30 min |
| Low refrigerant | Low suction pressure, warm air | Leak check, repair, recharge | 2-4 hrs |
| Bad contactor | Compressor won't run | Replace contactor | 20 min |
| Seized compressor | No sound, open circuit | Replace compressor | 4-8 hrs |

## Safety Warnings
⚠️ **Refrigerant Hazards:**
- Never release refrigerant to atmosphere (illegal)
- Use proper recovery equipment
- Wear safety glasses (liquid refrigerant causes frostbite)
- Work in ventilated area

⚠️ **Electrical Hazards:**
- Discharge capacitors before touching
- Verify power off with multimeter
- Use insulated tools

## References
- EPA 608 Certification Guidelines
- Refrigerant pressure-temperature charts
- Manufacturer service manual
```

---

## Slash Command Detailed Specifications

### /chucky-node-builder

**Purpose:** Generate n8n node JSON from natural language

**Usage:**
```bash
/chucky-node-builder "Create a Code node that parses pump pressure readings from sensor data and triggers an alert if pressure exceeds 150 PSI"
```

**Sub-Agent:** n8n-workflow-architect

**Output Format:**
```json
{
  "parameters": {
    "jsCode": "// Parse pump pressure sensor data\nconst sensorData = $json.pressure_reading;\nconst threshold = 150; // PSI\n\nif (sensorData > threshold) {\n  return {\n    json: {\n      alert: true,\n      message: `⚠️ PRESSURE ALERT: ${sensorData} PSI exceeds safe limit of ${threshold} PSI`,\n      pressure: sensorData,\n      timestamp: $now.toISO(),\n      action_required: 'Inspect pump immediately'\n    }\n  };\n} else {\n  return {\n    json: {\n      alert: false,\n      pressure: sensorData,\n      status: 'Normal',\n      timestamp: $now.toISO()\n    }\n  };\n}"
  },
  "id": "code-pressure-alert-001",
  "name": "Pump Pressure Alert",
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [1200, 400]
}
```

**Validation Checklist:**
- ✅ Valid node type
- ✅ Proper parameter structure
- ✅ Unique node ID
- ✅ Position coordinates
- ✅ Syntactically correct code
- ✅ Error handling included

---

### /chucky-workflow-validator

**Purpose:** Validate existing n8n workflow JSON

**Usage:**
```bash
/chucky-workflow-validator ChuckyDiscordRAG.json
```

**Sub-Agent:** testing-coordinator

**Validation Checks:**
1. **JSON Syntax**: Valid JSON structure
2. **Node Types**: All node types exist in n8n
3. **Connections**: All connections reference valid nodes
4. **Credentials**: All credential IDs are defined
5. **Required Parameters**: All required params present
6. **Position Conflicts**: No nodes at same coordinates
7. **Circular Dependencies**: No infinite loops

**Output:**
```markdown
# Workflow Validation Report: ChuckyDiscordRAG.json

## Summary
✅ Valid JSON structure
✅ All 25 nodes have valid types
⚠️ 3 warnings found
❌ 1 error found

## Errors
1. **Node: "xAI Grok Model" (xai-grok-001)**
   - Issue: Credential ID "XAI_CREDENTIAL_ID" is a placeholder
   - Fix: Update with actual xAI API credential ID
   - Severity: CRITICAL (workflow will fail)

## Warnings
1. **Node: "Log Error to External Service" (http-log-error-001)**
   - Issue: URL points to "https://your-logging-service.com/errors" (placeholder)
   - Fix: Update with actual logging endpoint
   - Severity: LOW (optional feature)

2. **Connection: "Discord Trigger" → "Extract Message Data"**
   - Issue: No error handling if Discord message is malformed
   - Recommendation: Add try-catch in downstream Code nodes
   - Severity: MEDIUM

3. **Performance: "Iteration Loop" (split-batches-001)**
   - Issue: Batch size of 1 may cause slow processing
   - Recommendation: Increase to 5 if handling multiple items
   - Severity: LOW

## Suggested Fixes
```json
// Update xAI credential (line 234)
"credentials": {
  "xAiApi": {
    "id": "your-actual-xai-credential-id",
    "name": "xAI account"
  }
}
```

## Next Steps
1. Fix critical error (credential ID)
2. Test workflow execution in n8n
3. Monitor for runtime errors
4. Address warnings as needed
```

---

### /chucky-doc-generator

**Purpose:** Auto-generate documentation from workflow changes

**Usage:**
```bash
/chucky-doc-generator ChuckyDiscordRAG.json --compare ChuckyDiscordRAG_old.json
```

**Sub-Agent:** documentation-maintainer

**Output:** Updated markdown files with changelog

---

### /chucky-troubleshoot-builder

**Purpose:** Create troubleshooting decision trees from manuals

**Usage:**
```bash
/chucky-troubleshoot-builder "Centrifugal pump cavitation from HVAC maintenance manual chapter 7"
```

**Sub-Agent:** industrial-knowledge-curator

**Output:** Structured troubleshooting markdown (see examples above)

---

### /chucky-test-scenario

**Purpose:** Generate test scenarios for Discord interactions

**Usage:**
```bash
/chucky-test-scenario "Test image analysis confidence threshold with blurry equipment photo"
```

**Sub-Agent:** testing-coordinator

**Output:**
```markdown
# Test Scenario: Image Analysis Confidence Threshold

## Test ID: TEST-IMG-CONF-001

## Objective
Verify that Chucky asks for clarification when image analysis confidence is below 80%

## Prerequisites
- Chucky workflow active
- Discord bot online
- Gemini Vision API functional

## Test Steps
1. Upload a blurry photo of industrial equipment to #troubleshooting channel
2. Add text: "!troubleshoot motor issue"
3. Wait for Chucky's response (5-15 seconds)

## Test Data
**Image:** blurry_motor_photo.jpg (provided in test_assets/)
**Expected Confidence:** 60-75%

## Expected Result
✅ Chucky responds with clarification request:
```
**Clarification Needed** (<@user>)

I analyzed the image but only have 65% confidence. Can you provide more details?

**What I detected:**
- Category: Electric Motor (possibly 3-phase)
- Description: Motor assembly with visible nameplate, but image quality limits detailed analysis

Please specify:
1. Exact equipment model/type (check nameplate)
2. What specific issue you're experiencing
3. Any error codes or symptoms

Also, if possible, upload a clearer photo focusing on:
- Motor nameplate with specifications
- Any visible damage or abnormalities
```

## Validation Criteria
- ✅ Response within 15 seconds
- ✅ Confidence level mentioned (should be <80%)
- ✅ Request for additional information
- ✅ User mentioned with @username
- ✅ No troubleshooting steps provided (should wait for clarification)

## Failure Modes
❌ If confidence >80% despite blurry image → Gemini Vision may be over-confident, adjust threshold
❌ If no response → Check Discord Trigger activation and network
❌ If error message → Check Gemini API quota and credentials

## Cleanup
No cleanup needed (test message can remain in channel)

## Related Tests
- TEST-IMG-CONF-002: Test with high-quality image (expected confidence >85%)
- TEST-IMG-CONF-003: Test with no equipment in image (expected confidence <50%)
```

---

## Implementation Checklist

### Phase 1: Initial Setup ✅
- [ ] Install Claude Code CLI
- [ ] Navigate to chucky_project directory
- [ ] Create context/ directory with markdown files
- [ ] Run master setup prompt in Claude

### Phase 2: Command Creation (Claude does automatically)
- [ ] /chucky-node-builder created
- [ ] /chucky-workflow-validator created
- [ ] /chucky-doc-generator created
- [ ] /chucky-troubleshoot-builder created
- [ ] /chucky-test-scenario created
- [ ] /chucky-embed-designer created

### Phase 3: Sub-Agent Creation (Claude does automatically)
- [ ] n8n-workflow-architect configured
- [ ] industrial-knowledge-curator configured
- [ ] discord-integration-specialist configured
- [ ] documentation-maintainer configured
- [ ] testing-coordinator configured

### Phase 4: Testing
- [ ] Test /chucky-node-builder with sample input
- [ ] Validate generated node JSON in n8n
- [ ] Test /chucky-workflow-validator with ChuckyDiscordRAG.json
- [ ] Generate sample documentation with /chucky-doc-generator
- [ ] Create test troubleshooting tree

### Phase 5: Integration
- [ ] Use generated nodes in live workflow
- [ ] Set up auto-documentation pipeline
- [ ] Establish testing workflow
- [ ] Monitor and iterate

---

## Success Criteria

**You'll know the integration is working when:**

1. ✅ You can type `/chucky-node-builder "add calculator for pump flow rate"` and get valid n8n JSON
2. ✅ Generated nodes can be imported into n8n without errors
3. ✅ /chucky-workflow-validator catches real issues in workflow
4. ✅ Documentation auto-updates when workflow changes
5. ✅ Troubleshooting trees are comprehensive and safety-compliant
6. ✅ Test scenarios are thorough and executable

---

## Troubleshooting Claude Code Integration

**Issue:** Claude Code doesn't recognize slash commands
**Solution:** Ensure commands are in `.claude/commands/` as markdown files

**Issue:** Sub-agents not activating
**Solution:** Check `.claude/agents/` directory exists and contains agent definitions

**Issue:** Generated nodes have syntax errors
**Solution:** Update n8n-workflow-architect prompt with more examples

**Issue:** Context files not being read
**Solution:** Verify markdown files are in `./context/` relative to where `claude` was launched

---

**Ready to integrate!** Copy the master setup prompt, paste into Claude Code, and watch it build the system automatically.

**Last Updated:** 2025-11-03
**Version:** 1.0
**Integration Status:** Ready for Implementation
