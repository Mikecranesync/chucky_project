# Chucky Manager - User Guide

**Quick Start Guide for the Unified n8n Workflow Management System**

Version: 1.0.0
Last Updated: 2025-11-04

---

## What is Chucky Manager?

Chucky Manager is your **single point of contact** for managing the entire Chucky n8n workflow system. Instead of remembering multiple commands or manually coordinating different tasks, you simply describe what you want in natural language, and the manager handles everything.

Think of it as a project manager that:
- Understands what you need
- Routes work to the right specialists
- Remembers your conversation context
- Validates outputs for quality
- Handles errors gracefully

---

## Quick Start (5 Minutes)

### Step 1: Verify Installation

Open Claude Code CLI and check that everything's set up:

```bash
# Check you're in the project directory
pwd
# Should show: C:\Users\hharp\chucky_project

# Verify manager agent exists
ls .claude/agents/chucky-manager.md

# Verify command exists
ls .claude/commands/chucky.md
```

### Step 2: Your First Command

Try a simple request:

```bash
/chucky create a Code node that parses temperature sensor JSON data
```

You should get:
- A complete n8n node JSON
- Validation confirmation
- Usage instructions

**That's it!** You're ready to use the manager.

---

## How It Works

### The Magic Behind the Scenes

When you type `/chucky [request]`, here's what happens:

```
Your Request
    ↓
Manager Analyzes Intent
    ↓
Determines Complexity
    ├─ Simple? → Auto-execute
    └─ Complex? → Show plan, wait for approval
    ↓
Routes to Specialist(s)
    ├─ n8n-workflow-expert (nodes, workflows)
    ├─ industrial-knowledge-curator (PDF docs)
    ├─ discord-integration-specialist (Discord config)
    ├─ documentation-maintainer (docs)
    └─ testing-coordinator (tests)
    ↓
Validates Output
    ↓
Returns Result to You
```

### Session Memory

The manager remembers your recent work:

```bash
# Create something
/chucky create a Discord embed for equipment alerts

# Modify it (manager remembers "it")
/chucky make it orange instead of blue

# Test it (manager remembers what "it" is)
/chucky generate tests for it
```

No need to repeat yourself!

---

## Common Use Cases

### 1. Create a Single Node

**When:** You need one specific n8n node

**Example:**
```bash
/chucky create a webhook trigger node for Discord messages
```

**What Happens:** Auto-executes, returns node JSON in ~20 seconds

---

### 2. Validate Your Workflow

**When:** Check if your workflow is ready for production

**Example:**
```bash
/chucky validate ChuckyDiscordRAG.json
```

**What Happens:** Auto-executes validation, returns report in ~15 seconds

---

### 3. Build a Complete Feature

**When:** You need multiple components working together

**Example:**
```bash
/chucky build a pressure monitoring system with Discord alerts and tests
```

**What Happens:**
1. Shows plan (3-4 steps)
2. Waits for your approval
3. Executes pipeline
4. Returns complete package (nodes + alerts + tests)
Time: 3-5 minutes

---

### 4. Debug a Problem

**When:** Something's not working

**Example:**
```bash
/chucky debug ChuckyDiscordRAG.json "Discord messages aren't sending"
```

**What Happens:**
1. Analyzes workflow
2. Identifies root cause
3. Implements fix
4. Tests the fix
Time: 3-5 minutes

---

### 5. Prepare for Deployment

**When:** Ready to move to production

**Example:**
```bash
/chucky production-ready ChuckyDiscordRAG.json
```

**What Happens:**
1. Generates comprehensive tests
2. Validates structure
3. Runs security checks
4. Creates deployment guide
Time: 5-8 minutes

---

## Workflow Templates

Pre-built multi-step pipelines for common tasks.

### Template: `production-ready`

**Purpose:** Full validation before deployment

**Command:**
```bash
/chucky production-ready [workflow.json]
```

