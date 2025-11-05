#!/bin/bash
# GitHub Repository Labels Setup Script
# Creates all 25 labels needed for Chucky project issue tracking and IssueOps

echo "Creating GitHub labels for Chucky project..."
echo ""

# Type labels (7)
echo "Creating type labels..."
gh label create "type:bug" --color "d73a4a" --description "Bug fixes" --force
gh label create "type:feature" --color "0e8a16" --description "New features" --force
gh label create "type:enhancement" --color "1d76db" --description "Enhancements" --force
gh label create "type:documentation" --color "0075ca" --description "Documentation" --force
gh label create "type:security" --color "ee0701" --description "Security issues" --force
gh label create "type:deployment" --color "8b5cf6" --description "Deployment tasks" --force
gh label create "type:maintenance" --color "fbca04" --description "Maintenance" --force

# Priority labels (4)
echo "Creating priority labels..."
gh label create "priority:critical" --color "b60205" --description "Critical priority" --force
gh label create "priority:high" --color "ff9800" --description "High priority" --force
gh label create "priority:medium" --color "fbca04" --description "Medium priority" --force
gh label create "priority:low" --color "c5def5" --description "Low priority" --force

# Status labels (6)
echo "Creating status labels..."
gh label create "status:needs-triage" --color "ededed" --description "Needs triage" --force
gh label create "status:ready" --color "0e8a16" --description "Ready for work" --force
gh label create "status:in-progress" --color "fef2c0" --description "In progress" --force
gh label create "status:blocked" --color "d93f0b" --description "Blocked" --force
gh label create "status:deployed" --color "5319e7" --description "Deployed" --force
gh label create "status:failed" --color "b60205" --description "Failed" --force

# Component labels (5)
echo "Creating component labels..."
gh label create "component:n8n" --color "006b75" --description "n8n workflows" --force
gh label create "component:supabase" --color "3ecf8e" --description "Supabase DB" --force
gh label create "component:gemini" --color "4285f4" --description "Google Gemini" --force
gh label create "component:discord" --color "5865f2" --description "Discord integration" --force
gh label create "component:telegram" --color "0088cc" --description "Telegram integration" --force

# Special labels (3) - CRITICAL for IssueOps
echo "Creating special labels..."
gh label create "deploy-to-prod" --color "b60205" --description "Deploy to production (CRITICAL for IssueOps)" --force
gh label create "environment:staging" --color "ffeb3b" --description "Staging environment" --force
gh label create "environment:production" --color "4caf50" --description "Production environment" --force

echo ""
echo "✅ All 25 labels created successfully!"
echo ""
echo "Verify at: https://github.com/Mikecranesync/chucky_project/labels"
