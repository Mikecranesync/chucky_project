#!/bin/bash
#
# validate-workflows.sh - Validate n8n workflow JSON files
#
# Usage:
#   ./scripts/validate-workflows.sh [file.json]
#   ./scripts/validate-workflows.sh  (validates all workflow JSON files)
#
# Exit codes:
#   0 - All valid
#   1 - Validation errors
#   2 - Credentials detected
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
VALIDATED=0
ERRORS=0
WARNINGS=0
CREDS_FOUND=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper functions
if [ -f "$SCRIPT_DIR/helpers/validation.sh" ]; then
    source "$SCRIPT_DIR/helpers/validation.sh"
else
    echo -e "${RED}Error: Helper script not found: helpers/validation.sh${NC}"
    exit 1
fi

# Check dependencies
if ! check_dependencies; then
    exit 1
fi

# Function to validate single workflow
validate_workflow() {
    local file="$1"

    echo -e "\n${BLUE}Validating: $file${NC}"

    # Check JSON syntax
    if ! validate_json_syntax "$file"; then
        echo -e "${RED}✗ Invalid JSON syntax${NC}"
        ((ERRORS++))
        return 1
    fi

    # Check n8n workflow structure
    if ! validate_n8n_structure "$file"; then
        echo -e "${RED}✗ Missing required n8n fields (nodes/connections)${NC}"
        ((ERRORS++))
        return 1
    fi

    # Extract metadata
    local METADATA=$(get_workflow_metadata "$file")
    IFS='|' read -r NAME ID NODE_COUNT CONNECTION_COUNT <<< "$METADATA"

    # Check for disabled nodes
    local DISABLED_COUNT=$(count_disabled_nodes "$file")
    if [ "$DISABLED_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Contains $DISABLED_COUNT disabled nodes${NC}"
        ((WARNINGS++))
    fi

    # Check for credentials
    if scan_for_credentials "$file"; then
        echo -e "${RED}⚠ ALERT: Potential credentials detected!${NC}"
        echo -e "${RED}   This file may contain exposed API keys or tokens${NC}"
        ((CREDS_FOUND++))
    fi

    echo -e "${GREEN}✓ Valid workflow: $NAME${NC}"
    echo "  ID: $ID"
    echo "  Nodes: $NODE_COUNT, Connections: $CONNECTION_COUNT"

    ((VALIDATED++))
    return 0
}

# Main logic
main() {
    echo "========================================="
    echo "n8n Workflow Validation"
    echo "========================================="

    # Determine files to validate
    if [ $# -eq 0 ]; then
        # Validate all workflow JSON files (exclude config files)
        FILES=$(find . -maxdepth 1 -name "*.json" -type f | \
                grep -vE "(package|tsconfig|mcp_config|settings)" | \
                grep -E "(Chucky|[Ww]orkflow|Payment|User|Quota|Monitoring|Security|Stripe|Monthly|Premium|Marketing)" || true)
    else
        FILES="$@"
    fi

    if [ -z "$FILES" ]; then
        echo -e "${YELLOW}No workflow files found${NC}"
        exit 0
    fi

    echo "Files to validate:"
    for file in $FILES; do
        echo "  - $file"
    done

    # Validate each file
    for file in $FILES; do
        if [ -f "$file" ]; then
            validate_workflow "$file" || true
        else
            echo -e "${RED}✗ File not found: $file${NC}"
            ((ERRORS++))
        fi
    done

    # Summary
    echo -e "\n========================================="
    echo "Validation Summary"
    echo "========================================="
    echo "Validated: $VALIDATED"
    echo "Errors: $ERRORS"
    echo "Warnings: $WARNINGS"

    if [ $CREDS_FOUND -gt 0 ]; then
        echo -e "${RED}⚠ SECURITY ALERT: Credentials detected in $CREDS_FOUND files${NC}"
        echo -e "${RED}   Review these files and remove exposed credentials${NC}"
        echo "========================================="
        exit 2
    fi

    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}Validation FAILED${NC}"
        echo "========================================="
        exit 1
    fi

    echo -e "${GREEN}All validations PASSED ✓${NC}"
    echo "========================================="
    exit 0
}

# Run main
main "$@"
