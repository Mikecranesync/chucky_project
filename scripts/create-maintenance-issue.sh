#!/bin/bash
#
# create-maintenance-issue.sh - Create weekly maintenance checklist issue
#
# Usage:
#   ./scripts/create-maintenance-issue.sh
#   ./scripts/create-maintenance-issue.sh --date 2025-11-12
#
# Exit codes:
#   0 - Issue created
#   1 - Error or issue already exists
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Default to current week
WEEK_DATE=$(date '+%Y-%m-%d')

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --date)
            WEEK_DATE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--date YYYY-MM-DD]"
            echo ""
            echo "Creates a weekly maintenance checklist issue for the specified week"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is required${NC}"
    echo "Install from: https://cli.github.com/"
    exit 1
fi

# Check if issue already exists for this week
EXISTING=$(gh issue list --label "type:maintenance" --search "Weekly Maintenance Checklist - $WEEK_DATE" --json number --jq '.[0].number' 2>/dev/null || echo "")

if [ -n "$EXISTING" ]; then
    echo -e "${YELLOW}Maintenance issue already exists for week of $WEEK_DATE${NC}"
    echo "Issue #$EXISTING"
    echo "Use: gh issue view $EXISTING"
    exit 1
fi

# Create issue body
ISSUE_TITLE="🔧 Weekly Maintenance Checklist - Week of $WEEK_DATE"
ISSUE_BODY="## Weekly Maintenance Tasks

**Week of:** $WEEK_DATE
**Status:** Pending Review

---

### 🔒 Security Tasks

- [ ] Review recent security scan results
- [ ] Check for exposed credentials in new commits
- [ ] Verify API keys are not expiring soon
- [ ] Review access logs for suspicious activity
- [ ] Confirm all secrets are stored in n8n credentials manager

### 📁 Repository Tasks

- [ ] Review and close completed issues
- [ ] Update PROJECT_TRACKER.md with progress
- [ ] Check for stale branches and clean up
- [ ] Review and merge pending PRs (if any)
- [ ] Update documentation for recent changes

### 🤖 n8n Workflow Health

- [ ] Check all active workflows are running
- [ ] Review workflow execution logs for errors
- [ ] Verify webhook endpoints are responding
- [ ] Check database connection health
- [ ] Review workflow performance metrics

### 🗄️ Database Tasks

- [ ] Check Supabase database health
- [ ] Review query performance
- [ ] Verify RLS policies are working
- [ ] Check storage usage
- [ ] Review and clean up old test data (if any)

### 📊 Monitoring & Analytics

- [ ] Review workflow execution statistics
- [ ] Check error rates and patterns
- [ ] Verify monitoring alerts are working
- [ ] Review quota usage across users
- [ ] Check payment processing statistics (if applicable)

### 📝 Documentation Tasks

- [ ] Update README if needed
- [ ] Review and update setup guides
- [ ] Document any new issues or workarounds
- [ ] Update deployment history
- [ ] Check for broken documentation links

### 🔄 Deployment Review

- [ ] List recently deployed workflows
- [ ] Verify deployed workflows match repository
- [ ] Check for pending deployments
- [ ] Review deployment success rate
- [ ] Plan next week's deployments

---

### 📋 Notes

Add any notes, observations, or issues discovered during maintenance:

-

---

### ✅ Completion

When all tasks are complete:
1. Review all checklist items
2. Add summary comment with findings
3. Add label \`status:completed\`
4. Close this issue

**Auto-created by:** \`scripts/create-maintenance-issue.sh\`
"

# Create the issue
echo "Creating maintenance issue for week of $WEEK_DATE..."

ISSUE_NUMBER=$(gh issue create \
    --title "$ISSUE_TITLE" \
    --label "type:maintenance,priority:medium,status:needs-triage" \
    --body "$ISSUE_BODY" \
    --assignee "@me" \
    --json number \
    --jq '.number')

if [ -n "$ISSUE_NUMBER" ]; then
    echo -e "${GREEN}✓ Created issue #$ISSUE_NUMBER${NC}"
    echo "View: gh issue view $ISSUE_NUMBER"
    echo "URL: $(gh issue view $ISSUE_NUMBER --json url --jq '.url')"
    exit 0
else
    echo -e "${RED}✗ Failed to create issue${NC}"
    exit 1
fi
