# Chucky Workflow Architecture

## n8n Workflow Technical Specification

### Overview
File: `ChuckyDiscordRAG.json`
Nodes: 25 core nodes
Connections: 22 main connections + 5 AI tool connections
Triggers: 2 (Discord, Error)

---

## Node Inventory

### 1. Trigger Nodes (2)

#### Discord Trigger
- **Type**: `n8n-nodes-base.discordTrigger`
- **Version**: 1
- **ID**: `discord-trigger-001`
- **Position**: [-200, 400]
- **Parameters**:
  ```json
  {
    "channel": "",  // Channel ID inserted after setup
    "updates": ["messageCreated"],
    "options": {
      "filter": "!",
      "matchStartsWith": true
    }
  }
  ```
- **Credentials**: Discord OAuth2 API
- **Purpose**: Listens for messages starting with `!` in specified Discord channel
- **Output**: Discord message object with content, author, attachments, channel_id

#### Error Trigger
- **Type**: `n8n-nodes-base.errorTrigger`
- **Version**: 1
- **ID**: `error-trigger-001`
- **Position**: [2440, 480]
- **Parameters**: None
- **Purpose**: Catches workflow execution errors
- **Output**: Error object with message, node name, execution ID

---

### 2. Data Processing Nodes (4)

#### Extract Message Data
- **Type**: `n8n-nodes-base.set`
- **Version**: 3.4
- **ID**: `edit-fields-001`
- **Position**: [40, 400]
- **Parameters**:
  ```json
  {
    "assignments": {
      "assignments": [
        {"name": "query", "value": "={{ $json.content }}", "type": "string"},
        {"name": "sessionId", "value": "={{ $json.author.id }}", "type": "string"},
        {"name": "channelId", "value": "={{ $json.channel_id }}", "type": "string"},
        {"name": "attachments", "value": "={{ $json.attachments || [] }}", "type": "array"},
        {"name": "username", "value": "={{ $json.author.username }}", "type": "string"}
      ]
    }
  }
  ```
- **Purpose**: Extracts key data from Discord message
- **Input**: Raw Discord message
- **Output**: Structured object with query, sessionId, channelId, attachments, username

#### Route by Input Type (Switch)
- **Type**: `n8n-nodes-base.switch`
- **Version**: 3.2
- **ID**: `switch-input-type-001`
- **Position**: [280, 400]
- **Parameters**:
  ```json
  {
    "rules": {
      "values": [
        {
          "conditions": {
            "combinator": "and",
            "conditions": [{
              "leftValue": "={{ $json.attachments }}",
              "rightValue": "",
              "operator": {"type": "array", "operation": "notEmpty"}
            }]
          }
        },
        {
          "conditions": {
            "combinator": "and",
            "conditions": [{
              "leftValue": "={{ $json.query }}",
              "rightValue": "",
              "operator": {"type": "string", "operation": "exists"}
            }]
          }
        }
      ]
    }
  }
  ```
- **Purpose**: Routes messages based on whether they have attachments
- **Outputs**:
  - Output 0 → Has attachments (goes to Download)
  - Output 1 → Text only (goes to Set Text Query)

#### Set Text Query
- **Type**: `n8n-nodes-base.set`
- **Version**: 3.4
- **ID**: `set-text-query-001`
- **Position**: [520, 520]
- **Parameters**: Adds `hasAttachment: false` and sets description to query
- **Purpose**: Prepares text-only messages for RAG retrieval

#### Parse Vision Response
- **Type**: `n8n-nodes-base.code`
- **Version**: 2
- **ID**: `code-parse-json-001`
- **Position**: [1000, 280]
- **Code**: JavaScript that parses Gemini Vision JSON response
- **Purpose**: Extracts structured data from AI vision analysis
- **Key Logic**:
  - Regex extraction of JSON from markdown
  - Fallback parsing for unstructured responses
  - Adds confidence level, sessionId, query metadata
- **Output**: Structured analysis with category, confidence, faults, keywords

---

### 3. File Handling Nodes (1)

