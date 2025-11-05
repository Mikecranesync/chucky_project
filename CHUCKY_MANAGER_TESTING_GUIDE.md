# Chucky Manager - Testing & Validation Guide

**Version:** 1.0.0
**Date:** 2025-11-04
**Purpose:** Comprehensive testing guide for the chucky-manager orchestration system

## Overview

This document provides test scenarios to validate all functionality of the Chucky Manager system, including:
- Simple auto-execution requests
- Complex plan-first workflows
- Workflow templates
- Session memory
- Error recovery
- Quality validation

## Test Environment Setup

### Prerequisites

1. **Claude Code CLI** installed and configured
2. **Chucky project** at `C:\Users\hharp\chucky_project`
3. **Git repository** initialized with recent commits
4. **Context files** present in `context/` directory
5. **All sub-agents** defined in `.claude/agents/`
6. **All slash commands** defined in `.claude/commands/`

### Verification Commands

```bash
# Verify Claude Code is working
claude --version

# Verify project structure
ls .claude/agents/
ls .claude/commands/
ls context/

# Verify git status
git status
git log --oneline -5
```

---

## Test Suite

### Test Category 1: Simple Auto-Execute Requests

These should execute immediately without showing a plan.

#### Test 1.1: Create Single Node

**Command:**
```bash
/chucky create a Code node that parses JSON sensor data
```

**Expected Behavior:**
1. Manager analyzes intent → "create node"
2. Determines complexity → Simple (1 sub-agent)
3. Auto-executes → Invokes `n8n-workflow-expert`
4. Returns → Complete node JSON

**Success Criteria:**
- ✅ No plan shown (auto-executes)
- ✅ Valid node JSON returned
- ✅ Node has correct type: `n8n-nodes-base.code`
- ✅ Node has JavaScript parsing logic
- ✅ Node has proper position coordinates
- ✅ Response includes validation confirmation

**Estimated Time:** < 30 seconds

---

#### Test 1.2: Validate Workflow

**Command:**
```bash
/chucky validate ChuckyDiscordRAG.json
```

**Expected Behavior:**
1. Manager analyzes → "validate workflow"
2. Complexity → Simple (single validation task)
3. Routes to → `n8n-workflow-expert`
4. Auto-executes → Validation check
5. Returns → Validation report

**Success Criteria:**
- ✅ No plan shown (auto-executes)
- ✅ Validation report includes:
  - Node count
  - Connection validation
  - Credential checks
  - Any errors/warnings
- ✅ Clear pass/fail status

**Estimated Time:** < 20 seconds

---

#### Test 1.3: Update Documentation

**Command:**
```bash
/chucky update the README to mention the new manager system
```

**Expected Behavior:**
1. Manager analyzes → "update documentation"
2. Complexity → Simple (single doc update)
3. Routes to → `documentation-maintainer`
4. Auto-executes → Updates README
5. Returns → Updated content or diff

**Success Criteria:**
- ✅ No plan shown (auto-executes)
- ✅ README.md is modified
- ✅ Manager system mentioned
- ✅ Changes are relevant and accurate

**Estimated Time:** < 25 seconds

---

### Test Category 2: Complex Plan-First Requests

These should show a plan and wait for approval before executing.

#### Test 2.1: Build Complete Feature

**Command:**
```bash
/chucky build a temperature monitoring system with alerts, tests, and documentation
```

**Expected Behavior:**
1. Manager analyzes → Multiple components needed
2. Determines complexity → Complex (3-4 sub-agents)
3. Generates plan →
   - Step 1: Build monitoring nodes [n8n-workflow-expert]
   - Step 2: Configure Discord alerts [discord-integration-specialist]
   - Step 3: Generate tests [testing-coordinator]
   - Step 4: Update docs [documentation-maintainer]
4. Presents plan to user → Waits for approval
5. After approval → Executes pipeline
6. Returns → Complete package

**Success Criteria:**
- ✅ Plan is shown before execution
- ✅ Plan includes all 4 steps
- ✅ Each step has clear purpose and estimated time
- ✅ User can approve/reject
- ✅ After approval, all steps execute
- ✅ Deliverables include: nodes JSON, alert config, tests, docs

**Estimated Time:** 3-5 minutes after approval

---

#### Test 2.2: Feature with Ambiguity

**Command:**
```bash
/chucky I need a better error handling system
```

**Expected Behavior:**
1. Manager analyzes → Ambiguous request
2. Asks clarifying questions →
   - Which workflows need error handling?
   - What types of errors to handle?
   - Desired error notification method?
3. After clarification → Generates plan
4. Presents plan → Waits for approval
5. Executes → Returns deliverables

**Success Criteria:**
- ✅ Manager recognizes ambiguity
- ✅ Asks relevant clarifying questions
- ✅ Uses answers to generate appropriate plan
- ✅ Plan reflects user's clarifications
- ✅ Final deliverables match intent

