# /chucky - Unified Chucky Management Interface

**Command:** `/chucky`
**Purpose:** Natural language interface for all Chucky n8n workflow operations
**Agent:** chucky-manager
**Model:** sonnet

## Overview

The `/chucky` command provides a unified, natural language interface for managing the Chucky n8n workflow system. Instead of remembering multiple specific commands, you can describe what you want to accomplish in plain English, and the manager agent will route your request to the appropriate specialized sub-agents.

This command wraps the `chucky-manager` agent, providing intelligent routing, session memory, quality validation, and error recovery.

## Usage

```bash
/chucky [your request in natural language]
```

## Core Capabilities

### 1. Natural Language Requests

Simply describe what you want:

```bash
/chucky create a Discord node for equipment failure alerts

/chucky validate the ChuckyDiscordRAG workflow and check for errors

/chucky build a complete temperature monitoring system with tests and docs

/chucky I need help debugging why the Discord triggers aren't firing
```

### 2. Workflow Templates

Pre-configured multi-agent pipelines:

```bash
# Validate workflow for production deployment
/chucky production-ready ChuckyDiscordRAG.json

# Build a complete new feature from scratch
/chucky new-feature "pressure monitoring dashboard"

# Debug and fix workflow issues
/chucky debug ChuckyDiscordRAG.json "Discord messages not sending"

# Prepare workflow for VPS deployment
/chucky deploy-prep ChuckyDiscordRAG.json
```

### 3. Session Memory & Follow-up

The manager remembers your recent work:

```bash
# First request
/chucky create a sensor monitoring node

# Follow-up (manager remembers "it" = sensor node)
/chucky add error handling to it

# Another follow-up
/chucky now generate tests for that node
```

### 4. Individual Command Access

You can still call specialized commands directly:

- `/chucky-node-builder` - Generate n8n nodes
- `/chucky-workflow-validator` - Validate workflows
- `/chucky-doc-generator` - Update documentation
- `/chucky-troubleshoot-builder` - Create troubleshooting guides
- `/chucky-test-scenario` - Generate tests
- `/chucky-embed-designer` - Design Discord embeds

## Examples

### Example 1: Simple Node Creation

**Request:**
```bash
/chucky create a Code node that parses temperature sensor JSON data
```

**What happens:**
1. Manager analyzes intent → "create node"
2. Determines complexity → Simple (single action)
3. Routes to → `n8n-workflow-expert`
4. Auto-executes → Generates node JSON
5. Validates output → Checks structure
6. Returns → Complete node with documentation

**Output:**
```json
{
  "name": "Parse Temperature Data",
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [250, 300],
  "parameters": {
    "mode": "runOnceForEachItem",
    "jsCode": "// Parse temperature sensor JSON\nconst data = $input.item.json;\n// ... parsing logic ..."
  }
}
```

### Example 2: Complete Feature Development

**Request:**
```bash
/chucky new-feature "Safety alert system for critical equipment failures"
```

**What happens:**
1. Manager recognizes → Workflow template
2. Presents plan:
   - Step 1: Design alert workflow nodes [n8n-workflow-expert]
   - Step 2: Configure Discord alerts [discord-integration-specialist]
   - Step 3: Generate test scenarios [testing-coordinator]
   - Step 4: Update documentation [documentation-maintainer]
3. User approves → Executes pipeline
4. Compiles deliverables → Returns complete package

**Output:**
- `safety_alert_nodes.json` - Alert workflow nodes
- `discord_alert_config.json` - Discord embed templates
- `safety_alert_tests.md` - Test scenarios
- `ARCHITECTURE_UPDATE.md` - Updated documentation

### Example 3: Production Readiness Check

**Request:**
```bash
/chucky production-ready ChuckyDiscordRAG.json
```

**What happens:**
1. Manager loads template → "production-ready"
2. Executes pipeline:
   - testing-coordinator → Generate comprehensive tests
   - n8n-workflow-expert → Validate structure
   - testing-coordinator → Security checks
   - documentation-maintainer → Deployment guide