#### Download Attachment
- **Type**: `n8n-nodes-base.googleDrive`
- **Version**: 3
- **ID**: `download-attachment-001`
- **Position**: [520, 280]
- **Parameters**:
  ```json
  {
    "operation": "download",
    "fileId": {
      "__rl": true,
      "mode": "url",
      "value": "={{ $json.attachments[0].url }}"
    }
  }
  ```
- **Credentials**: Google OAuth2
- **Retry**: maxTries=3, retryOnFail=true
- **Purpose**: Downloads Discord attachments for analysis
- **Note**: Discord CDN URLs are directly accessible, but node configured for Google Drive compatibility

---

### 4. AI Vision Analysis Nodes (1)

#### Gemini Vision Analysis
- **Type**: `@n8n/n8n-nodes-langchain.lmChatGoogleGemini`
- **Version**: 1
- **ID**: `gemini-vision-001`
- **Position**: [760, 280]
- **Parameters**:
  ```json
  {
    "model": "gemini-1.5-pro-latest",
    "prompt": {
      "messages": [
        {
          "role": "system",
          "content": "You are an industrial equipment analysis expert. Analyze images and PDFs to identify equipment type, potential faults, extract visible text/diagrams, and suggest initial troubleshooting steps based on industry standards (e.g., OSHA, NFPA). Output structured JSON with: category, description, keywords, extractedText, faults (array), suggestedSteps (array), confidence (0-100)."
        },
        {
          "role": "user",
          "content": "={{ 'Analyze this industrial equipment image/document: ' + $json.query }}"
        }
      ]
    },
    "options": {
      "temperature": 0.3,
      "maxOutputTokens": 800
    }
  }
  ```
- **Credentials**: Google PaLM API
- **Purpose**: Analyzes equipment images using vision AI
- **Output**: JSON response with equipment analysis

---

### 5. Logic Nodes (3)

#### Check Confidence
- **Type**: `n8n-nodes-base.if`
- **Version**: 2
- **ID**: `if-confidence-001`
- **Position**: [1240, 280]
- **Parameters**:
  ```json
  {
    "conditions": {
      "combinator": "and",
      "conditions": [{
        "leftValue": "={{ $json.confidence }}",
        "rightValue": 80,
        "operator": {"type": "number", "operation": "gte"}
      }]
    }
  }
  ```
- **Purpose**: Checks if vision analysis confidence >= 80%
- **Outputs**:
  - True (confidence >=80%) → Proceed to RAG
  - False (confidence <80%) → Ask for clarification

#### Merge Analysis + RAG
- **Type**: `n8n-nodes-base.merge`
- **Version**: 3
- **ID**: `merge-analysis-rag-001`
- **Position**: [1720, 200]
- **Parameters**:
  ```json
  {
    "mode": "combine",
    "combinationMode": "mergeByPosition"
  }
  ```
- **Purpose**: Combines vision analysis with RAG retrieval results
- **Inputs**:
  - Input 1: Vision analysis or text query
  - Input 2: RAG documents from vector store
- **Output**: Merged object with analysis + documents

#### Iteration Loop
- **Type**: `n8n-nodes-base.splitInBatches`
- **Version**: 3
- **ID**: `split-batches-001`
- **Position**: [2200, 200]
- **Parameters**:
  ```json
  {
    "batchSize": 1,
    "options": {}
  }
  ```
- **Purpose**: Allows AI Agent to iterate and refine response
- **Note**: Currently set to batch size 1 (processes one item at a time)

---

### 6. RAG Pipeline Nodes (2)

#### RAG Retrieval
- **Type**: `@n8n/n8n-nodes-langchain.vectorStoreSupabase`
- **Version**: 1.3
- **ID**: `vector-store-retrieve-001`
- **Position**: [1480, 140]
- **Parameters**:
  ```json
  {
    "mode": "retrieve",
    "tableName": "learnable_content",
    "query": "={{ $json.description || $json.query }}",
    "topK": 5,
    "options": {
      "similarityThreshold": 0.7
    }
  }
  ```