**Deliverables:**
- Comprehensive test scenarios
- Validation report
- Security audit
- Deployment checklist

**Time:** 5-8 minutes

---

### Template: `new-feature`

**Purpose:** Complete feature from design to docs

**Command:**
```bash
/chucky new-feature "[feature description]"
```

**Example:**
```bash
/chucky new-feature "Temperature monitoring with email alerts"
```

**Deliverables:**
- Feature architecture design
- Workflow nodes
- Test scenarios
- Updated documentation

**Time:** 4-6 minutes

---

### Template: `debug`

**Purpose:** Troubleshoot and fix issues

**Command:**
```bash
/chucky debug [workflow.json] "[problem description]"
```

**Example:**
```bash
/chucky debug ChuckyDiscordRAG.json "Image analysis not working"
```

**Deliverables:**
- Root cause analysis
- Fixed workflow
- Test to prevent regression
- Explanation of fix

**Time:** 3-5 minutes

---

### Template: `deploy-prep`

**Purpose:** Prepare for VPS/production deployment

**Command:**
```bash
/chucky deploy-prep [workflow.json]
```

**Deliverables:**
- Configuration validation
- Security audit
- Deployment checklist
- Environment setup guide

**Time:** 5-7 minutes

---

## Session Memory Examples

The manager remembers context, making follow-ups natural.

### Example 1: Iterative Development

```bash
You: /chucky create a sensor monitoring node
Manager: [Creates node, stores in memory]

You: add error handling to it
Manager: [Retrieves node, adds error handling]

You: now add logging
Manager: [Retrieves updated node, adds logging]

You: perfect, generate tests for that
Manager: [Routes to testing with full context]
```

### Example 2: Feature Refinement

```bash
You: /chucky create a Discord embed for alerts
Manager: [Creates blue embed]

You: make it red for critical alerts
Manager: [Changes color to red]

You: add timestamp and equipment ID fields
Manager: [Adds fields]

You: show me the final JSON
Manager: [Returns complete embed JSON]
```

### What Gets Remembered

- ✅ Recently created nodes
- ✅ Modified workflows
- ✅ User preferences
- ✅ Current conversation context

### Memory Limitations

- ⏱ Lasts only for current session
- 🔄 Cleared when you start new Claude Code session
- 📝 Remembers last 5-10 interactions

---

## Tips for Best Results

### ✅ DO: Be Specific

**Good:**
```bash
/chucky create a Code node that parses JSON temperature data with error handling
```

**Not as Good:**
```bash
/chucky make a node
```

### ✅ DO: Use Natural Language

**Good:**
```bash
/chucky I need help debugging why Discord alerts aren't sending
```

**Not as Good:**
```bash
/chucky discord send node fix
```

### ✅ DO: Use Templates for Common Tasks

**Good:**
```bash
/chucky production-ready workflow.json
```

**Not as Good:**
```bash
/chucky validate workflow then test it then check security then create deployment guide
```

### ✅ DO: Reference Previous Work

**Good:**
```bash
/chucky validate that workflow we just created
```

**Good:**
```bash
/chucky add tests for it
```

### ❌ DON'T: Be Ambiguous

**Bad:**
```bash
/chucky do the thing
```

**Better:**
```bash
/chucky validate the main workflow
```

### ❌ DON'T: Forget Context Expires

**Bad (in new session):**
```bash
/chucky modify it
```
*Manager doesn't know what "it" is*

**Better:**
```bash
/chucky modify the temperature monitoring node
```

---

## When to Use Individual Commands

The manager is great, but sometimes you want direct access.

### Use `/chucky-node-builder` when:
- You know exactly what node you need
- You want quick node generation
- You're scripting/automating

### Use `/chucky-workflow-validator` when:
- You only need validation
- You don't want full production-ready checks
- You're in a tight loop

### Use `/chucky-doc-generator` when:
- You only need documentation updated
- You want specific doc type (architecture, API, etc.)
- You're updating docs frequently