3. Compiles results → Returns complete readiness package

**Output:**
- `test_scenarios.md` - 25 test scenarios
- `validation_report.md` - ✅ 25 nodes validated
- `security_report.md` - ⚠️ 2 warnings about rate limits
- `deployment_guide.md` - Step-by-step deployment checklist

### Example 4: Debugging Assistance

**Request:**
```bash
/chucky debug ChuckyDiscordRAG.json "The bot responds but images aren't being analyzed"
```

**What happens:**
1. Manager analyzes → Debug request with specific symptom
2. Executes debug template:
   - n8n-workflow-expert → Analyzes workflow for image processing issues
   - testing-coordinator → Creates reproduction test case
   - n8n-workflow-expert → Identifies fix (Gemini Vision node misconfigured)
   - n8n-workflow-expert → Implements fix
   - testing-coordinator → Validates fix with test
3. Returns → Analysis + Fix + Test results

**Output:**
- `debug_analysis.md` - Root cause analysis
- `ChuckyDiscordRAG_fixed.json` - Corrected workflow
- `image_analysis_test.md` - Test to verify fix
- `fix_summary.md` - What was changed and why

### Example 5: Documentation Update

**Request:**
```bash
/chucky update the architecture docs to reflect the new temperature monitoring feature
```

**What happens:**
1. Manager analyzes → Documentation update request
2. Determines complexity → Simple (single agent)
3. Routes to → `documentation-maintainer`
4. Auto-executes:
   - Reads current architecture docs
   - Identifies temperature monitoring sections
   - Updates with new feature details
   - Validates markdown formatting
5. Returns → Updated documentation

**Output:**
- `ARCHITECTURE_UPDATED.md` - Updated architecture document
- `CHANGELOG.md` - What was changed

### Example 6: Session Memory in Action

**Conversation flow:**
```bash
You: /chucky create a Discord embed for equipment failure alerts
Manager: [Creates red embed with equipment fields, stores in session]

You: /chucky make it orange instead of red
Manager: [Retrieves from session, changes color, returns updated embed]

You: /chucky add a timestamp field to it
Manager: [Retrieves updated version, adds timestamp, returns final embed]

You: /chucky now create a test scenario for that embed
Manager: [Routes to testing-coordinator with embed context from session]
```

**Session memory persists:**
- Recently created nodes/workflows
- Modified configurations
- User preferences
- Conversation context

## Workflow Templates

### Template: `production-ready`

**Purpose:** Comprehensive validation before production deployment

**Command:**
```bash
/chucky production-ready [workflow.json]
```

**Pipeline:**
1. Generate comprehensive test scenarios
2. Validate workflow structure and configuration
3. Run security and performance checks
4. Create deployment guide and checklist

**Deliverables:**
- Test report with all scenarios
- Validation report (errors, warnings, suggestions)
- Security report (vulnerabilities, best practices)
- Deployment guide (step-by-step instructions)

**Example:**
```bash
/chucky production-ready ChuckyDiscordRAG.json
```

---

### Template: `new-feature`

**Purpose:** Complete feature development from design to documentation

**Command:**
```bash
/chucky new-feature "[feature description]"
```

**Pipeline:**
1. Design feature architecture
2. Build n8n workflow nodes
3. Generate comprehensive tests
4. Update documentation

**Deliverables:**
- Feature node JSON
- Architecture design document
- Test scenarios
- Updated project documentation

**Example:**
```bash
/chucky new-feature "Real-time pressure monitoring with SMS alerts"
```

---

### Template: `debug`

**Purpose:** Troubleshoot and fix workflow issues

**Command:**
```bash
/chucky debug [workflow.json] "[problem description]"
```

**Pipeline:**
1. Analyze workflow for issues
2. Create reproduction test case
3. Implement fixes
4. Validate fixes with tests

**Deliverables:**
- Root cause analysis
- Fixed workflow JSON
- Test cases to prevent regression
- Fix summary and explanation

**Example:**
```bash
/chucky debug ChuckyDiscordRAG.json "Discord triggers not firing"
```

---

