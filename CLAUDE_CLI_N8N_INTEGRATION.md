# Integrating Claude CLI with Web-Hosted n8n

**Goal:** Set up Claude CLI on your Hostinger VPS so Claude Code can help manage your n8n instance at n8n.maintpc.com

**Date:** 2025-11-03

---

## 🎯 What This Enables

Once set up, you'll be able to:
- Ask Claude to inspect and debug your n8n workflows
- Have Claude make changes to workflows via API
- Troubleshoot issues on your production n8n
- Create and test workflows with Claude's help
- Monitor n8n executions and logs
- Automate n8n management tasks

---

## 📋 Prerequisites

**What you need:**
- ✅ Hostinger VPS with n8n running (n8n.maintpc.com)
- ✅ SSH access to your VPS
- ✅ Claude API key (you have this)
- ✅ n8n API key (we'll generate this)
- ⚠️ Node.js installed on VPS (we'll verify/install)

---

## 🚀 Installation Steps

### Step 1: SSH into Your Hostinger VPS

```bash
# From your Windows machine (PowerShell or WSL)
ssh root@your-vps-ip
# Or if you have a specific user:
ssh username@n8n.maintpc.com
```

**Don't have SSH set up?**
- Check Hostinger panel for SSH credentials
- Enable SSH access in Hostinger VPS settings
- Or use Hostinger's web terminal

---

### Step 2: Install Node.js (if not already installed)

Check if Node.js is installed:
```bash
node --version
npm --version
```

If not installed:
```bash
# For Ubuntu/Debian (most Hostinger VPS use this)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x
```

---

### Step 3: Install Claude CLI on VPS

```bash
# Install Claude CLI globally
npm install -g @anthropic-ai/claude-cli

# Verify installation
claude --version
```

---

### Step 4: Configure Claude CLI with Your API Key

```bash
# Initialize Claude CLI
claude config set apiKey your-claude-api-key-here

# Test the connection
claude "Hello, can you help me with n8n?"
```

**Get your Claude API key from:**
- Claude Desktop settings
- Or generate new one at: https://console.anthropic.com/settings/keys

---

### Step 5: Generate n8n API Key

**Option A: Via n8n UI**
1. Open: https://n8n.maintpc.com
2. Go to **Settings** → **API**
3. Click **Create API Key**
4. Name it: "Claude CLI Integration"
5. **Copy the key** (you won't see it again!)

**Option B: Via Environment Variable** (if you have access to docker-compose)
```bash
# Check your current docker-compose.yml
cat docker-compose.yml | grep N8N_API

# If not set, add to your n8n container:
environment:
  - N8N_API_KEY_AUTH=true
```

---

### Step 6: Configure n8n API Access for Claude

Create a configuration file on your VPS:

```bash
# Create config directory
mkdir -p ~/.config/n8n-claude

# Create config file
nano ~/.config/n8n-claude/config.json
```

**Add this configuration:**
```json
{
  "n8n": {
    "baseUrl": "https://n8n.maintpc.com",
    "apiKey": "your-n8n-api-key-here",
    "version": "api/v1"
  },
  "claude": {
    "model": "claude-3-5-sonnet-20241022",
    "maxTokens": 4096
  }
}
```

Save and exit (Ctrl+X, Y, Enter in nano)

---

### Step 7: Create Helper Scripts for Claude

Let's create some utility scripts that Claude can use:

**Script 1: List all workflows**
```bash
cat > ~/n8n-list-workflows.sh << 'EOF'
#!/bin/bash
source ~/.config/n8n-claude/config.json
N8N_URL="https://n8n.maintpc.com/api/v1/workflows"
N8N_KEY="your-n8n-api-key-here"

curl -s -H "X-N8N-API-KEY: ${N8N_KEY}" "${N8N_URL}" | jq '.'
EOF

chmod +x ~/n8n-list-workflows.sh
```

**Script 2: Get specific workflow**
```bash
cat > ~/n8n-get-workflow.sh << 'EOF'
#!/bin/bash
WORKFLOW_ID=$1
N8N_URL="https://n8n.maintpc.com/api/v1/workflows/${WORKFLOW_ID}"
N8N_KEY="your-n8n-api-key-here"

curl -s -H "X-N8N-API-KEY: ${N8N_KEY}" "${N8N_URL}" | jq '.'
EOF

chmod +x ~/n8n-get-workflow.sh
```

**Script 3: Get execution logs**
```bash
cat > ~/n8n-get-executions.sh << 'EOF'
#!/bin/bash
WORKFLOW_ID=$1
N8N_URL="https://n8n.maintpc.com/api/v1/executions"
N8N_KEY="your-n8n-api-key-here"

curl -s -H "X-N8N-API-KEY: ${N8N_KEY}" "${N8N_URL}?workflowId=${WORKFLOW_ID}" | jq '.'
EOF

chmod +x ~/n8n-get-executions.sh
```

---

### Step 8: Test the Integration

**Test 1: List workflows via Claude**
```bash
claude "Run the command: ~/n8n-list-workflows.sh and tell me what workflows exist"
```

**Test 2: Get workflow details**
```bash
claude "Run: ~/n8n-get-workflow.sh ET0fWxeEeuWDQCTp and summarize the workflow"
```

**Test 3: Check recent executions**
```bash
claude "Run: ~/n8n-get-executions.sh ET0fWxeEeuWDQCTp and tell me if there are any errors"
```

---

## 🔧 Advanced: Set Up MCP Server for n8n

For even deeper integration, create a custom MCP server:

**Install n8n MCP Server (if available):**
```bash
# Check if n8n MCP exists
npm search n8n-mcp

# Or use the one you already have locally
# We can deploy the n8n-mcp from your local setup to VPS
```

**Create custom MCP server config:**
```bash
mkdir -p ~/.config/claude-code/mcp-servers
nano ~/.config/claude-code/mcp-servers/n8n-production.json
```

**Add configuration:**
```json
{
  "n8n-production": {
    "command": "npx",
    "args": ["n8n-mcp"],
    "env": {
      "N8N_API_KEY": "your-n8n-api-key",
      "N8N_BASE_URL": "https://n8n.maintpc.com"
    }
  }
}
```

---

## 🎨 Use Cases: What Claude Can Now Do

### Use Case 1: Debug Workflow Issues
```bash
claude "Check the Chucky workflow on n8n.maintpc.com and tell me why it's failing"
```

### Use Case 2: Update Workflow Configuration
```bash
claude "In the Chucky workflow, change the Gemini model to gemini-2.0-flash-exp"
```

### Use Case 3: Monitor Executions
```bash
claude "Show me all failed executions from the last 24 hours on my n8n instance"
```

### Use Case 4: Create New Workflows
```bash
claude "Create a new n8n workflow that monitors my website uptime and sends alerts"
```

### Use Case 5: Optimize Performance
```bash
claude "Analyze the Chucky workflow and suggest performance optimizations"
```

---

## 🔐 Security Best Practices

**1. Secure API Keys**
```bash
# Store keys in environment variables, not in scripts
echo 'export N8N_API_KEY="your-key-here"' >> ~/.bashrc
echo 'export CLAUDE_API_KEY="your-key-here"' >> ~/.bashrc
source ~/.bashrc
```

**2. Restrict API Access**
```bash
# In n8n, create API key with limited permissions
# Only allow: read workflows, read executions, update workflows
```

**3. Use SSH Key Authentication**
```bash
# Generate SSH key on your local machine
ssh-keygen -t ed25519 -C "claude-cli-access"

# Copy to VPS
ssh-copy-id user@n8n.maintpc.com
```

**4. Set Up Firewall Rules**
```bash
# On VPS, restrict SSH access to your IP
sudo ufw allow from YOUR_IP to any port 22
sudo ufw enable
```

---

## 📊 Integration Architecture

```
Your Windows Machine (Claude Desktop)
         |
         | SSH Connection
         ↓
Hostinger VPS (n8n.maintpc.com)
         |
         ├── Claude CLI (installed)
         ├── Helper Scripts
         ├── n8n Docker Container
         └── n8n API (HTTPS)
              |
              ↓
         n8n Workflows (Chucky, etc.)
```

---

## 🤖 Phase 7: Chucky Manager - Unified Orchestration Layer

**Status:** ✅ Complete (2025-11-04)

The Chucky Manager is the latest addition to the Claude Code integration, providing a **single unified interface** for all n8n workflow operations.

### What Is It?

Instead of calling individual commands, you now have **one master command** that:
- Understands natural language requests
- Routes to appropriate sub-agents automatically
- Maintains session memory for follow-ups
- Validates all outputs for quality
- Handles errors gracefully
- Supports workflow templates

### Quick Start

```bash
# Single unified command
/chucky create a temperature monitoring node

# Complex request with plan
/chucky build a complete safety alert system with tests and docs

# Workflow template
/chucky production-ready ChuckyDiscordRAG.json

# Follow-up with session memory
/chucky add error handling to it
```

### Architecture

```
User Request (/chucky)
        ↓
Chucky Manager Agent
        ↓
    [Routes to]
        ↓
├─ n8n-workflow-expert (nodes, workflows)
├─ industrial-knowledge-curator (PDF docs)
├─ discord-integration-specialist (Discord config)
├─ documentation-maintainer (docs)
└─ testing-coordinator (tests)
        ↓
    [Validates Output]
        ↓
    Returns Result
```

### 5 Specialized Sub-Agents

1. **n8n-workflow-expert** - Building, debugging, optimizing n8n workflows
2. **industrial-knowledge-curator** - Scraping and formatting industrial documentation
3. **discord-integration-specialist** - Configuring Discord nodes and embeds
4. **documentation-maintainer** - Auto-generating and updating documentation
5. **testing-coordinator** - Creating test plans and validation scripts

### 6 Slash Commands

**Master Command:**
- `/chucky` - Unified natural language interface (⭐ **Recommended**)

**Specialized Commands:**
- `/chucky-node-builder` - Generate n8n nodes
- `/chucky-workflow-validator` - Validate workflows
- `/chucky-doc-generator` - Update documentation
- `/chucky-troubleshoot-builder` - Create troubleshooting guides
- `/chucky-test-scenario` - Generate tests
- `/chucky-embed-designer` - Design Discord embeds

### 4 Workflow Templates

Pre-configured multi-agent pipelines:

```bash
# Full production validation pipeline
/chucky production-ready ChuckyDiscordRAG.json

# Complete feature development
/chucky new-feature "Temperature monitoring with alerts"

# Troubleshoot and fix issues
/chucky debug ChuckyDiscordRAG.json "Discord not sending messages"

# Prepare for VPS deployment
/chucky deploy-prep ChuckyDiscordRAG.json
```

### Key Features

✅ **Session Memory** - Remembers context across conversation
✅ **Smart Routing** - Auto-determines simple vs complex requests
✅ **Quality Validation** - Checks all outputs before returning
✅ **Error Recovery** - Auto-retries failed operations
✅ **Workflow Templates** - Pre-built pipelines for common tasks
✅ **Natural Language** - No need to memorize command syntax

### Files Created

```
.claude/
├── agents/
│   ├── chucky-manager.md (604 lines)
│   ├── n8n-workflow-expert.md
│   ├── industrial-knowledge-curator.md
│   ├── discord-integration-specialist.md
│   ├── documentation-maintainer.md
│   └── testing-coordinator.md
├── commands/
│   ├── chucky.md (434 lines)
│   ├── chucky-node-builder.md
│   ├── chucky-workflow-validator.md
│   ├── chucky-doc-generator.md
│   ├── chucky-troubleshoot-builder.md
│   ├── chucky-test-scenario.md
│   └── chucky-embed-designer.md
└── settings.local.json

context/
├── project_overview.md
├── workflow_architecture.md
└── discord_config.md

Documentation:
├── CHUCKY_MANAGER_USER_GUIDE.md
├── CHUCKY_MANAGER_TESTING_GUIDE.md
└── MANAGER_IMPLEMENTATION_SUMMARY.md
```

### Usage Examples

**Simple Auto-Execute:**
```bash
/chucky create a webhook trigger node
# → Auto-executes, returns node JSON in ~20 seconds
```

**Complex Plan-First:**
```bash
/chucky build a pressure monitoring system with Discord alerts
# → Shows plan: 1) Build nodes, 2) Configure Discord, 3) Generate tests
# → Waits for approval
# → Executes pipeline
# → Returns complete package
```

**Session Memory:**
```bash
/chucky create a sensor monitoring node
/chucky add error handling to it        # "it" = sensor node
/chucky now generate tests for that     # "that" = sensor node with error handling
```

### Documentation

- **User Guide:** `CHUCKY_MANAGER_USER_GUIDE.md` - How to use the manager
- **Testing Guide:** `CHUCKY_MANAGER_TESTING_GUIDE.md` - 30+ test scenarios
- **Implementation Summary:** `MANAGER_IMPLEMENTATION_SUMMARY.md` - Technical details
- **Agent Definition:** `.claude/agents/chucky-manager.md` - Full specification
- **Command Reference:** `.claude/commands/chucky.md` - Complete usage guide

### Git Commits

Phase 7 implementation commits:
```bash
b81a092 - feat: add chucky-manager orchestration agent
77e7603 - feat: add /chucky unified slash command
b79c6a3 - test: add comprehensive manager testing guide
[next]  - docs: add manager documentation
```

### Next Steps with Manager

1. **Try the manager:**
   ```bash
   /chucky create a Code node that parses sensor data
   ```

2. **Run a workflow template:**
   ```bash
   /chucky production-ready ChuckyDiscordRAG.json
   ```

3. **Build a complete feature:**
   ```bash
   /chucky new-feature "Temperature monitoring with email alerts"
   ```

4. **Test all scenarios:**
   - See `CHUCKY_MANAGER_TESTING_GUIDE.md` for comprehensive test suite

### Benefits

**Before Manager:**
```bash
# Had to know which command to use
/chucky-node-builder "create node"
/chucky-workflow-validator workflow.json
/chucky-test-scenario workflow.json
/chucky-doc-generator --update
# 4 separate commands, manual coordination
```

**With Manager:**
```bash
# One command, natural language
/chucky create a node, validate it, test it, and update docs
# Manager coordinates everything automatically
```

---

## 🐛 Troubleshooting

### Issue: Can't SSH into VPS

**Check:**
1. Hostinger panel - is SSH enabled?
2. Do you have the correct credentials?
3. Is firewall blocking port 22?

**Fix:**
- Enable SSH in Hostinger VPS settings
- Use Hostinger web terminal as alternative
- Check VPS firewall rules

### Issue: Claude CLI not found

**Fix:**
```bash
# Check npm global install path
npm config get prefix

# Add to PATH if needed
echo 'export PATH="$PATH:$(npm config get prefix)/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Issue: n8n API returns 401 Unauthorized

**Check:**
1. Is API key correct?
2. Is API authentication enabled in n8n?
3. Is key included in request header?

**Fix:**
```bash
# Test API manually
curl -H "X-N8N-API-KEY: your-key" https://n8n.maintpc.com/api/v1/workflows

# Check n8n environment variables
docker exec n8n-container env | grep N8N_API
```

---

## 🚀 Next Steps

Once this is set up, you can:

1. **From Claude Desktop:**
   - Ask me to check your n8n workflows
   - Have me debug execution errors
   - Request workflow modifications
   - Get real-time monitoring insights

2. **From Your VPS (via SSH):**
   ```bash
   # Start interactive Claude session
   claude

   # Then ask questions like:
   "List all my n8n workflows"
   "Show me recent errors in Chucky workflow"
   "Update the email notification settings"
   ```

3. **Automate with Cron:**
   ```bash
   # Add to crontab for automated monitoring
   crontab -e

   # Add line:
   0 * * * * claude "Check n8n.maintpc.com for errors and email me a summary"
   ```

---

## 📝 Quick Reference Commands

**On your local machine (Windows):**
```powershell
# SSH to VPS
ssh user@n8n.maintpc.com

# Run Claude command remotely
ssh user@n8n.maintpc.com "claude 'list my n8n workflows'"
```

**On the VPS:**
```bash
# Interactive Claude session
claude

# One-off command
claude "show me the Chucky workflow status"

# With workflow scripts
~/n8n-list-workflows.sh
~/n8n-get-workflow.sh WORKFLOW_ID
~/n8n-get-executions.sh WORKFLOW_ID
```

---

## 📁 Files Created on VPS

After setup, you'll have:
```
~/.config/n8n-claude/config.json
~/.bashrc (with API keys)
~/n8n-list-workflows.sh
~/n8n-get-workflow.sh
~/n8n-get-executions.sh
```

---

## ✅ Success Criteria

You'll know it's working when:
1. ✅ Claude CLI responds on VPS
2. ✅ Helper scripts return n8n data
3. ✅ You can ask Claude to inspect workflows
4. ✅ Claude can make API calls to n8n
5. ✅ No authentication errors

---

**Ready to proceed?** Start with Step 1 (SSH into VPS) and follow each step sequentially.

**Estimated setup time:** 20-30 minutes
**Difficulty:** Intermediate 🔧🔧

**Benefits:** Full Claude integration with production n8n! 🎉