- **Credentials**: Supabase API
- **Purpose**: Retrieves top 5 relevant documents from vector database
- **Minimum Similarity**: 0.7 (70%)
- **Output**: Array of documents with pageContent and metadata

#### Gemini Embeddings
- **Type**: `@n8n/n8n-nodes-langchain.embeddingsGoogleGemini`
- **Version**: 1
- **ID**: `gemini-embeddings-001`
- **Position**: [1480, 20]
- **Parameters**:
  ```json
  {
    "model": "embedding-001"
  }
  ```
- **Credentials**: Google PaLM API
- **Purpose**: Generates 768-dimensional embeddings for vector search
- **Connection**: Connected to RAG Retrieval and Vector Store Tool via ai_embedding

---

### 7. AI Agent & Tools (5)

#### Chucky AI Agent
- **Type**: `@n8n/n8n-nodes-langchain.agent`
- **Version**: 1
- **ID**: `ai-agent-001`
- **Position**: [1960, 200]
- **Parameters**:
  ```json
  {
    "promptType": "define",
    "text": "You are an industrial troubleshooting expert. Use the provided tools to: 1) Analyze the input, 2) Retrieve relevant documentation, 3) Generate detailed troubleshooting steps, 4) Verify and iterate if needed.\\n\\nUser Query: {{ $json.query }}\\n\\nImage Analysis: {{ $json.description }}\\n\\nRetrieved Documentation: {{ $json.documents }}",
    "hasOutputParser": true,
    "options": {
      "systemMessage": "You are Chucky, an expert industrial maintenance assistant. Provide clear, actionable troubleshooting steps. Always prioritize safety. Format as numbered markdown lists."
    }
  }
  ```
- **Connections**:
  - ai_memory → Postgres Chat Memory
  - ai_languageModel → xAI Grok Model
  - ai_tool → 3 tools (Vector Store, Code, HTTP)
- **Purpose**: Core reasoning engine using ReAct pattern

#### Postgres Chat Memory
- **Type**: `@n8n/n8n-nodes-langchain.memoryPostgresChat`
- **Version**: 2
- **ID**: `postgres-memory-001`
- **Position**: [1960, 60]
- **Parameters**:
  ```json
  {
    "sessionIdType": "customKey",
    "sessionKey": "={{ $json.sessionId }}",
    "contextWindowLength": 10
  }
  ```
- **Credentials**: Postgres database
- **Purpose**: Stores conversation history per Discord user
- **Remembers**: Last 10 messages per session

#### xAI Grok Model
- **Type**: `@n8n/n8n-nodes-langchain.lmChatxAi`
- **Version**: 1
- **ID**: `xai-grok-001`
- **Position**: [1960, -60]
- **Parameters**:
  ```json
  {
    "model": "grok-beta",
    "options": {
      "temperature": 0.5,
      "maxTokens": 2000
    }
  }
  ```
- **Credentials**: xAI API
- **Alternative**: Can use `@n8n/n8n-nodes-langchain.lmChatAnthropic` with Claude 3.5 Sonnet
- **Purpose**: LLM for agentic reasoning

#### Vector Store Tool
- **Type**: `@n8n/n8n-nodes-langchain.toolVectorStore`
- **Version**: 1
- **ID**: `tool-vector-store-001`
- **Position**: [1720, 60]
- **Parameters**:
  ```json
  {
    "name": "vectorStoreRetrieval",
    "description": "Retrieve relevant documentation from the industrial equipment knowledge base. Use this to find manuals, troubleshooting guides, safety procedures, and technical specifications.",
    "mode": "retrieve",
    "tableName": "learnable_content",
    "topK": 5,
    "options": {
      "similarityThreshold": 0.7
    }
  }
  ```
- **Purpose**: Allows agent to query vector database dynamically

#### Code Analysis Tool
- **Type**: `@n8n/n8n-nodes-langchain.toolCode`
- **Version**: 1
- **ID**: `tool-code-001`
- **Position**: [1720, -60]
- **Parameters**:
  ```json
  {
    "name": "customAnalysis",
    "description": "Execute custom JavaScript code for specialized analysis, data transformation, or calculations. Use this for extracting specific information from analysis results.",
    "code": "// Custom analysis logic\nconst input = $input.all();\nconst result = { processed: true, data: input };\nreturn result;"
  }
  ```
