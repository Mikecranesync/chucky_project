# Repository Cleanup Guide

**Status:** 100+ untracked files need organization
**Time Estimate:** 30-60 minutes
**Goal:** Clean, organized repository with clear separation of production vs archive files

## Quick Summary

**Files to KEEP (commit to Git):**
- Production workflow JSON files (11 files)
- Setup guide MD files (15+ files)
- Database schema SQL files (5 files)
- CI/CD infrastructure (.github/ directory)
- Documentation files (README.md, CONTRIBUTING.md, etc.)

**Files to ARCHIVE (move to archive/):**
- Backup JSON files (20+ files)
- Diagnostic reports (10+ files)
- Dev scripts (15+ .ps1 and .js files)
- Temp/debug workflow files (30+ files)

**Files to DELETE:**
- True temporary files
- Duplicate files
- Files now covered by .gitignore

---

## Production Workflow Files (KEEP - Commit These)

These are your core n8n workflows - **keep these in root and commit**:

```bash
# Core production workflows
ChuckyDiscordRAG.json
ChuckyTelegramLocal.json
Payment_Management_Workflow.json
User_Auth_Workflow.json
Quota_Enforcement_Workflow.json
Premium_Features_Workflow.json
Monitoring_Analytics_Workflow.json
Marketing_Retention_Workflow.json
Security_Compliance_Workflow.json
Stripe_Webhook_Handler.json
Monthly_Quota_Reset.json

# Original workflow (keep for reference)
"Chucky (30).json"
"Chucky (31).json"
```

**Action:**
```bash
# These are already in place - just commit them later
git add ChuckyDiscordRAG.json ChuckyTelegramLocal.json
git add Payment_Management_Workflow.json User_Auth_Workflow.json
git add Quota_Enforcement_Workflow.json Premium_Features_Workflow.json
git add Monitoring_Analytics_Workflow.json Marketing_Retention_Workflow.json
git add Security_Compliance_Workflow.json Stripe_Webhook_Handler.json
git add Monthly_Quota_Reset.json "Chucky (30).json" "Chucky (31).json"
```

---

## Backup Files (ARCHIVE - Move to archive/backups/)

These are old backups and should be archived:

```bash
ChuckyLocal.BACKUP_20251103_052329.json
workflow_backup.json
workflow_fixed.json
workflow_updated.json
workflow_modified.json
current_workflow.json
```

**Action:**
```bash
mv ChuckyLocal.BACKUP_20251103_052329.json archive/backups/
mv workflow_backup.json archive/backups/
mv workflow_fixed.json archive/backups/
mv workflow_updated.json archive/backups/
mv workflow_modified.json archive/backups/
mv current_workflow.json archive/backups/
```

---

## Diagnostic/Debug Files (ARCHIVE - Move to archive/diagnostics/)

These are troubleshooting reports and debug files:

```bash
# Diagnostic reports
serpapi_diagnostic_report.md
gemini_error_fix_report.md
MODIFICATION_SUMMARY.md
modification_report.md
WORKFLOW_FIX_SUMMARY.md
WORKFLOW_ACTIVATION_TROUBLESHOOTING.md
workflow_activation_analysis.md
mcp_workflow_analysis_report.md
CHUCKY_31_VALIDATION_REPORT.md
N8N_COMMUNITY_KNOWN_ISSUES.md
SERPAPI_FIX_SUMMARY.md

# Debug workflow files
workflow_debug.json
workflow_temp.json
workflow_verification.json
workflow_for_validation.json
workflow_mcp_input.json
workflow_validation_input.json
workflow_final_payload.json
workflow_correct_payload.json
workflow_minimal_payload.json
workflow_update_payload.json
update_payload.json
update_response.json
update_result.json
final_response.json

# Debug node files
failing_node.json
working_node1.json
```