**Estimated Time:** 2-4 minutes + clarification time

---

### Test Category 3: Workflow Templates

All templates should show their pipeline plan before executing.

#### Test 3.1: Production-Ready Template

**Command:**
```bash
/chucky production-ready ChuckyDiscordRAG.json
```

**Expected Behavior:**
1. Manager recognizes template → "production-ready"
2. Shows pipeline →
   - Generate comprehensive tests
   - Validate workflow structure
   - Run security checks
   - Create deployment guide
3. User approves → Executes all steps
4. Returns → Complete readiness package

**Success Criteria:**
- ✅ Template recognized correctly
- ✅ Pipeline shows all 4 steps
- ✅ Each step executes in order
- ✅ Deliverables include:
  - `test_scenarios.md`
  - `validation_report.md`
  - `security_report.md`
  - `deployment_guide.md`
- ✅ All reports are comprehensive and actionable

**Estimated Time:** 5-8 minutes

---

#### Test 3.2: New-Feature Template

**Command:**
```bash
/chucky new-feature "Pressure monitoring with SMS alerts"
```

**Expected Behavior:**
1. Manager loads template → "new-feature"
2. Shows pipeline →
   - Design feature architecture
   - Build workflow nodes
   - Generate tests
   - Update documentation
3. Executes → Returns complete feature package

**Success Criteria:**
- ✅ Feature architecture designed
- ✅ Workflow nodes generated (pressure monitoring + SMS)
- ✅ Test scenarios created
- ✅ Documentation updated
- ✅ All components integrated correctly

**Estimated Time:** 4-6 minutes

---

#### Test 3.3: Debug Template

**Command:**
```bash
/chucky debug ChuckyDiscordRAG.json "Discord messages not sending"
```

**Expected Behavior:**
1. Manager loads template → "debug"
2. Analyzes workflow for Discord sending issues
3. Creates reproduction test case
4. Identifies root cause
5. Implements fix
6. Validates fix with test

**Success Criteria:**
- ✅ Root cause identified
- ✅ Fix is appropriate and targeted
- ✅ Test validates the fix
- ✅ Explanation of what was wrong and how it's fixed

**Estimated Time:** 3-5 minutes

---

#### Test 3.4: Deploy-Prep Template

**Command:**
```bash
/chucky deploy-prep ChuckyDiscordRAG.json
```

**Expected Behavior:**
1. Manager loads template → "deploy-prep"
2. Validates all configurations
3. Runs security audit
4. Creates deployment checklist
5. Generates environment setup guide

**Success Criteria:**
- ✅ Configuration validation complete
- ✅ Security audit identifies any issues
- ✅ Deployment checklist is step-by-step
- ✅ Environment guide includes all required variables

**Estimated Time:** 5-7 minutes

---

### Test Category 4: Session Memory

Tests that the manager remembers context across multiple interactions.

#### Test 4.1: Create and Modify

**Sequence:**
```bash
# Step 1: Create node
/chucky create a temperature sensor monitoring node

# Step 2: Modify it (using pronoun)
/chucky add error handling to it

# Step 3: Another modification
/chucky now add logging to that node
```

**Expected Behavior:**
- Step 1: Creates node, stores in session memory
- Step 2: Retrieves "it" from memory, adds error handling
- Step 3: Retrieves updated node, adds logging

**Success Criteria:**
- ✅ "it" correctly refers to temperature node
- ✅ "that node" correctly refers to same node
- ✅ Each modification builds on previous version
- ✅ Final node includes: monitoring + error handling + logging

**Estimated Time:** < 1 minute total

---

#### Test 4.2: Multi-Step Workflow

**Sequence:**
```bash
# Step 1: Create embed
/chucky create a Discord embed for equipment alerts

# Step 2: Modify styling
/chucky make it orange with a warning icon

# Step 3: Add fields
/chucky add fields for equipment ID, status, and timestamp

# Step 4: Test it
/chucky generate test scenarios for that embed
```

**Expected Behavior:**
- Steps 1-3: Iteratively build the embed
- Step 4: Routes to testing-coordinator with embed context

**Success Criteria:**
- ✅ Session memory tracks embed through all modifications
- ✅ Each step references correct version
- ✅ Test scenarios reference final embed version
- ✅ No confusion about what "it" or "that" refers to

**Estimated Time:** < 2 minutes total

---

### Test Category 5: Quality Validation

Tests that manager validates sub-agent outputs.

#### Test 5.1: Invalid Node Detection

**Setup:** Request a node with invalid configuration

**Command:**
```bash
/chucky create a node that connects to a non-existent service
```