- **Purpose**: Allows agent to run custom code for complex analysis

#### External Search Tool
- **Type**: `@n8n/n8n-nodes-langchain.toolHttpRequest`
- **Version**: 1.1
- **ID**: `tool-http-001`
- **Position**: [1720, -180]
- **Parameters**:
  ```json
  {
    "name": "externalSearch",
    "description": "Search external sources (web, documentation sites) when internal knowledge base doesn't have sufficient information.",
    "method": "GET",
    "url": "=https://api.brave.com/res/v1/web/search?q={{ encodeURIComponent($json.query) }}&count=5",
    "options": {
      "response": {
        "response": {
          "responseFormat": "json"
        }
      }
    }
  }
  ```
- **Credentials**: Brave Search API (Header Auth)
- **Purpose**: Fallback to web search when vector store has no matches

---

### 8. Output Nodes (5)

#### Format Discord Response
- **Type**: `n8n-nodes-base.code`
- **Version**: 2
- **ID**: `code-format-response-001`
- **Position**: [2440, 200]
- **Code**: JavaScript that formats AI Agent output as Discord markdown
- **Key Features**:
  - Adds user mention
  - Formats as markdown
  - Truncates to 1900 chars if too long
  - Adds footer with branding
- **Output**: Formatted message ready for Discord

#### Send Troubleshooting Steps
- **Type**: `n8n-nodes-base.discord`
- **Version**: 2
- **ID**: `discord-send-response-001`
- **Position**: [2680, 200]
- **Parameters**:
  ```json
  {
    "channel": "={{ $json.channelId }}",
    "text": "={{ $json.formattedMessage }}",
    "options": {
      "allowedMentions": {
        "users": ["={{ $json.sessionId }}"]
      }
    }
  }
  ```
- **Credentials**: Discord OAuth2
- **Retry**: maxTries=3, retryOnFail=true
- **Purpose**: Sends final response to Discord

#### Ask for Clarification
- **Type**: `n8n-nodes-base.discord`
- **Version**: 2
- **ID**: `discord-send-clarify-001`
- **Position**: [1480, 420]
- **Parameters**: Sends clarification request when confidence <80%
- **Purpose**: Asks user for more details when vision analysis is uncertain

#### Send Error Message
- **Type**: `n8n-nodes-base.discord`
- **Version**: 2
- **ID**: `discord-send-error-001`
- **Position**: [2680, 480]
- **Parameters**: Sends user-friendly error message
- **Purpose**: Notifies user of workflow failures

#### Log Error to External Service
- **Type**: `n8n-nodes-base.httpRequest`
- **Version**: 4.2
- **ID**: `http-log-error-001`
- **Position**: [2680, 620]
- **Parameters**:
  ```json
  {
    "url": "=https://your-logging-service.com/errors",
    "method": "POST",
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        {"name": "error", "value": "={{ JSON.stringify($json.error) }}"},
        {"name": "workflow", "value": "Chucky Discord RAG"},
        {"name": "timestamp", "value": "={{ $now.toISO() }}"}
      ]
    }
  }
  ```
- **Continue On Fail**: true
- **Purpose**: Logs errors to external monitoring service (optional)

---

## Connection Map

### Main Flow
```
Discord Trigger → Extract Message Data → Route by Input Type
                                           ├─ Output 0 (has attachments)
                                           │   → Download Attachment
                                           │   → Gemini Vision Analysis
                                           │   → Parse Vision Response
                                           │   → Check Confidence
                                           │       ├─ True → RAG Retrieval
                                           │       └─ False → Ask for Clarification
                                           └─ Output 1 (text only)
                                               → Set Text Query
                                               → RAG Retrieval

RAG Retrieval → Merge Analysis + RAG → Chucky AI Agent → Iteration Loop → Format Discord Response → Send Troubleshooting Steps
```