**Action:**
```bash
# Move diagnostic MD files
mv serpapi_diagnostic_report.md archive/diagnostics/
mv gemini_error_fix_report.md archive/diagnostics/
mv MODIFICATION_SUMMARY.md archive/diagnostics/
mv modification_report.md archive/diagnostics/
mv WORKFLOW_FIX_SUMMARY.md archive/diagnostics/
mv WORKFLOW_ACTIVATION_TROUBLESHOOTING.md archive/diagnostics/
mv workflow_activation_analysis.md archive/diagnostics/
mv mcp_workflow_analysis_report.md archive/diagnostics/
mv CHUCKY_31_VALIDATION_REPORT.md archive/diagnostics/
mv N8N_COMMUNITY_KNOWN_ISSUES.md archive/diagnostics/
mv SERPAPI_FIX_SUMMARY.md archive/diagnostics/

# Move debug JSON files
mv workflow_debug.json archive/diagnostics/
mv workflow_temp.json archive/diagnostics/
mv workflow_verification.json archive/diagnostics/
mv workflow_for_validation.json archive/diagnostics/
mv workflow_mcp_input.json archive/diagnostics/
mv workflow_validation_input.json archive/diagnostics/
mv workflow_final_payload.json archive/diagnostics/
mv workflow_correct_payload.json archive/diagnostics/
mv workflow_minimal_payload.json archive/diagnostics/
mv workflow_update_payload.json archive/diagnostics/
mv update_payload.json archive/diagnostics/
mv update_response.json archive/diagnostics/
mv update_result.json archive/diagnostics/
mv final_response.json archive/diagnostics/
mv failing_node.json archive/diagnostics/
mv working_node1.json archive/diagnostics/
```

---

## Development Scripts (ARCHIVE - Move to archive/scripts/)

These are one-off dev scripts used for debugging:

```bash
# PowerShell scripts
fix_workflow_for_localhost.ps1
extract_node.ps1
setup_n8n_mcp.ps1
deploy-claude-to-vps.ps1
check-vps-readiness.ps1

# JavaScript scripts
analyze_key_nodes.js
compare_nodes.js
create_update_payload.js
extract_node.js
fix_node.js
fix_serpapi_node.json
modify_workflow.js
modify_workflow_v2.js
prepare_correct_update.js
prepare_final_update.js
prepare_minimal_update.js
prepare_update.js
prepare_workflow_for_mcp.js
validate_chucky.js
verify_fix.js

# Python scripts
modify_workflow.py
```

**Action:**
```bash
# Move PowerShell scripts
mv *.ps1 archive/scripts/

# Move JavaScript scripts
mv analyze_key_nodes.js archive/scripts/
mv compare_nodes.js archive/scripts/
mv create_update_payload.js archive/scripts/
mv extract_node.js archive/scripts/
mv fix_node.js archive/scripts/
mv fix_serpapi_node.json archive/scripts/
mv modify_workflow.js archive/scripts/
mv modify_workflow_v2.js archive/scripts/
mv prepare_correct_update.js archive/scripts/
mv prepare_final_update.js archive/scripts/
mv prepare_minimal_update.js archive/scripts/
mv prepare_update.js archive/scripts/
mv prepare_workflow_for_mcp.js archive/scripts/
mv validate_chucky.js archive/scripts/
mv verify_fix.js archive/scripts/

# Move Python scripts
mv modify_workflow.py archive/scripts/
```

---

## Documentation Files (KEEP - but consolidate if needed)

Keep these documentation files in root:

### Core Documentation (KEEP in root)
```bash
README.md
CLAUDE.md
CONTRIBUTING.md
GITHUB_SETUP.md
SECURITY_ALERT.md
CLEANUP_GUIDE.md (this file)

# Setup guides
CHUCKY_DISCORD_RAG_SETUP.md
DISCORD_SETUP_GUIDE.md
DISCORD_MIGRATION_MASTER_GUIDE.md
DISCORD_WORKFLOW_IMPLEMENTATION.md
PAYMENT_INTEGRATION_SETUP_GUIDE.md
PAYMENT_WORKFLOW_SUMMARY.md
QUOTA_MANAGEMENT_SETUP_GUIDE.md
QUOTA_WORKFLOW_SUMMARY.md
USER_AUTH_SETUP_GUIDE.md
TELEGRAM_WEBHOOK_FIX.md
EMAIL_SETUP_WALKTHROUGH.md

# VPS deployment guides
VPS_CHECK_GUIDE.md
```

