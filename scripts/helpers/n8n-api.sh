#!/bin/bash
#
# n8n-api.sh - Helper functions for n8n Cloud API interactions
#

# Deploy workflow to n8n instance
n8n_deploy_workflow() {
    local file="$1"
    local n8n_url="$2"
    local api_key="$3"

    # Extract workflow metadata
    local WORKFLOW_ID=$(jq -r '.id // empty' "$file" 2>/dev/null)
    local WORKFLOW_NAME=$(jq -r '.name // "Unnamed"' "$file" 2>/dev/null)

    # Determine if creating new or updating
    local METHOD
    local URL
    local ACTION

    if [ -z "$WORKFLOW_ID" ] || [ "$WORKFLOW_ID" = "null" ]; then
        METHOD="POST"
        URL="${n8n_url}/api/v1/workflows"
        ACTION="Creating"
    else
        METHOD="PUT"
        URL="${n8n_url}/api/v1/workflows/${WORKFLOW_ID}"
        ACTION="Updating"
    fi

    echo "$ACTION workflow: $WORKFLOW_NAME"

    # Deploy via API
    local RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X "$METHOD" \
        "$URL" \
        -H "X-N8N-API-KEY: $api_key" \
        -H "Content-Type: application/json" \
        -d @"$file" 2>&1)

    local HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    local BODY=$(echo "$RESPONSE" | sed '$d')

    # Return status
    if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
        echo "SUCCESS|$HTTP_CODE|$BODY"
        return 0
    else
        echo "FAILED|$HTTP_CODE|$BODY"
        return 1
    fi
}

# Get workflow status from n8n
n8n_get_workflow() {
    local workflow_id="$1"
    local n8n_url="$2"
    local api_key="$3"

    local RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X GET \
        "${n8n_url}/api/v1/workflows/${workflow_id}" \
        -H "X-N8N-API-KEY: $api_key" 2>&1)

    local HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    local BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
        echo "$BODY"
        return 0
    else
        return 1
    fi
}

# List all workflows in n8n instance
n8n_list_workflows() {
    local n8n_url="$1"
    local api_key="$2"

    local RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X GET \
        "${n8n_url}/api/v1/workflows" \
        -H "X-N8N-API-KEY: $api_key" 2>&1)

    local HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    local BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
        echo "$BODY"
        return 0
    else
        return 1
    fi
}

# Activate/deactivate workflow
n8n_toggle_workflow() {
    local workflow_id="$1"
    local active="$2"  # true or false
    local n8n_url="$3"
    local api_key="$4"

    local RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X PATCH \
        "${n8n_url}/api/v1/workflows/${workflow_id}" \
        -H "X-N8N-API-KEY: $api_key" \
        -H "Content-Type: application/json" \
        -d "{\"active\": $active}" 2>&1)

    local HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

    if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
        return 0
    else
        return 1
    fi
}
