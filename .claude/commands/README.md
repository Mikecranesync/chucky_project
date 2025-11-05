# Claude Code Slash Commands

This directory contains custom slash commands for the Chucky n8n workflow system.

## Master Command

**`/chucky`** - Unified natural language interface (NEW)
- Routes requests to specialized sub-agents
- Supports workflow templates (`production-ready`, `new-feature`, `debug`, `deploy-prep`)
- Session memory for follow-up commands
- Auto-executes simple requests, plans complex workflows
- Quality validation and error recovery

This is the **recommended command** for most tasks. It intelligently routes your natural language requests to the appropriate specialized commands below.

## Specialized Commands

These commands provide direct access to specific functionality:

- `/chucky-node-builder` - Generate n8n nodes from natural language descriptions
- `/chucky-workflow-validator` - Validate n8n workflow JSON for errors
- `/chucky-doc-generator` - Auto-generate documentation from workflow changes
- `/chucky-troubleshoot-builder` - Create troubleshooting decision trees
- `/chucky-test-scenario` - Generate test scenarios for Discord interactions
- `/chucky-embed-designer` - Design Discord embed templates

## Usage

### Using the Master Command (Recommended)

```bash
# Simple request (auto-executes)
/chucky create a temperature monitoring node

# Complex request (shows plan first)
/chucky build a complete safety alert feature with tests and docs

# Workflow template
/chucky production-ready ChuckyDiscordRAG.json

# Follow-up with session memory
/chucky create a sensor node
/chucky now add error handling to it
```

### Using Specialized Commands (Direct Access)

```bash
# Direct node generation
/chucky-node-builder "Create a node that parses sensor data"

# Direct validation
/chucky-workflow-validator ChuckyDiscordRAG.json

# Direct documentation
/chucky-doc-generator --type setup
```

## Command Architecture

```
User Request
    ↓
/chucky (Master Command)
    ↓
chucky-manager (Orchestration Agent)
    ↓
├─ /chucky-node-builder → n8n-workflow-expert
├─ /chucky-workflow-validator → n8n-workflow-expert + testing-coordinator
├─ /chucky-doc-generator → documentation-maintainer
├─ /chucky-troubleshoot-builder → industrial-knowledge-curator
├─ /chucky-test-scenario → testing-coordinator
└─ /chucky-embed-designer → discord-integration-specialist
```

## When to Use Which Command

### Use `/chucky` when:
- You want a natural language interface
- You need multiple agents working together
- You want session memory for follow-up commands
- You're not sure which specialized command to use
- You want workflow templates (production-ready, new-feature, etc.)

### Use specialized commands when:
- You know exactly which operation you need
- You want direct control over a specific sub-agent
- You're scripting/automating repeated tasks
- You prefer explicit over implicit routing

## Quick Reference

| Task | Command |
|------|---------|
| Build anything (natural language) | `/chucky [request]` |
| Production validation pipeline | `/chucky production-ready [workflow.json]` |
| Create complete feature | `/chucky new-feature "[description]"` |
| Debug workflow | `/chucky debug [workflow.json] "[issue]"` |
| Generate single node | `/chucky-node-builder "[description]"` |
| Validate workflow | `/chucky-workflow-validator [workflow.json]` |
| Update docs | `/chucky-doc-generator --type [type]` |
| Create troubleshooting guide | `/chucky-troubleshoot-builder "[equipment]"` |
| Generate tests | `/chucky-test-scenario [workflow.json]` |
| Design Discord embed | `/chucky-embed-designer --purpose "[purpose]"` |