**Expected Behavior:**
1. n8n-workflow-expert generates node
2. Manager validates output
3. Detects invalid service reference
4. Returns error with explanation
5. Suggests alternatives

**Success Criteria:**
- ✅ Manager catches invalid configuration
- ✅ Clear error message explaining the issue
- ✅ Suggests valid alternatives
- ✅ Does not return invalid node to user

**Estimated Time:** < 30 seconds

---

#### Test 5.2: Incomplete Documentation

**Setup:** Request documentation for complex feature

**Command:**
```bash
/chucky document the RAG system architecture
```

**Expected Behavior:**
1. documentation-maintainer generates docs
2. Manager validates completeness:
   - All sections present
   - Code examples included
   - Diagrams if needed
   - No broken links
3. If incomplete → Asks maintainer to enhance
4. Returns complete documentation

**Success Criteria:**
- ✅ Documentation is comprehensive
- ✅ All required sections present
- ✅ No broken references
- ✅ Quality meets standards

**Estimated Time:** < 45 seconds

---

### Test Category 6: Error Recovery

Tests that manager handles sub-agent failures gracefully.

#### Test 6.1: Sub-Agent Failure with Retry

**Setup:** Trigger a failure scenario (e.g., invalid file path)

**Command:**
```bash
/chucky validate nonexistent_workflow.json
```

**Expected Behavior:**
1. n8n-workflow-expert attempts to read file
2. Fails with "file not found"
3. Manager catches error
4. Retries with adjusted parameters
5. If still fails → Reports clear error to user

**Success Criteria:**
- ✅ Error caught by manager
- ✅ Retry attempted (max 2 times)
- ✅ Clear error message to user
- ✅ Suggests what to do next (check file path, etc.)

**Estimated Time:** < 20 seconds

---

#### Test 6.2: Ambiguous Intent Recovery

**Command:**
```bash
/chucky do the thing
```

**Expected Behavior:**
1. Manager cannot determine intent
2. Asks clarifying questions
3. Uses answers to route correctly
4. Executes appropriate action

**Success Criteria:**
- ✅ Manager recognizes ambiguity
- ✅ Asks helpful clarifying questions
- ✅ Routes correctly after clarification
- ✅ No frustrating back-and-forth

**Estimated Time:** Variable (depends on user responses)

---

### Test Category 7: Integration with Individual Commands

Tests that individual slash commands still work alongside manager.

#### Test 7.1: Direct Node Builder Call

**Command:**
```bash
/chucky-node-builder "Create a webhook trigger node for Discord"
```

**Expected Behavior:**
1. Command invokes n8n-workflow-expert directly
2. No manager routing
3. Returns node JSON

**Success Criteria:**
- ✅ Command works independently
- ✅ Same quality as manager-routed requests
- ✅ No conflicts with manager

**Estimated Time:** < 20 seconds

---

#### Test 7.2: All Individual Commands

Test each specialized command:

```bash
/chucky-node-builder "Create a Code node"
/chucky-workflow-validator ChuckyDiscordRAG.json
/chucky-doc-generator --type architecture
/chucky-troubleshoot-builder "HVAC system"
/chucky-test-scenario ChuckyDiscordRAG.json
/chucky-embed-designer --purpose alerts
```

**Success Criteria:**
- ✅ All commands work independently
- ✅ No interference from manager
- ✅ Outputs match expected quality

**Estimated Time:** 5-7 minutes total

---

### Test Category 8: Edge Cases

Tests unusual or boundary conditions.

#### Test 8.1: Empty Request

**Command:**
```bash
/chucky
```

**Expected Behavior:**
- Manager asks what you need help with
- Provides usage examples
- Suggests templates

**Success Criteria:**
- ✅ Helpful response (not error)
- ✅ Guides user to make a proper request

---

#### Test 8.2: Very Long Request

**Command:**
```bash
/chucky I need to build a comprehensive monitoring system that tracks temperature, pressure, vibration, and electrical parameters across 50 different pieces of equipment, with real-time alerts via Discord, SMS, and email, comprehensive logging to Supabase, predictive maintenance AI using historical data, automated work order generation, and a dashboard showing all metrics with drill-down capabilities, plus complete documentation and testing
```

**Expected Behavior:**
1. Manager breaks down into phases
2. Suggests starting with MVP
3. Proposes iterative approach

**Success Criteria:**
- ✅ Not overwhelmed by complexity
- ✅ Provides structured approach
- ✅ Suggests prioritization

---

#### Test 8.3: Conflicting Requirements

**Command:**
```bash
/chucky create a node that's both synchronous and asynchronous
```

**Expected Behavior:**
- Manager identifies conflict
- Asks for clarification
- Suggests alternatives

**Success Criteria:**
- ✅ Conflict recognized
- ✅ User educated about the issue
- ✅ Practical solution offered

---

## Validation Checklist

