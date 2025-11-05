# n8n Workflow Management Scripts

This directory contains bash scripts for managing n8n workflows **without requiring GitHub Actions** (completely free approach).

## Overview

These scripts replace GitHub Actions functionality with manual execution:

| Script | Replaces | Purpose |
|--------|----------|---------|
| `validate-workflows.sh` | ci-validate.yml | Validate workflow JSON + credential scanning |
| `deploy-to-n8n.sh` | cd-deploy-staging.yml<br>issueops-production.yml | Deploy workflows to n8n Cloud |
| `security-scan.sh` | security-scan.yml | Scan for exposed credentials |
| `create-maintenance-issue.sh` | cron-maintenance.yml | Create weekly maintenance issues |

## Prerequisites

### Required Tools

1. **jq** (JSON processor)
   - Windows: `choco install jq` or download from https://stedolan.github.io/jq/download/
   - Mac: `brew install jq`
   - Linux: `apt-get install jq`

2. **curl** (HTTP client)
   - Usually pre-installed on most systems

3. **GitHub CLI** (`gh`) - For issue/milestone management
   - Install: https://cli.github.com/
   - Authenticate: `gh auth login`

### Environment Variables

Create a `.env` file in the project root (already done):

```bash
# Production n8n (required)
N8N_URL=https://your-instance.app.n8n.cloud
N8N_API_KEY=your_api_key_here

# Staging n8n (optional)
N8N_STAGING_URL=https://staging.app.n8n.cloud
N8N_STAGING_API_KEY=staging_api_key_here
```

Load environment variables:
```bash
source .env
# or
export $(cat .env | xargs)
```

## Script Documentation

### 1. validate-workflows.sh

**Purpose:** Validate n8n workflow JSON files before deployment

**Usage:**
```bash
# Validate single workflow
./scripts/validate-workflows.sh ChuckyDiscordRAG.json

# Validate all workflows
./scripts/validate-workflows.sh

# Validate multiple specific workflows
./scripts/validate-workflows.sh User_Auth_Workflow.json Payment_Management_Workflow.json
```

**What it checks:**
- ✅ JSON syntax validity
- ✅ Required n8n fields (nodes, connections)
- ⚠️ Disabled nodes (warning)
- 🔴 Exposed credentials (critical)

**Exit codes:**
- `0` - All validations passed
- `1` - Validation errors found
- `2` - Credentials detected

**Example output:**
```
=========================================
n8n Workflow Validation
=========================================
Files to validate:
  - ChuckyDiscordRAG.json

Validating: ChuckyDiscordRAG.json
✓ Valid workflow: Chucky Discord RAG Agent
  ID: abc123
  Nodes: 25, Connections: 24

=========================================
Validation Summary
=========================================
Validated: 1
Errors: 0
Warnings: 0
All validations PASSED ✓
=========================================
```

---

### 2. deploy-to-n8n.sh

**Purpose:** Deploy workflows to n8n Cloud instance

**Usage:**
```bash
# Deploy single workflow to production
./scripts/deploy-to-n8n.sh --env production ChuckyDiscordRAG.json

# Deploy multiple workflows to staging
./scripts/deploy-to-n8n.sh --env staging User_Auth_Workflow.json Quota_Enforcement_Workflow.json

# Deploy all workflows
./scripts/deploy-to-n8n.sh --env production --all

# Show help
./scripts/deploy-to-n8n.sh --help
```

**Options:**
- `--env [production|staging]` - Target environment (default: production)
- `--all` - Deploy all workflow JSON files
- `-h, --help` - Show help message

**Behavior:**
- Validates JSON before deploying
- Auto-detects create vs. update (based on workflow ID in JSON)
- Prompts for confirmation before deploying
- Shows detailed deployment results

**Requirements:**
- `N8N_URL` and `N8N_API_KEY` must be set (for production)
- `N8N_STAGING_URL` and `N8N_STAGING_API_KEY` (for staging, optional)

**Example output:**
```
=========================================
n8n Workflow Deployment
=========================================
Environment: production
n8n URL: https://mikecranesync.app.n8n.cloud
=========================================
Workflows to deploy: 1
  - ChuckyDiscordRAG.json

Deploy to production? (y/N): y

=========================================
Deploying: ChuckyDiscordRAG.json
=========================================
Updating workflow: Chucky Discord RAG Agent
✓ Successfully deployed (HTTP 200)

=========================================
Deployment Summary
=========================================
Environment: production
Succeeded: 1
Failed: 0
All deployments successful ✓
=========================================
```

---

### 3. security-scan.sh

**Purpose:** Scan workflow files for exposed credentials

**Usage:**
```bash
# Run security scan
./scripts/security-scan.sh

# Run scan and auto-create GitHub issue if findings
./scripts/security-scan.sh --create-issue
```

**What it scans for:**
- Google API keys (`AIza...`)
- OpenAI API keys (`sk-...`)
- Stripe secret keys (`sk_test_...`, `sk_live_...`)
- Discord bot tokens
- Supabase tokens
- Generic API key patterns

**Exit codes:**
- `0` - No credentials found
- `1` - Credentials detected

**Example output (clean):**
```
=========================================
Security Scan for Exposed Credentials
=========================================

=========================================
Scan Summary
=========================================
Files scanned: 11
Findings: 0
✓ No obvious credentials detected
=========================================
```

**Example output (findings):**
```
=========================================
Security Scan for Exposed Credentials
=========================================

⚠ ALERT: Potential Google API found in ChuckyDiscordRAG.json

=========================================
Scan Summary
=========================================
Files scanned: 11
Findings: 1
⚠ SECURITY ALERT: Credentials may be exposed

Files with potential credentials:
  - ChuckyDiscordRAG.json (Google API)
=========================================
```