### Template: `deploy-prep`

**Purpose:** Prepare workflow for VPS/production deployment

**Command:**
```bash
/chucky deploy-prep [workflow.json]
```

**Pipeline:**
1. Validate all configurations
2. Security and performance audit
3. Create deployment checklist
4. Generate environment setup guide

**Deliverables:**
- Pre-deployment validation report
- Security audit results
- Deployment checklist (step-by-step)
- Environment variable setup guide
- Docker/VPS configuration instructions

**Example:**
```bash
/chucky deploy-prep ChuckyDiscordRAG.json
```

## Routing Logic

The manager agent uses intelligent routing to determine execution strategy:

### Auto-Execute (Simple Requests)
- Single action verb ("create", "validate", "update", "document")
- Single target entity (one node, one workflow)
- No multi-step requirements

**Examples:**
- "Create a webhook trigger node"
- "Validate ChuckyDiscordRAG.json"
- "Document the sensor parsing code"

### Plan First (Complex Requests)
- Multiple action verbs ("create and test and document")
- Multiple target entities
- Cross-cutting concerns (security + performance + testing)

**Examples:**
- "Build a complete monitoring system with alerts"
- "Create a new workflow with Discord integration and testing"
- "Redesign the error handling architecture"

### Templates (Always Show Plan)
- Any workflow template invocation
- Shows full pipeline before execution
- User can approve or modify before proceeding

**Examples:**
- "production-ready ChuckyDiscordRAG.json"
- "new-feature 'temperature monitoring'"
- "debug workflow.json 'errors in Discord sending'"

## Sub-Agent Routing

The manager routes to these specialized agents:

| Sub-Agent | When Invoked | Capabilities |
|-----------|--------------|-------------|
| **n8n-workflow-expert** | Node/workflow building, validation, optimization | Full n8n expertise, 200+ node types |
| **industrial-knowledge-curator** | PDF parsing, documentation extraction | Industrial standards (OSHA, NFPA, ASME) |
| **discord-integration-specialist** | Discord configuration, embed design | Discord bot ID: 1435031220009304084 |
| **documentation-maintainer** | Doc generation, updates, changelogs | Markdown, architecture docs, API docs |
| **testing-coordinator** | Test scenario generation, validation | Unit, integration, E2E, security tests |

## Output Formats

### Success Response

```markdown
## Task Completed: [Brief description]

**What I Did:**
- Analyzed your request for [intent]
- Invoked: [sub-agent-name]
- Validated output: [validation checks]

**Deliverables:**
1. [Primary deliverable]
2. [Secondary deliverable]

**Validation:**
✅ [Check 1]
✅ [Check 2]
✅ [Check 3]

**Next Steps:** [Suggestions for follow-up]
```

### Plan Presentation

```markdown
## Workflow Plan

**Your Request:** [Paraphrased]

**I propose this workflow:**

**Step 1:** [Description]
- Agent: [sub-agent-name]
- Purpose: [What this accomplishes]
- Time: ~X minutes

**Step 2:** [Description]
- Agent: [sub-agent-name]
- Purpose: [What this accomplishes]
- Time: ~X minutes

**Total time:** ~X minutes

**Final Deliverables:**
- [List of what you'll receive]

**Proceed?** [Yes/No]
```

### Error Response

```markdown
## Error Encountered

**What went wrong:**
[Clear explanation]

**What I tried:**
1. [Attempt 1 and failure reason]
2. [Attempt 2 and failure reason]

**Root cause:**
[Technical explanation]

**Recommendations:**
1. [Fix suggestion]
2. [Alternative approach]
3. [Information needed]

**Would you like me to:** [Options]
```

## Tips for Best Results

### Be Specific
✅ Good: "Create a Code node that parses JSON sensor data with error handling"
❌ Vague: "Make a node"

### Use Natural Language
✅ Good: "I need help debugging why Discord messages aren't sending"
❌ Rigid: "Debug Discord send node error"

### Reference Previous Work
✅ Good: "Add validation to that temperature node we just created"
❌ Unclear: "Add validation"

