#!/bin/bash
#
# Karabiner Configuration Generator
#
# This script generates karabiner.json by combining profiles.json and rules.json
# from assets/complex_modifications/
#
# - profiles.json: Contains profile definitions with empty complex_modifications
# - rules.json: Contains the rules to be inserted into each profile's complex_modifications
#
# Requirements: jq (brew install jq)
#
# Usage:
#   ./generate_config.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$TOOL_DIR/config"
ASSETS_DIR="$CONFIG_DIR/assets/complex_modifications"
PROFILES_FILE="$ASSETS_DIR/profiles.json"
RULES_FILE="$ASSETS_DIR/rules.json"
OUTPUT_FILE="$CONFIG_DIR/karabiner.json"

echo "🔧 Generating Karabiner configuration..."

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "❌ Error: 'jq' is required but not found"
    echo ""
    echo "Install with:"
    echo "  brew install jq"
    exit 1
fi

# Check if input files exist
if [ ! -f "$PROFILES_FILE" ]; then
    echo "❌ Error: profiles.json not found at $PROFILES_FILE"
    exit 1
fi

if [ ! -f "$RULES_FILE" ]; then
    echo "❌ Error: rules.json not found at $RULES_FILE"
    exit 1
fi

echo "  📄 Loading profiles from profiles.json"
echo "  📄 Loading rules from rules.json"

# Read the rules from rules.json
RULES=$(jq '.rules' "$RULES_FILE")

# Read profiles and inject rules into each profile's complex_modifications
jq --argjson rules "$RULES" '
  .profiles |= map(
    .complex_modifications = {"rules": $rules}
  )
' "$PROFILES_FILE" > "$OUTPUT_FILE"

echo ""
echo "✅ Done! Generated configuration:"
jq -r '.profiles[] | "   [\(if .selected then "✓" else " " end)] \(.name): \(.complex_modifications.rules | length) rules"' "$OUTPUT_FILE"
echo ""
echo "💡 Karabiner-Elements will reload automatically"
