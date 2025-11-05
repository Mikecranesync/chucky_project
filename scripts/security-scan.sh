#!/bin/bash
#
# security-scan.sh - Scan for exposed credentials in workflow files
#
# Usage:
#   ./scripts/security-scan.sh
#   ./scripts/security-scan.sh --create-issue (creates GitHub issue if findings)
#
# Exit codes:
#   0 - No credentials found
#   1 - Credentials detected
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Options
CREATE_ISSUE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --create-issue)
            CREATE_ISSUE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--create-issue]"
            echo ""
            echo "Options:"
            echo "  --create-issue  Create GitHub issue if credentials found"
            echo "  -h, --help      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Credential patterns to check
declare -A PATTERNS=(
    ["Google API"]="AIza[0-9A-Za-z-_]{35}"
    ["OpenAI API"]="sk-[a-zA-Z0-9]{48}"
    ["Stripe Secret"]="sk_(test|live)_[0-9a-zA-Z]{24}"
    ["Discord Bot Token"]="[MN][A-Za-z\d]{23}\.[\w-]{6}\.[\w-]{27}"
    ["Supabase Anon"]="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+"
    ["Generic API Key"]="(api[_-]?key|apikey)[\"']?\s*[:=]\s*[\"'][a-zA-Z0-9_\-]{20,}[\"']"
)

# Counters
TOTAL_FILES=0
FINDINGS=0
declare -a FINDING_DETAILS=()

# Get workflow files
FILES=$(find . -maxdepth 1 -name "*.json" -type f | \
        grep -vE "(package|tsconfig|mcp_config|settings)" | \
        grep -E "(Chucky|[Ww]orkflow|Payment|User|Quota|Monitoring|Security|Stripe|Monthly|Premium|Marketing)" || true)

if [ -z "$FILES" ]; then
    echo "No workflow files found"
    exit 0
fi

echo "========================================="
echo "Security Scan for Exposed Credentials"
echo "========================================="
echo ""

# Scan each file
for file in $FILES; do
    ((TOTAL_FILES++))

    for pattern_name in "${!PATTERNS[@]}"; do
        pattern="${PATTERNS[$pattern_name]}"

        if grep -qE "$pattern" "$file" 2>/dev/null; then
            # Found potential credential
            ((FINDINGS++))
            FINDING_DETAILS+=("$file|$pattern_name")
            echo -e "${RED}⚠ ALERT: Potential $pattern_name found in $file${NC}"
        fi
    done
done

echo ""
echo "========================================="
echo "Scan Summary"
echo "========================================="
echo "Files scanned: $TOTAL_FILES"
echo "Findings: $FINDINGS"

if [ $FINDINGS -gt 0 ]; then
    echo -e "${RED}⚠ SECURITY ALERT: Credentials may be exposed${NC}"
    echo ""
    echo "Files with potential credentials:"
    for finding in "${FINDING_DETAILS[@]}"; do
        IFS='|' read -r file cred_type <<< "$finding"
        echo "  - $file ($cred_type)"
    done

    # Create GitHub issue if requested
    if [ "$CREATE_ISSUE" = true ]; then
        if command -v gh &> /dev/null; then
            echo ""
            echo "Creating GitHub security issue..."

            # Build issue body
            ISSUE_BODY="## 🔴 Security Alert: Potential Exposed Credentials

**Scan Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Findings:** $FINDINGS potential credentials detected

### Files Affected

"
            for finding in "${FINDING_DETAILS[@]}"; do
                IFS='|' read -r file cred_type <<< "$finding"
                ISSUE_BODY="${ISSUE_BODY}- \`$file\` - $cred_type"$'\n'
            done

            ISSUE_BODY="${ISSUE_BODY}
### Recommended Actions

1. **Immediate:** Review the files listed above
2. **Verify:** Check if these are actual credentials or false positives
3. **Rotate:** If real credentials, rotate them immediately
4. **Remove:** Remove credentials from workflow JSON files
5. **Use:** Store credentials in n8n Cloud credentials manager instead

### Prevention

- Never hardcode credentials in workflow files
- Use n8n's built-in credential management
- Add patterns to .gitignore for credential files
- Run this scan before committing changes

### Auto-Generated

This issue was created automatically by \`scripts/security-scan.sh\`
"

            gh issue create \
                --title "🔴 Security Alert: Potential Exposed Credentials ($FINDINGS findings)" \
                --label "type:security,priority:critical,status:needs-triage" \
                --body "$ISSUE_BODY"

            echo -e "${GREEN}✓ GitHub issue created${NC}"
        else
            echo -e "${YELLOW}GitHub CLI (gh) not installed - cannot create issue${NC}"
        fi
    fi

    echo "========================================="
    exit 1
fi

echo -e "${GREEN}✓ No obvious credentials detected${NC}"
echo "========================================="
exit 0
