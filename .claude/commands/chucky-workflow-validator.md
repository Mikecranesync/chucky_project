# Chucky Workflow Validator

Validate n8n workflow JSON for errors, issues, and best practice violations.

## Task

You are the `/chucky-workflow-validator` command. Your job is to analyze n8n workflow JSON files and identify:
- Syntax errors
- Invalid node configurations
- Broken connections
- Missing credentials
- Performance bottlenecks
- Security issues
- Best practice violations

## Context Files to Read

Read these files to understand validation requirements:
- `context/workflow_architecture.md` - Expected node structures and patterns
- `context/project_overview.md` - System architecture and requirements

## Sub-Agent to Use

Invoke the **n8n-workflow-expert** sub-agent for deep technical validation and the **testing-coordinator** sub-agent for test scenario generation.

## Input Format

User will provide:
- Workflow JSON file path (e.g., `ChuckyDiscordRAG.json`)
- Optional: Specific node ID or area to focus validation on

## Validation Checks

### 1. JSON Structure Validation
- ✅ Valid JSON syntax (no parsing errors)
- ✅ Required top-level fields present (nodes, connections, settings)
- ✅ Proper array and object nesting

### 2. Node Validation
For each node, check:
- ✅ Node type exists in n8n library
- ✅ Node ID is unique within workflow
- ✅ Node name is descriptive
- ✅ Required parameters are present
- ✅ Parameter values are correct types
- ✅ Position coordinates are valid
- ✅ Type version matches n8n expectations

### 3. Connection Validation
- ✅ All connections reference valid source and target node IDs
- ✅ Connection types are valid (main, ai_tool, ai_memory, ai_embedding)
- ✅ Output/input indices exist on referenced nodes
- ✅ No circular dependencies (infinite loops)
- ✅ No orphaned nodes (disconnected from flow)

### 4. Credential Validation
- ✅ All credential IDs are defined (not placeholders)
- ✅ Credential types match node requirements
- ✅ No exposed secrets or tokens in plain text

### 5. Logic Validation
- ✅ IF/Switch nodes have all branches handled
- ✅ Merge nodes have proper input connections
- ✅ Error handling is present
- ✅ Retry logic configured for API nodes

### 6. Performance Validation
- ⚠️ Batch sizes are appropriate (not too small/large)
- ⚠️ Rate limiting configured for external APIs
- ⚠️ No excessive iterations in loops
- ⚠️ Database queries are optimized

### 7. Security Validation
- 🚨 No hardcoded API keys or passwords
- 🚨 Proper authentication for all external services
- 🚨 Input validation in Code nodes
- 🚨 SQL injection prevention in database queries

## Output Format

Generate a comprehensive validation report in markdown:

```markdown
# Workflow Validation Report: [filename]

**Date**: [ISO timestamp]
**Workflow**: [name]
**Total Nodes**: [count]

## Summary
✅ [X] checks passed
⚠️ [Y] warnings found
❌ [Z] errors found

## Critical Errors (Must Fix)
1. **Node: "[node-name]" (ID: [id])**
   - Issue: [description]
   - Location: [file:line or position]
   - Fix: [specific instructions]
   - Severity: CRITICAL

## Warnings (Should Fix)
1. **Node: "[node-name]"**
   - Issue: [description]
   - Recommendation: [suggestion]
   - Severity: MEDIUM/LOW

## Best Practice Suggestions
1. [Improvement suggestion with explanation]

## Performance Optimizations
1. [Performance improvement with expected benefit]

## Security Considerations
1. [Security recommendation]

## Suggested Fixes

### Fix for Error 1
```json
// Update this section of the node
{
  "parameters": {
    "fixedParameter": "correctedValue"
  }
}
```

## Test Recommendations
Based on validation findings, recommended tests:
1. [Test scenario 1]
2. [Test scenario 2]

## Next Steps
1. Fix critical errors (workflow will not execute)
2. Address warnings (may cause runtime issues)
3. Consider best practices (improves maintainability)
4. Run test scenarios after fixes

---
**Validation Status**: [PASS/FAIL/WARNING]
```

## Example Validation Report

```markdown
# Workflow Validation Report: ChuckyDiscordRAG.json

**Date**: 2025-11-04T16:30:00Z
**Workflow**: Chucky Discord RAG Agent
**Total Nodes**: 25

## Summary
✅ 22 checks passed
⚠️ 3 warnings found
❌ 1 error found

## Critical Errors

1. **Node: "xAI Grok Model" (xai-grok-001)**
   - Issue: Credential ID "XAI_CREDENTIAL_ID" is a placeholder string
   - Location: node position [1960, -60]
   - Fix: Replace with actual xAI API credential ID from n8n credential manager
   - Severity: CRITICAL (workflow will fail on execution)

   ```json
   "credentials": {
     "xAiApi": {
       "id": "12345",  // Replace XAI_CREDENTIAL_ID with actual ID
       "name": "xAI account"
     }
   }
   ```

## Warnings

1. **Connection: "Discord Trigger" → "Extract Message Data"**
   - Issue: No error handling if Discord message is malformed
   - Recommendation: Add try-catch in downstream Code nodes
   - Severity: MEDIUM

2. **Performance: "Iteration Loop" (split-batches-001)**
   - Issue: Batch size of 1 may cause slow processing for multiple items
   - Recommendation: Increase to 5 for better throughput
   - Severity: LOW

3. **Node: "Log Error to External Service" (http-log-error-001)**
   - Issue: URL points to placeholder "https://your-logging-service.com/errors"
   - Recommendation: Update with actual logging endpoint or disable node
   - Severity: LOW (optional feature)

## Best Practice Suggestions

1. **Add session timeout handling**: Currently, Postgres chat memory stores unlimited sessions. Consider adding TTL or cleanup logic.

2. **Implement rate limit backoff**: External Search Tool (Brave API) should have exponential backoff on rate limit errors.

3. **Add input sanitization**: Code nodes parsing user input should validate/sanitize to prevent injection attacks.

## Next Steps
1. ✅ Update xAI credential ID (CRITICAL)
2. ⚠️ Add error handling for Discord message parsing
3. ✅ Test workflow execution after credential fix

---
**Validation Status**: FAIL (due to placeholder credential)
```

## Special Validation Rules for Chucky

1. **Discord Integration**: Verify bot token, channel IDs, and webhook URLs are configured
2. **AI Components**: Check that embeddings dimensions match between Gemini and Supabase vector store
3. **RAG Pipeline**: Validate similarity threshold (0.7), topK (5), and table name match Supabase schema
4. **Safety Compliance**: Ensure troubleshooting outputs include OSHA/NFPA safety warnings
5. **Session Management**: Verify sessionId is consistently passed through workflow

## Automation

After validation, offer to:
1. Auto-fix simple issues (placeholders, formatting)
2. Generate test scenarios for identified risks
3. Create documentation updates if workflow structure changed
4. Suggest performance optimizations with estimated improvements

## Notes

- Focus validation on actual errors that would prevent execution
- Separate "must fix" from "nice to have" improvements
- Provide specific, actionable fix instructions
- Reference n8n documentation for complex node configurations
