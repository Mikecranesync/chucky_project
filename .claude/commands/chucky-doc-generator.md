# Chucky Documentation Generator

Auto-generate and update documentation when workflows change.

## Task

You are the `/chucky-doc-generator` command. Your job is to automatically generate or update documentation based on workflow changes, ensuring docs stay synchronized with code.

## Context Files to Read

Read these to understand what to document:
- `context/workflow_architecture.md` - Technical architecture patterns
- `context/project_overview.md` - System capabilities and purpose
- Existing markdown documentation files in the project

## Sub-Agent to Use

Invoke the **documentation-maintainer** sub-agent to handle documentation generation and updates.

## Input Formats

### 1. Generate New Documentation
```
/chucky-doc-generator --type [setup|architecture|api|user-guide] --workflow ChuckyDiscordRAG.json
```

### 2. Update Existing Documentation
```
/chucky-doc-generator --update SETUP_GUIDE.md --compare ChuckyDiscordRAG_old.json ChuckyDiscordRAG_new.json
```

### 3. Generate Changelog
```
/chucky-doc-generator --changelog --from v1.0 --to v1.1
```

## Documentation Types

### 1. Setup Guides
**Purpose**: Help users configure and deploy the workflow
**Includes**:
- Prerequisites (accounts, credentials, software)
- Step-by-step installation instructions
- Configuration checklists
- Troubleshooting common issues
- Testing and validation steps

**Template**:
```markdown
# [System Name] Setup Guide

## Prerequisites
- [ ] n8n instance (self-hosted or cloud)
- [ ] Discord bot created
- [ ] Supabase account with pgvector
- [ ] API keys: [list all required]

## Installation Steps

### Step 1: Import Workflow
1. Open n8n
2. Go to Workflows → Import
3. Select `[filename].json`

### Step 2: Configure Credentials
[Detailed credential setup for each service]

### Step 3: Update Configuration
[Node-specific settings to customize]

### Step 4: Test
[How to verify everything works]

## Troubleshooting
**Issue**: [Common problem]
**Solution**: [Fix steps]

## Next Steps
[What to do after setup is complete]
```

### 2. Architecture Documentation
**Purpose**: Explain technical design and data flow
**Includes**:
- System architecture diagram (text-based)
- Node inventory with descriptions
- Connection map
- Data flow patterns
- Extension points

**Template**:
```markdown
# [System Name] Architecture

## Overview
[High-level description]

## Data Flow
[Text-based flowchart showing trigger → processing → output]

## Node Inventory
### Trigger Nodes
- **[Node Name]** (`[type]`): [Purpose]

### Processing Nodes
[List each node with ID, type, and function]

## Connection Map
[Show how nodes connect and what data flows between them]

## Extension Points
[How to add new features]
```

### 3. API Documentation
**Purpose**: Document HTTP endpoints, webhooks, and integrations
**Includes**:
- Endpoint URLs
- Request/response formats
- Authentication methods
- Rate limits
- Example calls

### 4. User Guides
**Purpose**: Teach end-users how to interact with the system
**Includes**:
- Command reference
- Usage examples
- Best practices
- FAQ

## Changelog Generation

When comparing workflow versions, automatically detect and document:

### Changes to Detect
1. **Nodes Added**: New node IDs not in old version
2. **Nodes Removed**: Node IDs missing in new version
3. **Nodes Modified**: Same ID but different parameters
4. **Connections Changed**: New or removed connections
5. **Credentials Updated**: Changed credential references
6. **Position Changes**: Nodes moved on canvas (minor)

### Changelog Format
```markdown
# Changelog: v[old] → v[new]

**Date**: [ISO timestamp]

## Summary
- [X] nodes added
- [Y] nodes removed
- [Z] nodes modified
- [W] connections changed

## Added Nodes
1. **[Node Name]** (`[id]`, type: `[type]`)
   - Purpose: [What it does]
   - Position: [x, y]
   - Connections: [What it connects to]

## Removed Nodes
1. **[Node Name]** (`[id]`)
   - Reason: [Why removed if known]

## Modified Nodes
1. **[Node Name]** (`[id]`)
   - Changed: [parameter name]
   - Old value: `[old]`
   - New value: `[new]`
   - Impact: [What this affects]

## Connection Changes
- Added: [source] → [target]
- Removed: [source] ╳ [target]

## Breaking Changes
⚠️ [List any changes that require user action]

## Migration Guide
[If breaking changes exist, provide migration steps]

## Testing Recommendations
Based on changes, test these scenarios:
1. [Test scenario based on modified nodes]
```

## Auto-Update Existing Docs

When updating existing documentation:

1. **Preserve Structure**: Keep existing sections and formatting
2. **Smart Updates**: Only modify sections affected by workflow changes
3. **Add Changelog**: Append changelog to bottom of document
4. **Version Increment**: Update version numbers
5. **Timestamp**: Add "Last Updated" date
6. **Highlight Changes**: Use callout blocks for new content

Example update pattern:
```markdown
> **Updated 2025-11-04**: Added new sentiment analysis node to processing pipeline

[Existing content...]

## Changelog

### v1.1 (2025-11-04)
- Added sentiment analysis capability
- Updated Discord embed formatting
- Fixed confidence threshold bug
```

## Documentation Best Practices

### 1. Clarity
- Use simple language
- Define technical terms
- Provide examples
- Include screenshots or diagrams where helpful

### 2. Completeness
- Cover all setup steps
- List all prerequisites
- Document error messages
- Include troubleshooting section

### 3. Maintainability
- Use consistent formatting
- Follow markdown best practices
- Include table of contents for long docs
- Add navigation links

### 4. Accuracy
- Test all instructions before publishing
- Verify command examples work
- Check that credential names match
- Validate file paths and URLs

## Integration with Git

After generating documentation:
1. Save to appropriate directory
2. Add to git staging
3. Create commit with descriptive message
4. Suggest commit message: `docs: [what was documented]`

Example: `docs: add setup guide for Discord RAG workflow v1.1`

## Example Usage

### Generate Setup Guide
```
/chucky-doc-generator --type setup --workflow ChuckyDiscordRAG.json
```

**Output**: `CHUCKY_DISCORD_RAG_SETUP.md` with complete setup instructions

### Update After Changes
```
/chucky-doc-generator --update CHUCKY_DISCORD_RAG_SETUP.md --compare ChuckyDiscordRAG_old.json ChuckyDiscordRAG.json
```

**Output**: Updated setup guide with changelog showing what changed

### Generate Architecture Docs
```
/chucky-doc-generator --type architecture --workflow ChuckyDiscordRAG.json
```

**Output**: `CHUCKY_ARCHITECTURE.md` with technical design documentation

## Quality Checks

Before finalizing documentation, verify:
- ✅ All links work
- ✅ Code examples are syntactically correct
- ✅ File paths are accurate
- ✅ Commands can be copy-pasted and run
- ✅ Spelling and grammar are correct
- ✅ Formatting is consistent
- ✅ Table of contents matches headings
- ✅ Version numbers are updated

## Automation Opportunities

Suggest automation when:
- Multiple docs need updating simultaneously
- Workflow changes frequently
- Documentation drift is detected (code doesn't match docs)
- Release notes need to be generated

## Notes

- Focus on user value (what they need to know)
- Separate beginner and advanced content
- Use progressive disclosure (simple first, details later)
- Keep docs DRY (Don't Repeat Yourself) - link instead of duplicate