### Archive Old Documentation (ARCHIVE - Move to archive/docs/)
```bash
# Old implementation summaries
PROJECT_COMPLETE_SUMMARY.md
CHUCKY_RAG_DELIVERY_SUMMARY.md
ADVANCED_FEATURES_SUMMARY.md
NEXT_STEPS_QUICK_START.md
QUICK_START.txt
QUICK_FIX_GUIDE.txt
STEP_BY_STEP_FIX.md

# Claude Code implementation notes
CLAUDE_N8N_USAGE_EXAMPLES.md
claude_mcp_implementation.md
mcp_setup_success.md
programming_n8n_with_claude.md
CLAUDE_CODE_IMPLEMENTATION_SUMMARY.md
CLAUDE_CODE_VALIDATION_REPORT.md
MASTER_CLAUDE_SETUP_PROMPT.md
Claude_CLI_semiauto_programmimng.txt

# Outdated guides
api_workflow_update_method.md
n8n_api_setup_guide.md
```

**Action:**
```bash
# Move old summaries
mv PROJECT_COMPLETE_SUMMARY.md archive/docs/
mv CHUCKY_RAG_DELIVERY_SUMMARY.md archive/docs/
mv ADVANCED_FEATURES_SUMMARY.md archive/docs/
mv NEXT_STEPS_QUICK_START.md archive/docs/
mv QUICK_START.txt archive/docs/
mv QUICK_FIX_GUIDE.txt archive/docs/
mv STEP_BY_STEP_FIX.md archive/docs/

# Move Claude Code notes
mv CLAUDE_N8N_USAGE_EXAMPLES.md archive/docs/
mv claude_mcp_implementation.md archive/docs/
mv mcp_setup_success.md archive/docs/
mv programming_n8n_with_claude.md archive/docs/
mv CLAUDE_CODE_IMPLEMENTATION_SUMMARY.md archive/docs/
mv CLAUDE_CODE_VALIDATION_REPORT.md archive/docs/
mv MASTER_CLAUDE_SETUP_PROMPT.md archive/docs/
mv Claude_CLI_semiauto_programmimng.txt archive/docs/

# Move outdated guides
mv api_workflow_update_method.md archive/docs/
mv n8n_api_setup_guide.md archive/docs/
```

---

## Database Schema Files (KEEP in root)

```bash
supabase_users_schema.sql
supabase_payment_schema.sql
supabase_quota_schema.sql
supabase_telegram_audit.sql
supabase_advanced_schema.sql
```

**Action:**
```bash
# These should stay in root - just commit them
git add supabase_*.sql
```

---

## Configuration Files (KEEP as-is)

```bash
.env.example
.gitignore
docker-compose.local.yml
settings.json
mcp_config_to_add.json
```

---

## n8n-MCP Directory (KEEP as-is)

The `n8n-mcp/` directory contains the n8n MCP server code. Keep it as-is.

---

## database/ Directory (KEEP as-is)

Keep the `database/` directory structure as-is.

---

## Special Files

### PDF Files
```bash
API.pdf
"Grok chucky redo 1.pdf"
grok_report (1).pdf
```

**Decision:** Move to `archive/docs/` unless you reference them frequently.

```bash
mv *.pdf archive/docs/
```

### Shell Scripts
```bash
check-vps-from-inside.sh
setup-claude-on-vps.sh
```

**Action:**
```bash
mv *.sh archive/scripts/
```

---

## Files Covered by .gitignore (Can DELETE)

These files are now covered by .gitignore patterns and can be deleted:

```bash
# Will be ignored by Git anyway
workflow_temp.json
workflow_debug.json
*_temp.json
*_debug.json
update_*.json
workflow_*_payload.json
```

**Action:** Git will ignore them now, but you can delete them to clean up:
```bash
rm workflow_temp.json workflow_debug.json 2>/dev/null
rm update_*.json 2>/dev/null
```

---

## Quick Cleanup Script

Run these commands in order from the project root:

