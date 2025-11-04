# Chucky Project Overview

## Project Name
**Chucky Discord RAG Agent for Industrial Maintenance**

## Purpose
Chucky is an advanced AI-powered troubleshooting assistant that helps industrial maintenance technicians diagnose and resolve equipment issues through natural language interaction on Discord.

## Core Capabilities

### 1. Multi-Modal Input Processing
- **Text queries**: Plain language troubleshooting requests (e.g., "motor won't start")
- **Image analysis**: Equipment photos analyzed by Google Gemini Vision AI
- **Document processing**: PDF manuals and technical documentation

### 2. Retrieval-Augmented Generation (RAG)
- **Vector database**: Supabase pgvector stores industrial documentation embeddings
- **Semantic search**: Retrieves top 5 most relevant manual sections (similarity ≥ 0.7)
- **Google Gemini Embeddings**: 768-dimensional vectors for document matching
- **Knowledge base**: Pre-populated with equipment manuals, safety procedures, troubleshooting guides

### 3. AI Agent with Tools
- **LLM Options**: xAI Grok or Anthropic Claude 3.5 Sonnet
- **Agent Pattern**: ReAct (Reasoning + Acting) with up to 10 iterations
- **Tools Available**:
  - Vector Store Tool (RAG retrieval)
  - Code Tool (custom analysis logic)
  - HTTP Tool (external web searches via Brave API)
- **Session Memory**: Postgres Chat Memory for conversation context

### 4. Discord Integration
- **Trigger**: Built-in Discord node (n8n-nodes-base.discordTrigger)
- **Command Prefix**: `!` (e.g., `!troubleshoot HVAC not cooling`)
- **Output Format**: Markdown-formatted numbered lists with safety warnings
- **Response Features**:
  - User mentions for notifications
  - Structured troubleshooting steps
  - Retrieved documentation citations
  - Safety alerts with ⚠️ indicators

## System Architecture

### Platform
- **Orchestration**: n8n workflow automation
- **Deployment**: Self-hosted or n8n Cloud
- **Node Count**: 25 core nodes (optimized from original 100+)

### Tech Stack
| Component | Technology | Version/Model |
|-----------|-----------|---------------|
| Vision AI | Google Gemini | gemini-1.5-pro-latest |
| Embeddings | Google Gemini | embedding-001 |
| Vector DB | Supabase | pgvector extension |
| LLM | xAI Grok / Claude | grok-beta / claude-3-5-sonnet |
| Memory | PostgreSQL | Chat histories |
| Discord | Built-in n8n node | discordTrigger v1 |
| Search Fallback | Brave API | REST API |

### Data Flow
```
Discord (!command)
  ↓
Extract Message Data (query, sessionID, attachments)
  ↓
Switch Router (by input type)
  ├─ Has Attachment → Download → Gemini Vision → Parse JSON → Confidence Check
  │                                                               ├─ <80% → Ask Clarification
  │                                                               └─ ≥80% → RAG Retrieval
  └─ Text Only → RAG Retrieval
       ↓
Merge (Vision Analysis + RAG Documents)
  ↓
AI Agent (ReAct loop with tools)
  ↓
Iteration (SplitInBatches for refinement)
  ↓
Format Response (Markdown)
  ↓
Discord Send (Final Answer)
```

## Key Features

### Confidence-Based Clarification
- Vision analysis confidence threshold: 80%
- Below threshold: Bot asks for more details
- Above threshold: Proceeds to RAG retrieval

### External Search Fallback
- If no relevant documents in vector store (similarity <0.7)
- Falls back to Brave Search API for web results
- Integrates external knowledge into response

### Error Handling
- Error Trigger node catches workflow failures
- Sends error message to Discord
- Logs errors to external service (optional)
- Retry logic: maxTries=3 for API nodes

### Session Management
- User-specific chat memory via Discord user IDs
- Up to 10 messages remembered per session
- Enables follow-up questions and contextual responses

## Target Use Cases

### Primary
1. **Equipment Troubleshooting**
   - Motor failures, HVAC issues, electrical problems
   - Step-by-step diagnostic guidance
   - Safety-first approach

2. **Safety Compliance**
   - OSHA, NFPA, ASME standard references
   - Automated safety hazard detection in images
   - Lockout/tagout reminders

3. **Documentation Retrieval**
   - Instant manual lookup
   - Equipment specifications
   - Maintenance procedures

4. **Knowledge Retention**
   - AI remembers all procedures
   - Consistent troubleshooting approach
   - No tribal knowledge loss

## Current Status

### Implemented (v1.0)
- ✅ Complete n8n workflow (ChuckyDiscordRAG.json)
- ✅ Discord bot integration
- ✅ Multi-modal input processing
- ✅ RAG pipeline with Supabase
- ✅ AI Agent with 3 tools
- ✅ Session memory
- ✅ Error handling
- ✅ Comprehensive documentation (56,000+ words)

### Pending Setup
- ⏳ Discord bot creation and configuration
- ⏳ Supabase vector store population
- ⏳ Knowledge base ingestion (50-100 PDFs needed)
- ⏳ Credential configuration (6 services)
- ⏳ Production deployment

### Future Enhancements
- 🔮 Interactive Discord buttons (requires community node)
- 🔮 Slash commands (`/troubleshoot` instead of `!troubleshoot`)
- 🔮 Thread-based conversations
- 🔮 Multi-language support
- 🔮 Equipment monitoring integration
- 🔮 Automated work order generation

## Project Files

### Workflow
- `ChuckyDiscordRAG.json` - Main n8n workflow (importable)

### Documentation
- `CHUCKY_DISCORD_RAG_SETUP.md` - Complete setup guide (17,000 words)
- `CHUCKY_RAG_DELIVERY_SUMMARY.md` - Project overview and quick start
- `Grok chucky redo 1.pdf` - Original Product Requirements Document

### Reference (Alternative Approach)
- `DISCORD_SETUP_GUIDE.md` - Interactive Discord setup (community node)
- `DISCORD_WORKFLOW_IMPLEMENTATION.md` - Button-based implementation specs
- `DISCORD_MIGRATION_MASTER_GUIDE.md` - Migration strategy

### Context (for Claude Code)
- This directory contains markdown files for AI agent context

## Development Workflow

### Current Process
1. Modify `ChuckyDiscordRAG.json` manually in n8n UI
2. Export JSON for version control
3. Manually update documentation
4. Test in n8n execution environment
5. Deploy to production

### Desired Future (with Claude Code)
1. Describe desired feature in natural language
2. Claude Code generates n8n nodes automatically
3. Validates JSON and connections
4. Auto-updates documentation
5. Generates test scenarios
6. One-command deployment

## Contact & Resources

### Technical Resources
- n8n Documentation: https://docs.n8n.io/
- Supabase Vector Guide: https://supabase.com/docs/guides/ai
- Discord Developer Portal: https://discord.com/developers/
- Google Gemini API: https://ai.google.dev/docs

### Project Repository
- Local: `C:\Users\hharp\chucky_project\`
- Version Control: (TBD - Git repository)

---

**Last Updated**: 2025-11-03
**Version**: 1.0
**Status**: Production-ready, pending deployment