### Use `/chucky-troubleshoot-builder` when:
- You're creating industrial troubleshooting guides
- You have PDF manuals to process
- You need OSHA/NFPA compliance

### Use `/chucky-test-scenario` when:
- You only need test generation
- You want specific test types
- You're building test suite

### Use `/chucky-embed-designer` when:
- You're designing Discord embeds
- You want specific templates
- You're iterating on embed design

---

## Troubleshooting

### Problem: Manager doesn't understand my request

**Symptoms:** Wrong action taken or error message

**Solutions:**
1. Be more specific with action verbs ("create", "validate", "debug")
2. Name the target explicitly ("the Discord node", "ChuckyDiscordRAG workflow")
3. Try an individual command for precise control
4. Rephrase in simpler terms

**Example:**
```bash
# Unclear
/chucky fix the problem

# Clear
/chucky debug ChuckyDiscordRAG.json "Discord triggers not firing"
```

---

### Problem: Session memory not working

**Symptoms:** Follow-up commands don't recognize "it" or "that"

**Solutions:**
1. Check you're in the same Claude Code session
2. Name the entity explicitly
3. Ask what's in memory: `/chucky what did we just work on?`

**Example:**
```bash
# Won't work in new session
/chucky validate it

# Will work
/chucky validate the ChuckyDiscordRAG workflow
```

---

### Problem: Output too complex

**Symptoms:** Manager returns overwhelming information

**Solutions:**
1. Ask for summary: "give me just the key points"
2. Request specific sections: "show only errors"
3. Use simpler commands for focused tasks

**Example:**
```bash
# Complex
/chucky production-ready workflow.json

# Simpler
/chucky validate workflow.json
```

---

### Problem: Template not recognized

**Symptoms:** Template command doesn't work

**Solutions:**
1. Use exact template names:
   - `production-ready`
   - `new-feature`
   - `debug`
   - `deploy-prep`
2. Check syntax (some need quotes for descriptions)
3. Provide required file paths

**Example:**
```bash
# Wrong
/chucky prod-ready workflow.json

# Correct
/chucky production-ready workflow.json
```

---

## Real-World Workflows

### Workflow 1: Building a New Monitoring Feature

**Goal:** Create temperature monitoring with alerts

**Commands:**
```bash
# Step 1: Use template to build complete feature
/chucky new-feature "Temperature monitoring with Discord alerts when over 80°C"

# Manager shows plan, you approve, get:
# - Monitoring nodes
# - Alert configuration
# - Tests
# - Documentation

# Step 2: Validate it's production-ready
/chucky production-ready temperature_monitoring.json

# Get:
# - Test report
# - Validation report
# - Security audit
# - Deployment guide

# Step 3: Deploy!
```

**Time:** ~15 minutes total

---

### Workflow 2: Debugging an Existing Workflow

**Goal:** Fix Discord messages not sending

**Commands:**
```bash
# Step 1: Debug the issue
/chucky debug ChuckyDiscordRAG.json "Discord messages aren't sending"

# Get:
# - Root cause analysis (likely: webhook URL misconfigured)
# - Fixed workflow
# - Test case

# Step 2: Validate the fix
/chucky validate ChuckyDiscordRAG.json

# Get:
# - Validation report confirming fix

# Step 3: Test it works
/chucky generate test scenario for Discord sending

# Get:
# - Test to run manually
```

**Time:** ~5-7 minutes total

---

### Workflow 3: Preparing for Production Deployment

**Goal:** Move from localhost to VPS

**Commands:**
```bash
# Step 1: Get deployment ready
/chucky deploy-prep ChuckyDiscordRAG.json

# Get:
# - Environment variable list
# - Docker configuration
# - Security checklist
# - Step-by-step deployment guide

# Step 2: Update documentation
/chucky update docs to reflect VPS deployment

# Get:
# - Updated README
# - Architecture docs

# Step 3: Final validation
/chucky production-ready ChuckyDiscordRAG.json

# Get:
# - Full test suite
# - Final validation report
```

