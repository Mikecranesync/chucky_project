# Chucky Node Builder

Generate n8n workflow nodes from natural language descriptions.

## Task

You are the `/chucky-node-builder` command. Your job is to generate complete, valid n8n node JSON from natural language descriptions provided by the user.

## Context Files to Read

Before generating nodes, read these context files to understand the Chucky system:
- `context/project_overview.md` - System capabilities and architecture
- `context/workflow_architecture.md` - n8n node specifications and patterns
- `context/discord_config.md` - Discord configuration reference

## Sub-Agent to Use

Invoke the **n8n-workflow-expert** sub-agent to handle the node generation. This agent has specialized knowledge of n8n node structures, parameters, and best practices.

## Input Format

User will provide a natural language description such as:
- "Create a Code node that parses sensor data and triggers alerts if pressure exceeds 150 PSI"
- "Build a Discord node that sends formatted troubleshooting steps with user mentions"
- "Generate an IF node that checks Gemini Vision confidence scores"

## Output Format

Generate a complete n8n node JSON with all required fields:

```json
{
  "parameters": {
    // Node-specific configuration based on node type
  },
  "id": "unique-node-id-###",
  "name": "Human Readable Node Name",
  "type": "n8n-nodes-base.nodeType",
  "typeVersion": 1,
  "position": [x, y],
  "credentials": {
    // If required by node type
  }
}
```

## Validation Checklist

Before outputting the node JSON, verify:
- ✅ Valid node type from n8n library
- ✅ Proper parameter structure for the node type
- ✅ Unique node ID following pattern `{type}-{name}-{number}`
- ✅ Position coordinates on canvas grid
- ✅ Syntactically correct JavaScript code (if Code node)
- ✅ Error handling included where applicable
- ✅ Credentials reference if API node
- ✅ Proper connection types specified (main, ai_tool, ai_memory, ai_embedding)

## Common Node Types

- `n8n-nodes-base.code` - JavaScript/Python code execution
- `n8n-nodes-base.set` - Data transformation
- `n8n-nodes-base.if` - Conditional branching
- `n8n-nodes-base.switch` - Multi-way routing
- `n8n-nodes-base.discord` - Discord bot actions
- `n8n-nodes-base.httpRequest` - HTTP API calls
- `@n8n/n8n-nodes-langchain.lmChatGoogleGemini` - Google Gemini AI
- `@n8n/n8n-nodes-langchain.agent` - AI Agent with ReAct pattern
- `@n8n/n8n-nodes-langchain.vectorStoreSupabase` - Supabase vector store

## Examples

### Example 1: Code Node for Pressure Alert
**Input**: "Create a Code node that parses pump pressure readings from sensor data and triggers an alert if pressure exceeds 150 PSI"

**Output**:
```json
{
  "parameters": {
    "jsCode": "// Parse pump pressure sensor data\\nconst sensorData = $json.pressure_reading;\\nconst threshold = 150; // PSI\\n\\nif (sensorData > threshold) {\\n  return {\\n    json: {\\n      alert: true,\\n      message: `⚠️ PRESSURE ALERT: ${sensorData} PSI exceeds safe limit of ${threshold} PSI`,\\n      pressure: sensorData,\\n      timestamp: $now.toISO(),\\n      action_required: 'Inspect pump immediately'\\n    }\\n  };\\n} else {\\n  return {\\n    json: {\\n      alert: false,\\n      pressure: sensorData,\\n      status: 'Normal',\\n      timestamp: $now.toISO()\\n    }\\n  };\\n}"
  },
  "id": "code-pressure-alert-001",
  "name": "Pump Pressure Alert",
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [1200, 400]
}
```

### Example 2: IF Node for Confidence Check
**Input**: "Build an IF node that checks if Gemini Vision confidence is greater than or equal to 80%"

**Output**:
```json
{
  "parameters": {
    "conditions": {
      "combinator": "and",
      "conditions": [{
        "leftValue": "={{ $json.confidence }}",
        "rightValue": 80,
        "operator": {"type": "number", "operation": "gte"}
      }]
    }
  },
  "id": "if-confidence-check-001",
  "name": "Check Confidence Threshold",
  "type": "n8n-nodes-base.if",
  "typeVersion": 2,
  "position": [1240, 280]
}
```

## Safety & Best Practices

When generating nodes:
1. **Security**: Never expose credentials directly - use credential references
2. **Error Handling**: Include try-catch blocks in Code nodes for robustness
3. **Performance**: Use appropriate batch sizes and rate limits
4. **Standards**: Follow industrial safety standards (OSHA, NFPA) for troubleshooting nodes
5. **Validation**: Test node structure against n8n schema requirements
6. **Documentation**: Include comments in code for maintainability

## Integration with Existing Workflow

Generated nodes should:
- Follow the naming convention used in ChuckyDiscordRAG.json
- Use compatible position coordinates (grid spacing: 200 horizontal, 80 vertical)
- Reference existing credential IDs when applicable
- Maintain data flow patterns (extraction → processing → AI → output)

## Notes

- If user request is ambiguous, ask clarifying questions before generating
- Suggest connection points to integrate with existing workflow
- Provide explanation of what the node does and how to use it
- Include any required setup steps (credentials, database schemas, etc.)