---

### 4. create-maintenance-issue.sh

**Purpose:** Create weekly maintenance checklist GitHub issue

**Usage:**
```bash
# Create issue for current week
./scripts/create-maintenance-issue.sh

# Create issue for specific week
./scripts/create-maintenance-issue.sh --date 2025-11-12
```

**What it includes:**
- Security tasks checklist
- Repository tasks checklist
- n8n workflow health checks
- Database tasks
- Monitoring & analytics review
- Documentation updates
- Deployment review

**Requirements:**
- GitHub CLI (`gh`) must be installed and authenticated

**Example output:**
```
Creating maintenance issue for week of 2025-11-12...
✓ Created issue #10
View: gh issue view 10
URL: https://github.com/Mikecranesync/chucky_project/issues/10
```

---

## Typical Workflows

### Deploying a New Workflow

```bash
# 1. Validate the workflow
./scripts/validate-workflows.sh ChuckyDiscordRAG.json

# 2. Run security scan
./scripts/security-scan.sh

# 3. Deploy to production
source .env
./scripts/deploy-to-n8n.sh --env production ChuckyDiscordRAG.json

# 4. Create deployment issue for tracking (manual via GitHub UI or gh CLI)
gh issue create \
    --title "[DEPLOY] ChuckyDiscordRAG.json completed" \
    --label "type:deployment,status:deployed,component:n8n" \
    --body "Successfully deployed ChuckyDiscordRAG.json to production"
```

### Weekly Maintenance Routine

```bash
# 1. Create weekly maintenance issue
./scripts/create-maintenance-issue.sh

# 2. Run security scan
./scripts/security-scan.sh --create-issue

# 3. Validate all workflows
./scripts/validate-workflows.sh

# 4. Check workflow status in n8n Cloud (manual via UI)

# 5. Complete checklist in maintenance issue
gh issue view <issue-number>
# Complete tasks and close issue when done
```

### Pre-Commit Workflow

Before committing workflow changes:

```bash
# 1. Validate changes
./scripts/validate-workflows.sh

# 2. Security scan
./scripts/security-scan.sh

# 3. If all pass, commit
git add .
git commit -m "feat: update workflow"
git push
```

## Helper Scripts

### helpers/validation.sh

Shared validation functions:
- `check_dependencies()` - Verify jq is installed
- `validate_json_syntax()` - Check JSON syntax
- `validate_n8n_structure()` - Check required n8n fields
- `get_workflow_metadata()` - Extract workflow metadata
- `count_disabled_nodes()` - Count disabled nodes
- `scan_for_credentials()` - Check for exposed credentials

### helpers/n8n-api.sh

n8n Cloud API interaction functions:
- `n8n_deploy_workflow()` - Deploy workflow via API
- `n8n_get_workflow()` - Fetch workflow by ID
- `n8n_list_workflows()` - List all workflows
- `n8n_toggle_workflow()` - Activate/deactivate workflow

### helpers/github-api.sh

GitHub API interaction functions:
- Functions for creating issues, adding labels, posting comments
- Search issues, update issue status
- (To be expanded as needed)

## Troubleshooting

### "jq: command not found"

Install jq:
- Windows: `choco install jq`
- Mac: `brew install jq`
- Linux: `apt-get install jq`

### "N8N_URL and N8N_API_KEY environment variables required"

Load your .env file:
```bash
source .env
# or on Windows Git Bash:
export $(cat .env | xargs)
```

### "401 Unauthorized" from n8n API

Check your API key:
1. Go to n8n Cloud → Settings → API
2. Verify the API key is correct
3. Update .env file with correct key

### "GitHub CLI (gh) is required"

Install GitHub CLI:
- Download from: https://cli.github.com/
- Authenticate: `gh auth login`

### Scripts not executable

Make scripts executable:
```bash
chmod +x scripts/*.sh
chmod +x scripts/helpers/*.sh
```

## Development

### Adding New Scripts

1. Create script in `scripts/` directory
2. Follow naming convention: `verb-noun.sh`
3. Add shebang: `#!/bin/bash`
4. Add error handling: `set -euo pipefail`
5. Add help option: `--help`
6. Document in this README
7. Test thoroughly before committing

### Modifying Existing Scripts

1. Test changes locally first
2. Update help text if behavior changes
3. Update this README if usage changes
4. Ensure backward compatibility where possible

## Migration from GitHub Actions

These scripts replace the following GitHub Actions workflows that were archived due to billing issues:

- `.github/workflows/ci-validate.yml` → `scripts/validate-workflows.sh`
- `.github/workflows/cd-deploy-staging.yml` → `scripts/deploy-to-n8n.sh --env staging`
- `.github/workflows/issueops-production.yml` → `scripts/deploy-to-n8n.sh --env production`
- `.github/workflows/security-scan.yml` → `scripts/security-scan.sh`
- `.github/workflows/cron-maintenance.yml` → `scripts/create-maintenance-issue.sh`

All GitHub Actions workflows have been moved to `archive/github-actions/` and can be reactivated if billing is resolved.

## Cost

**$0** - All scripts use free tools and services:
- ✅ Bash (free)
- ✅ jq (free, open source)
- ✅ curl (free)
- ✅ GitHub CLI (free)
- ✅ n8n Cloud API (included in n8n Cloud plan)

No GitHub Actions minutes required!

## Support

For issues with these scripts:
1. Check troubleshooting section above
2. Review script help: `./script-name.sh --help`
3. Create GitHub issue with label `type:bug`

---

**Last Updated:** 2025-11-05
**Maintained By:** Chucky Project Team