```bash
# Step 1: Create archive structure (already done)
mkdir -p archive/backups archive/diagnostics archive/scripts archive/docs

# Step 2: Move backup files
mv ChuckyLocal.BACKUP_20251103_052329.json workflow_backup.json workflow_fixed.json workflow_updated.json workflow_modified.json current_workflow.json archive/backups/ 2>/dev/null

# Step 3: Move diagnostic files
mv *_diagnostic_report.md *_error_fix_report.md *_validation_report.md MODIFICATION_SUMMARY.md modification_report.md WORKFLOW_FIX_SUMMARY.md WORKFLOW_ACTIVATION_TROUBLESHOOTING.md workflow_activation_analysis.md mcp_workflow_analysis_report.md N8N_COMMUNITY_KNOWN_ISSUES.md SERPAPI_FIX_SUMMARY.md archive/diagnostics/ 2>/dev/null

# Step 4: Move debug JSON files
mv workflow_debug.json workflow_temp.json workflow_verification.json workflow_for_validation.json workflow_mcp_input.json workflow_validation_input.json workflow_final_payload.json workflow_correct_payload.json workflow_minimal_payload.json workflow_update_payload.json update_payload.json update_response.json update_result.json final_response.json failing_node.json working_node1.json archive/diagnostics/ 2>/dev/null

# Step 5: Move scripts
mv *.ps1 *.js *.py *.sh archive/scripts/ 2>/dev/null

# Step 6: Move old documentation
mv PROJECT_COMPLETE_SUMMARY.md CHUCKY_RAG_DELIVERY_SUMMARY.md ADVANCED_FEATURES_SUMMARY.md NEXT_STEPS_QUICK_START.md QUICK_START.txt QUICK_FIX_GUIDE.txt STEP_BY_STEP_FIX.md archive/docs/ 2>/dev/null
mv CLAUDE_N8N_USAGE_EXAMPLES.md claude_mcp_implementation.md mcp_setup_success.md programming_n8n_with_claude.md CLAUDE_CODE_IMPLEMENTATION_SUMMARY.md CLAUDE_CODE_VALIDATION_REPORT.md MASTER_CLAUDE_SETUP_PROMPT.md Claude_CLI_semiauto_programmimng.txt api_workflow_update_method.md n8n_api_setup_guide.md archive/docs/ 2>/dev/null

# Step 7: Move PDFs
mv *.pdf archive/docs/ 2>/dev/null

# Step 8: Check what's left
ls *.json *.md *.sql 2>/dev/null

# Step 9: Review and commit
git status
```

---

## Verification Checklist

After running the cleanup, verify:

### In Project Root
- [ ] ~11 production workflow JSON files
- [ ] ~15 setup guide MD files
- [ ] ~5 SQL schema files
- [ ] README.md, CONTRIBUTING.md, GITHUB_SETUP.md
- [ ] .github/ directory
- [ ] .env.example, .gitignore
- [ ] n8n-mcp/ directory
- [ ] database/ directory

### In archive/
- [ ] archive/backups/ - ~6 backup JSON files
- [ ] archive/diagnostics/ - ~40+ debug/diagnostic files
- [ ] archive/scripts/ - ~20+ .ps1/.js/.py files
- [ ] archive/docs/ - ~15+ old documentation files

### Git Status
```bash
git status
```

Should show:
- Modified: .gitignore, .env.example, DISCORD_SETUP_GUIDE.md
- New: .github/, README.md, CONTRIBUTING.md, GITHUB_SETUP.md, SECURITY_ALERT.md, CLEANUP_GUIDE.md
- New: All production workflow JSON files
- New: All setup guide MD files
- New: All SQL schema files
- Untracked: archive/ (optional - you can commit or not)

---

## Next Steps After Cleanup

1. **Review what's left**: `ls -la`
2. **Check git status**: `git status`
3. **Commit clean structure**:
   ```bash
   git add .github/ *.md *.json *.sql .gitignore .env.example
   git commit -m "feat: organize repository structure

   - Add GitHub Actions CI/CD infrastructure
   - Secure exposed Discord credentials
   - Add comprehensive documentation
   - Archive old diagnostic and debug files
   - Update .gitignore patterns
   - Add .env.example template

   Security:
   - Removed exposed Discord bot token and client secret from docs
   - Created SECURITY_ALERT.md with rotation instructions
   - Enhanced .gitignore to prevent future credential exposure"
   ```
4. **Push to GitHub**: `git push origin main`

---

## Time Estimate

- **Manual review and commands**: 30 minutes
- **Or use quick script**: 5 minutes
- **Git commit and push**: 5 minutes
- **Total**: 10-40 minutes depending on approach

---

## Questions?

If you're unsure about any file:
1. Check if it's referenced in any documentation
2. Check its last modified date
3. When in doubt, move to archive/ (don't delete)
4. You can always retrieve from archive/ later

**Ready to clean up?** Start with the quick cleanup script above!