**Time:** ~15-20 minutes total

---

## Advanced Usage

### Chaining Multiple Operations

```bash
/chucky create a pressure sensor node, validate it, generate tests, and update the architecture docs
```

Manager will:
1. Show plan for all 4 steps
2. Wait for approval
3. Execute sequentially
4. Return all deliverables

### Custom Validation Levels

```bash
# Thorough validation
/chucky validate ChuckyDiscordRAG.json with thorough security checks

# Quick validation
/chucky quick validate ChuckyDiscordRAG.json
```

### Asking for Clarification

If the manager doesn't understand, it will ask:

```
You: /chucky I need better error handling

Manager: I can help with that! A few questions:
1. Which workflows need error handling?
2. What types of errors should we handle?
3. How should errors be reported (Discord, logs, email)?

Please provide details so I can create the right solution.
```

---

## Performance Expectations

| Operation | Expected Time |
|-----------|---------------|
| Simple node creation | < 30 seconds |
| Workflow validation | < 20 seconds |
| Documentation update | < 25 seconds |
| Complex feature plan | < 45 seconds |
| production-ready template | 5-8 minutes |
| new-feature template | 4-6 minutes |
| debug template | 3-5 minutes |
| deploy-prep template | 5-7 minutes |

---

## Getting Help

### Built-in Help

```bash
# See all available commands
ls .claude/commands/

# Read command documentation
cat .claude/commands/chucky.md

# See all agents
ls .claude/agents/

# Read agent definition
cat .claude/agents/chucky-manager.md
```

### Ask the Manager

```bash
# Get usage examples
/chucky how do I use workflow templates?

# Check what's in session
/chucky what did we just work on?

# Get suggestions
/chucky what should I do next?
```

### Documentation

- **This Guide:** `CHUCKY_MANAGER_USER_GUIDE.md`
- **Testing Guide:** `CHUCKY_MANAGER_TESTING_GUIDE.md`
- **Implementation Summary:** `MANAGER_IMPLEMENTATION_SUMMARY.md`
- **Integration Guide:** `CLAUDE_CLI_N8N_INTEGRATION.md`
- **Project Overview:** `context/project_overview.md`

### Support

- GitHub Issues: [Project Repository]
- Testing Problems: See `CHUCKY_MANAGER_TESTING_GUIDE.md`
- Technical Details: See `MANAGER_IMPLEMENTATION_SUMMARY.md`

---

## Quick Reference Card

### Most Common Commands

```bash
# Create node
/chucky create a [type] node that [does what]

# Validate workflow
/chucky validate [workflow.json]

# Debug issue
/chucky debug [workflow.json] "[problem]"

# Build feature
/chucky new-feature "[description]"

# Production check
/chucky production-ready [workflow.json]

# Deployment prep
/chucky deploy-prep [workflow.json]

# Update docs
/chucky update docs for [what changed]

# Generate tests
/chucky generate tests for [what]
```

### Workflow Templates

```bash
/chucky production-ready [workflow.json]
/chucky new-feature "[description]"
/chucky debug [workflow.json] "[issue]"
/chucky deploy-prep [workflow.json]
```

### Session Memory

```bash
# Works after creating something
/chucky validate it
/chucky add tests for that
/chucky now document it
```

---

## What's Next?

Now that you understand the manager, try:

1. **Run the test suite** - See `CHUCKY_MANAGER_TESTING_GUIDE.md`
2. **Build a real feature** - Use `new-feature` template
3. **Validate your workflows** - Use `production-ready` template
4. **Deploy to production** - Use `deploy-prep` template

---

**Happy Building!**

---

**Version:** 1.0.0
**Maintainer:** Claude Code + User
**Last Updated:** 2025-11-04
**Feedback:** Open GitHub issue or update this doc