### AI Component Connections
```
Gemini Embeddings (ai_embedding)
  ├─ → RAG Retrieval
  └─ → Vector Store Tool

Postgres Chat Memory (ai_memory) → Chucky AI Agent

xAI Grok Model (ai_languageModel) → Chucky AI Agent

Tools (ai_tool) → Chucky AI Agent
  ├─ Vector Store Tool
  ├─ Code Analysis Tool
  └─ External Search Tool
```

### Error Flow
```
Error Trigger → Send Error Message
             └─ → Log Error to External Service
```

---

## Node Patterns & Best Practices

### 1. Credential References
All credential IDs are placeholders:
- `DISCORD_CREDENTIAL_ID`
- `GOOGLE_CREDENTIAL_ID`
- `GOOGLE_PALM_API_ID`
- `SUPABASE_CREDENTIAL_ID`
- `XAI_CREDENTIAL_ID`
- `POSTGRES_CREDENTIAL_ID`
- `BRAVE_API_CREDENTIAL_ID`

User must update these after import.

### 2. Retry Logic
Applied to nodes that may fail due to API issues:
- Download Attachment: maxTries=3
- Send Discord Messages: maxTries=3
- Vision Analysis: (handled by n8n automatically)

### 3. Position Grid
Nodes are positioned on a logical grid:
- Trigger: x=-200
- Data extraction: x=0-500
- Processing: x=500-1500
- AI Agent: x=1500-2000
- Output: x=2000-2700
- Y-axis varies by branch (200-600 range)

### 4. Naming Conventions
- IDs: `{type}-{name}-{number}` (e.g., `discord-trigger-001`)
- Names: Descriptive (e.g., "Extract Message Data", "Chucky AI Agent")
- Consistency: All nodes use clear, actionable names

### 5. Data Flow Patterns
- **Extraction**: Use Set/Edit Fields nodes to structure data early
- **Routing**: Use Switch nodes for conditional branching
- **Transformation**: Use Code nodes for complex logic
- **Merging**: Use Merge nodes to combine parallel branches
- **Iteration**: Use SplitInBatches for loops

---

## Extension Points

### Adding New Nodes
To add new functionality:

1. **Before AI Agent**:
   - Add pre-processing nodes between Merge and AI Agent
   - Example: Add sentiment analysis, language detection

2. **As Agent Tool**:
   - Create new tool node
   - Connect ai_tool output to AI Agent ai_tool input
   - Update agent prompt to describe tool usage

3. **After AI Agent**:
   - Add post-processing nodes between AI Agent and Format Response
   - Example: Add translation, summary generation

4. **Parallel Branch**:
   - Branch from Switch node
   - Create independent processing chain
   - Merge back before AI Agent if needed

### Modifying Existing Nodes

**To change LLM**:
- Replace "xAI Grok Model" with "Anthropic Chat Model"
- Update ai_languageModel connection
- Adjust temperature/max tokens as needed

**To add more tools**:
- Add new tool nodes (Calculator, Workflow, custom HTTP)
- Connect to AI Agent via ai_tool
- Update agent system message to describe new tools

**To change vector store**:
- Replace Supabase with Pinecone/Weaviate/Qdrant
- Update embedding dimension if needed
- Reconnect ai_embedding connections

---

## Performance Optimization

### Current Bottlenecks
1. **Vision Analysis**: ~3-5 seconds per image
2. **RAG Retrieval**: ~1-2 seconds for vector search
3. **AI Agent**: Variable (5-30 seconds depending on complexity)
4. **Total**: ~10-40 seconds per query

### Optimization Strategies
1. **Caching**: Store frequent queries and responses
2. **Parallel Processing**: Use multiple AI Agent instances
3. **Reduce Iterations**: Lower max iterations from 10 to 5
4. **Optimize Embeddings**: Use smaller model if accuracy permits
5. **Batch Processing**: Queue multiple requests

---

**Last Updated**: 2025-11-03
**Workflow Version**: 1.0
**Node Count**: 25
**Total Connections**: 27
