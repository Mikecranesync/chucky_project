#!/bin/bash
#
# deploy-to-n8n.sh - Deploy n8n workflows to Cloud instance
#
# Usage:
#   ./scripts/deploy-to-n8n.sh --env production workflow.json
#   ./scripts/deploy-to-n8n.sh --env staging workflow1.json workflow2.json
#   ./scripts/deploy-to-n8n.sh --env production --all
#
# Environment variables required:
#   N8N_URL - Production n8n instance URL
#   N8N_API_KEY - Production n8n API key
#   N8N_STAGING_URL (optional) - Staging instance URL
#   N8N_STAGING_API_KEY (optional) - Staging API key
#
# Exit codes:
#   0 - All deployments successful
#   1 - Some deployments failed
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
SUCCESS=0
FAILED=0

# Environment selection
ENV="production"
DEPLOY_ALL=false

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper functions
if [ -f "$SCRIPT_DIR/helpers/n8n-api.sh" ]; then
    source "$SCRIPT_DIR/helpers/n8n-api.sh"
else
    echo -e "${RED}Error: Helper script not found: helpers/n8n-api.sh${NC}"
    exit 1
fi

# Parse arguments
WORKFLOWS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            ENV="$2"
            shift 2
            ;;
        --all)
            DEPLOY_ALL=true
            shift
            ;;
        *.json)
            WORKFLOWS+=("$1")
            shift
            ;;
        -h|--help)
            echo "Usage: $0 --env [production|staging] [workflow.json...]"
            echo ""
            echo "Options:"
            echo "  --env [production|staging]  Target environment (default: production)"
            echo "  --all                       Deploy all workflow JSON files"
            echo "  -h, --help                  Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --env production ChuckyDiscordRAG.json"
            echo "  $0 --env staging User_Auth_Workflow.json Payment_Management_Workflow.json"
            echo "  $0 --env production --all"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Set API credentials based on environment
if [ "$ENV" = "production" ]; then
    N8N_API_URL="${N8N_URL:-}"
    N8N_KEY="${N8N_API_KEY:-}"

    if [ -z "$N8N_API_URL" ] || [ -z "$N8N_KEY" ]; then
        echo -e "${RED}Error: N8N_URL and N8N_API_KEY environment variables required${NC}"
        echo "Set them in your .env file or export them"
        exit 1
    fi
elif [ "$ENV" = "staging" ]; then
    N8N_API_URL="${N8N_STAGING_URL:-}"
    N8N_KEY="${N8N_STAGING_API_KEY:-}"

    if [ -z "$N8N_API_URL" ] || [ -z "$N8N_KEY" ]; then
        echo -e "${YELLOW}Staging environment not configured${NC}"
        echo "Set N8N_STAGING_URL and N8N_STAGING_API_KEY to use staging"
        exit 0
    fi
else
    echo -e "${RED}Invalid environment: $ENV${NC}"
    echo "Use: production or staging"
    exit 1
fi

# Function to deploy single workflow
deploy_workflow() {
    local file="$1"

    echo -e "\n${BLUE}=========================================${NC}"
    echo -e "${BLUE}Deploying: $file${NC}"
    echo -e "${BLUE}=========================================${NC}"

    # Validate first
    if ! jq empty "$file" 2>/dev/null; then
        echo -e "${RED}✗ Invalid JSON - skipping${NC}"
        ((FAILED++))
        return 1
    fi

    # Deploy using helper function
    local RESULT=$(n8n_deploy_workflow "$file" "$N8N_API_URL" "$N8N_KEY")
    local STATUS=$(echo "$RESULT" | cut -d'|' -f1)
    local HTTP_CODE=$(echo "$RESULT" | cut -d'|' -f2)

    if [ "$STATUS" = "SUCCESS" ]; then
        echo -e "${GREEN}✓ Successfully deployed (HTTP $HTTP_CODE)${NC}"
        ((SUCCESS++))
        return 0
    else
        echo -e "${RED}✗ Deployment failed (HTTP $HTTP_CODE)${NC}"
        local ERROR_MSG=$(echo "$RESULT" | cut -d'|' -f3-)
        echo "Response: $ERROR_MSG"
        ((FAILED++))
        return 1
    fi
}

# Main deployment logic
main() {
    echo "========================================="
    echo "n8n Workflow Deployment"
    echo "========================================="
    echo "Environment: $ENV"
    echo "n8n URL: $N8N_API_URL"
    echo "========================================="

    # Get list of workflows to deploy
    if [ "$DEPLOY_ALL" = true ]; then
        # Get all workflow JSON files
        WORKFLOWS=($(find . -maxdepth 1 -name "*.json" -type f | \
                     grep -vE "(package|tsconfig|mcp_config|settings)" | \
                     grep -E "(Chucky|[Ww]orkflow|Payment|User|Quota|Monitoring|Security|Stripe|Monthly|Premium|Marketing)" || true))
    fi

    if [ ${#WORKFLOWS[@]} -eq 0 ]; then
        echo -e "${YELLOW}No workflows specified${NC}"
        echo "Use: $0 --env $ENV workflow.json"
        echo "Or:  $0 --env $ENV --all"
        exit 0
    fi

    echo "Workflows to deploy: ${#WORKFLOWS[@]}"
    for wf in "${WORKFLOWS[@]}"; do
        echo "  - $wf"
    done

    # Confirm deployment
    echo -e "\n${YELLOW}Deploy to $ENV?${NC} (y/N): "
    read -r CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo "Deployment cancelled"
        exit 0
    fi

    # Deploy each workflow
    for workflow in "${WORKFLOWS[@]}"; do
        if [ -f "$workflow" ]; then
            deploy_workflow "$workflow" || true
        else
            echo -e "${RED}✗ File not found: $workflow${NC}"
            ((FAILED++))
        fi
    done

    # Summary
    echo -e "\n========================================="
    echo "Deployment Summary"
    echo "========================================="
    echo "Environment: $ENV"
    echo "Succeeded: $SUCCESS"
    echo "Failed: $FAILED"

    if [ $FAILED -gt 0 ]; then
        echo -e "${RED}Deployment completed with errors${NC}"
        echo "========================================="
        exit 1
    fi

    echo -e "${GREEN}All deployments successful ✓${NC}"
    echo "========================================="
    exit 0
}

# Run main
main
