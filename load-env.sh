#!/bin/bash
# Bash script to load .env file into environment variables
# Usage: source ./load-env.sh
# Or: . ./load-env.sh

ENV_FILE="${1:-.env}"

load_env() {
    local env_file="$1"

    if [ ! -f "$env_file" ]; then
        echo "⚠️  .env file not found at: $env_file"

        if [ -f ".env.example" ]; then
            echo "Creating from template..."
            cp .env.example "$env_file"
            echo "✅ Created .env from .env.example"
            echo "⚠️  Please edit .env and fill in your actual values!"
            echo ""
            return 1
        else
            echo "❌ .env.example not found. Cannot create .env"
            return 1
        fi
    fi

    echo "Loading environment variables from: $env_file"
    echo ""

    local count=0
    local warnings=0

    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        if [ -z "$line" ] || [[ "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        # Parse KEY=VALUE
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"

            # Trim whitespace
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)

            # Remove quotes if present
            value="${value%\"}"
            value="${value#\"}"
            value="${value%\'}"
            value="${value#\'}"

            # Check for placeholder values
            if [[ "$value" =~ YOUR_.*_HERE ]] || [[ "$value" =~ your_.*_here ]]; then
                echo "⚠️  $key has placeholder value - please update!"
                ((warnings++))
            fi

            # Export the variable
            export "$key=$value"
            ((count++))

        else
            echo "⚠️  Invalid format (expected KEY=VALUE): $line"
            ((warnings++))
        fi

    done < "$env_file"

    echo ""
    echo "✅ Loaded $count environment variables"

    if [ $warnings -gt 0 ]; then
        echo "⚠️  $warnings warnings (see above)"
    fi

    echo ""
    echo "Loaded variables:"

    # Show loaded variables (masked)
    while IFS= read -r line; do
        if [[ "$line" =~ ^([^=]+)= ]]; then
            key="${BASH_REMATCH[1]}"
            key=$(echo "$key" | xargs)

            if [ ! -z "${!key}" ]; then
                value="${!key}"
                if [ ${#value} -gt 20 ]; then
                    display_value="${value:0:20}...${value: -4}"
                else
                    display_value="****"
                fi
                echo "  $key = $display_value"
            fi
        fi
    done < <(grep -v '^#' "$env_file" | grep -v '^[[:space:]]*$' | sort)

    echo ""
    return 0
}

# Load the .env file
if load_env "$ENV_FILE"; then
    echo "✅ Environment variables loaded successfully!"
    echo ""
    echo "You can now use them in your scripts:"
    echo '  $ANTHROPIC_API_KEY'
    echo '  $VPS_HOST'
    echo '  $TELEGRAM_BOT_TOKEN'
    echo ""
else
    echo "❌ Failed to load environment variables"
    echo "Please ensure .env exists and has valid KEY=VALUE pairs"
fi
