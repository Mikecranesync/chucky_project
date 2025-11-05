# Archived GitHub Actions Workflows

**Archive Date:** 2025-11-05
**Reason:** GitHub Actions billing issue blocking workflow execution
**Status:** Migrated to manual bash scripts

---

## Overview

These workflows were archived due to GitHub Actions being blocked by a billing issue. All functionality has been migrated to manual bash scripts in `scripts/` directory.

This archive is kept for:
- Historical reference
- Potential reactivation if billing is resolved
- Documentation of automation approach

---

## Archived Workflows

### 1. ci-validate.yml
**Purpose:** Validate workflow JSON and scan for credentials on PRs

**Replaced by:** `scripts/validate-workflows.sh`

**What it did:**
- Triggered on: Pull requests, pushes to main
- Validated JSON syntax using jq
- Checked for required n8n fields
- Scanned for exposed credentials
- Posted validation results as PR comments
- Created issues on validation failures

**Migration notes:**
- Manual execution: Run `./scripts/validate-workflows.sh` before committing
- PR comments: Manually post validation results
- Issue creation: Use `gh issue create` or GitHub UI

---

### 2. cd-deploy-staging.yml
**Purpose:** Auto-deploy workflows to staging after merge to main

**Replaced by:** `scripts/deploy-to-n8n.sh --env staging`

**What it did:**
- Triggered on: Push to main branch
- Detected changed workflow files
- Deployed only modified workflows
- Posted deployment results as issue comments

**Migration notes:**
- Manual execution: Run `./scripts/deploy-to-n8n.sh --env staging <workflow.json>`
- Requires `N8N_STAGING_URL` and `N8N_STAGING_API_KEY` environment variables
- Can skip if no staging environment configured

---

### 3. issueops-production.yml
**Purpose:** Deploy to production via GitHub Issues (IssueOps pattern)

**Replaced by:** `scripts/deploy-to-n8n.sh --env production`

**What it did:**
- Triggered on: Adding `deploy-to-prod` label to issue
- Required manual approval via GitHub Environments
- Deployed workflows listed in issue
- Updated issue with deployment status
- Added/removed labels based on success/failure

**Migration notes:**
- Manual execution: Create deployment issue, run deploy script, update issue manually
- Use GitHub issue templates for deployment tracking
- Update labels and status via `gh issue edit`

---

### 4. security-scan.yml
**Purpose:** Weekly security scanning for exposed credentials

**Replaced by:** `scripts/security-scan.sh`

**What it did:**
- Triggered on: Weekly schedule (Sundays at 2 AM), push to main, pull requests
- Scanned for exposed credentials (API keys, tokens, passwords)
- Checked for: Discord, Stripe, Google, OpenAI, Supabase credentials
- Created GitHub issues for critical findings

**Migration notes:**
- Manual execution: Run `./scripts/security-scan.sh` weekly or before commits
- Auto-create issues: Use `--create-issue` flag
- Run before any deployment

---

### 5. cron-maintenance.yml
**Purpose:** Create weekly maintenance checklist issues

**Replaced by:** `scripts/create-maintenance-issue.sh`

**What it did:**
- Triggered on: Weekly schedule (Mondays at 9 AM), manual workflow dispatch
- Created comprehensive maintenance issue with checklists
- Checked for existing open maintenance issue to avoid duplicates

**Migration notes:**
- Manual execution: Run `./scripts/create-maintenance-issue.sh` every Monday
- Can schedule with local cron or Windows Task Scheduler if desired
- Or just run manually when needed

---

## Reactivation Instructions

If GitHub Actions billing is resolved and you want to reactivate these workflows:

```bash
# Move workflows back to .github/workflows/
cd C:/Users/hharp/chucky_project
git mv archive/github-actions/*.yml .github/workflows/

# Commit the change
git add .
git commit -m "Reactivate GitHub Actions workflows"
git push origin main

# Configure GitHub repository settings:
# 1. Enable workflow permissions (Settings → Actions → General)
# 2. Create production environment (Settings → Environments)
# 3. Verify secrets are configured (N8N_URL, N8N_API_KEY)
```

**Note:** The bash scripts in `scripts/` will still be useful for local testing and manual deployments.

---

## Migration Benefits

**Why bash scripts are better (for now):**

1. **$0 Cost** - No GitHub Actions minutes used
2. **Full Control** - Manual execution, see exactly what happens
3. **Debugging** - Easier to debug locally
4. **Learning** - Better understanding of n8n API
5. **Flexibility** - Can run anytime, anywhere
6. **No Billing Dependency** - Works regardless of GitHub billing status

---

## Workflow Comparison

| Feature | GitHub Actions | Bash Scripts |
|---------|---------------|--------------|
| **Cost** | Billed (blocked) | Free |
| **Trigger** | Automatic | Manual |
| **Execution** | GitHub servers | Local machine |
| **Debugging** | Logs in GitHub UI | Terminal output |
| **Approval Gates** | GitHub Environments | Manual confirmation |
| **PR Comments** | Automated | Manual |
| **Issue Creation** | Automated | `gh` CLI |
| **Schedule** | GitHub cron | Local cron/manual |

---

## Related Documentation

- **Script Usage:** `scripts/README.md` - Comprehensive guide to using bash scripts
- **Deployment Guide:** `GITHUB_SETUP.md` - Original GitHub Actions setup (for reference)
- **Migration Plan:** See commit history for detailed migration process
- **Issue Tracking:** GitHub Issues and Project board for deployment queue

---

## Historical Context

**Session 1 (Nov 5, 2025):**
- Created 5 GitHub Actions workflows
- Configured secrets, labels, templates
- All infrastructure ready to use

**Session 2 (Nov 5, 2025):**
- Discovered GitHub Actions billing issue
- Configured secrets (N8N_URL, N8N_API_KEY)
- Created 25 repository labels
- Tested CI/CD but workflows failed due to billing

**Session 3 (Nov 5, 2025):**
- User requested migration to free approach
- Created bash scripts to replace all workflows
- Archived GitHub Actions
- Migrated to issue-driven development

---

## Future Considerations

**If GitHub Actions is reactivated:**
- Can use both approaches (Actions for automation, scripts for manual testing)
- Scripts provide good local testing before CI/CD runs
- Hybrid approach: Actions for validation, manual for deployment

**For now:**
- Use bash scripts for all workflow management
- GitHub Issues for tracking
- Manual execution with full control
- $0 cost

---

**Questions?** See `scripts/README.md` or create a GitHub issue.