### Use Templates for Common Tasks
✅ Good: `/chucky production-ready workflow.json`
❌ Long: "Validate my workflow, run tests, check security, and create a deployment guide"

### Provide Context for Debugging
✅ Good: "Discord triggers work but image analysis fails with 401 error"
❌ Minimal: "It's broken"

## Troubleshooting

### Manager Not Responding Correctly

**Problem:** Wrong sub-agent invoked or request misunderstood

**Solutions:**
1. Rephrase with more specific action verbs
2. Explicitly name the target (node, workflow, feature)
3. Use individual slash commands for precise control

---

### Session Memory Not Working

**Problem:** Follow-up commands don't recognize references ("it", "that")

**Solutions:**
1. Explicitly name the entity ("validate the temperature monitoring node")
2. Start a new request if session has expired
3. Check what's in session: `/chucky what did we just work on?`

---

### Template Not Executing

**Problem:** Template command not recognized

**Solutions:**
1. Use exact template names: `production-ready`, `new-feature`, `debug`, `deploy-prep`
2. Provide required parameters (workflow file, feature description, etc.)
3. Check command syntax

---

### Output Too Long or Complex

**Problem:** Manager returns overwhelming amount of information

**Solutions:**
1. Ask for summaries: "Give me just the key points"
2. Request specific sections: "Show me only the validation errors"
3. Use simpler commands for focused tasks

## Integration with n8n-MCP

If you have the n8n-MCP server configured, the manager can also:
- Search n8n's 541 documented nodes
- Get node configuration details
- Browse 2,709 workflow templates
- Validate node operations
- (With API key) Create/update workflows directly in n8n

## Advanced Usage

### Chaining Operations

```bash
# The manager can handle multi-step requests in one command
/chucky create a sensor monitoring node, validate it, generate tests, and update the docs
```

The manager will:
1. Present a plan for all 4 steps
2. Wait for your approval
3. Execute each step sequentially
4. Return all deliverables together

### Custom Validation Levels

```bash
# Request thorough validation
/chucky validate ChuckyDiscordRAG.json with thorough security checks

# Quick validation only
/chucky quick validate ChuckyDiscordRAG.json
```

### Iterative Refinement

```bash
# Initial request
/chucky create a Discord embed for alerts

# Refinement 1
/chucky make it use brand colors

# Refinement 2
/chucky add more fields for equipment details

# Refinement 3
/chucky show me the final JSON
```

Each refinement builds on the previous work.

## Performance

- **Simple requests**: < 30 seconds
- **Complex multi-agent workflows**: 2-5 minutes
- **Workflow templates**: 5-10 minutes (comprehensive)
- **Session memory**: Active for current conversation

## Security

The manager enforces security best practices:
- ✅ Never exposes API keys or credentials
- ✅ Validates all inputs before routing to sub-agents
- ✅ Checks for command injection in generated code
- ✅ Warns about security risks
- ✅ Follows OSHA/NFPA safety standards

## Related Commands

- `/chucky-node-builder` - Direct node generation
- `/chucky-workflow-validator` - Direct validation
- `/chucky-doc-generator` - Direct documentation
- `/chucky-troubleshoot-builder` - Industrial troubleshooting guides
- `/chucky-test-scenario` - Test generation
- `/chucky-embed-designer` - Discord embed design

## Context Files

The manager has access to these context files for reference:
- `context/project_overview.md` - System architecture and capabilities
- `context/workflow_architecture.md` - n8n node specifications
- `context/discord_config.md` - Discord configuration

---

## Implementation

This command invokes the `chucky-manager` agent using the Task tool:

```javascript
Task({
  subagent_type: "chucky-manager",
  prompt: `${user_request}`,
  model: "sonnet"
})
```

The manager has full access to:
- All file operations (Read, Write, Edit, Glob, Grep)
- All bash commands (git, npm, docker, etc.)
- All MCP tools (n8n-mcp integration)
- Web search and fetch capabilities

---

**Version:** 1.0.0
**Last Updated:** 2025-11-04
**Maintainer:** Claude Code + User