After running all tests, verify:

### Manager Agent (`chucky-manager.md`)
- [ ] Intent analysis works correctly
- [ ] Simple requests auto-execute
- [ ] Complex requests show plans
- [ ] Session memory maintains context
- [ ] Quality validation catches errors
- [ ] Error recovery handles failures
- [ ] Workflow templates execute properly

### Unified Command (`/chucky`)
- [ ] Natural language parsing works
- [ ] Routes to correct sub-agents
- [ ] Template recognition accurate
- [ ] Session memory persistent
- [ ] Output formatting consistent

### Sub-Agents
- [ ] All 5 sub-agents invokable
- [ ] Each agent performs its specialty
- [ ] Outputs are high quality
- [ ] No conflicts between agents

### Context Files
- [ ] `project_overview.md` accurate
- [ ] `workflow_architecture.md` up-to-date
- [ ] `discord_config.md` reflects current setup

### Individual Commands
- [ ] All 6 specialized commands work
- [ ] No conflicts with manager
- [ ] Same quality as manager-routed

### Git Integration
- [ ] All changes committed
- [ ] Commit messages clear
- [ ] Git log shows proper history

---

## Performance Benchmarks

Expected performance for common operations:

| Operation | Target Time | Maximum Time |
|-----------|-------------|--------------|
| Simple node creation | < 30 sec | < 60 sec |
| Workflow validation | < 20 sec | < 45 sec |
| Documentation update | < 25 sec | < 50 sec |
| Complex feature plan | < 45 sec | < 90 sec |
| Production-ready template | 5-8 min | < 12 min |
| New-feature template | 4-6 min | < 10 min |
| Debug template | 3-5 min | < 8 min |
| Session memory recall | Instant | < 5 sec |

---

## Known Limitations

### Current Limitations

1. **Session Memory Scope**
   - Only persists during current conversation
   - Cleared when starting new Claude Code session

2. **Template Customization**
   - Templates have fixed pipelines
   - Cannot dynamically modify template steps

3. **Concurrent Requests**
   - One request processed at a time
   - No parallel request handling

4. **File Size Limits**
   - Large workflow files (>10MB) may be slow
   - Very long responses may be truncated

### Future Enhancements

1. **Persistent Session Memory** - Save across sessions
2. **Dynamic Templates** - User-customizable pipelines
3. **Parallel Processing** - Handle multiple requests
4. **Interactive Refinement** - Real-time collaboration
5. **Learning from Feedback** - Improve routing over time

---

## Troubleshooting

### Issue: Manager Not Responding

**Symptoms:** `/chucky` command has no output

**Solutions:**
1. Check Claude Code CLI is running
2. Verify agent file exists: `.claude/agents/chucky-manager.md`
3. Check for syntax errors in agent definition
4. Restart Claude Code CLI

---

### Issue: Incorrect Sub-Agent Routing

**Symptoms:** Wrong agent invoked for request

**Solutions:**
1. Be more specific in your request
2. Use explicit keywords (e.g., "create node", "validate workflow")
3. Call individual command directly if routing unclear
4. Report routing issue for improvement

---

### Issue: Session Memory Not Working

**Symptoms:** Follow-up commands don't recognize context

**Solutions:**
1. Check if in same conversation session
2. Rephrase with explicit references
3. Ask manager what's in session: `/chucky what did we just work on?`

---

### Issue: Quality Validation Too Strict

**Symptoms:** Manager rejects valid outputs

**Solutions:**
1. Request "quick validate" mode
2. Call individual command to bypass validation
3. Report false positive for improvement

---

## Test Results Log

Use this template to log your test results:

```
Test: [Test Name]
Date: [YYYY-MM-DD]
Time: [HH:MM]
Command: [Command executed]
Expected: [Expected behavior]
Actual: [Actual behavior]
Status: [PASS/FAIL/PARTIAL]
Notes: [Additional observations]
Issues: [Any problems encountered]
```

---

## Reporting Issues

If you encounter problems during testing:

1. **Document the issue:**
   - Exact command used
   - Expected vs actual behavior
   - Error messages (if any)
   - Environment details

2. **Check known limitations:**
   - Review limitations section above
   - May be expected behavior

3. **Submit feedback:**
   - Open GitHub issue at project repository
   - Include test results log
   - Suggest improvements

---

## Success Criteria

The Chucky Manager system is considered fully validated when:

- ✅ All Category 1-8 tests pass
- ✅ Performance benchmarks met
- ✅ No critical bugs discovered
- ✅ Edge cases handled gracefully
- ✅ Documentation accurate and complete
- ✅ Individual commands still functional
- ✅ User experience is intuitive

---

**Test Status:** Ready for execution
**Next Steps:** Run test suite and document results
**Maintainer:** Claude Code + User
**Version:** 1.0.0
