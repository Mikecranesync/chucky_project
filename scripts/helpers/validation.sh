#!/bin/bash
#
# validation.sh - Helper functions for n8n workflow validation
#

# Check if jq is installed
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed"
        echo "Install: https://stedolan.github.io/jq/download/"
        return 1
    fi
    return 0
}

# Validate JSON syntax
validate_json_syntax() {
    local file="$1"
    jq empty "$file" 2>/dev/null
    return $?
}

# Check for required n8n workflow fields
validate_n8n_structure() {
    local file="$1"

    # Check for nodes array
    if ! jq -e '.nodes' "$file" > /dev/null 2>&1; then
        return 1
    fi

    # Check for connections object
    if ! jq -e '.connections' "$file" > /dev/null 2>&1; then
        return 1
    fi

    return 0
}

# Extract workflow metadata
get_workflow_metadata() {
    local file="$1"

    local name=$(jq -r '.name // "Unnamed"' "$file" 2>/dev/null)
    local id=$(jq -r '.id // "none"' "$file" 2>/dev/null)
    local node_count=$(jq '.nodes | length' "$file" 2>/dev/null)
    local connection_count=$(jq '.connections | to_entries | length' "$file" 2>/dev/null)

    echo "$name|$id|$node_count|$connection_count"
}

# Check for disabled nodes
count_disabled_nodes() {
    local file="$1"
    jq '[.nodes[] | select(.disabled == true)] | length' "$file" 2>/dev/null
}

# Scan for potential exposed credentials
scan_for_credentials() {
    local file="$1"

    # Look for patterns that might be credentials
    # Excludes credentialId references (those are safe)
    if grep -qE '"(apiKey|api_key|token|password|secret)"\s*:\s*"[a-zA-Z0-9_\-\.]{20,}"' "$file" 2>/dev/null; then
        # Make sure it's not a credentialId reference
        if ! grep -q '"credentialId"' "$file" 2>/dev/null; then
            return 0  # Found credentials
        fi
    fi

    return 1  # No credentials found
}
