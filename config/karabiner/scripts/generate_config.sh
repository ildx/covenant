#!/bin/bash
#
# Karabiner Configuration Generator
#
# This script reads profiles.toml for profile definitions and generates
# karabiner.json by combining rule files from assets/complex_modifications/
#
# Each rule file can contain:
# - rules: Key modification rules
# - devices: Device-specific settings (optional, shared across profiles)
# - virtual_hid_keyboard: Keyboard type settings (optional, shared across profiles)
#
# Requirements: yq, jq (brew install yq jq)
#
# Usage:
#   ./generate_config.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$TOOL_DIR/config"
PROFILES_TOML="$TOOL_DIR/profiles.toml"
RULES_DIR="$CONFIG_DIR/assets/complex_modifications"
OUTPUT_FILE="$CONFIG_DIR/karabiner.json"

echo "🔧 Generating Karabiner configuration..."

# Get current hostname
HOSTNAME=$(hostname -s)
echo "💻 Hostname: $HOSTNAME"

# Check for yq
if ! command -v yq &> /dev/null; then
    echo "❌ Error: 'yq' is required but not found"
    echo ""
    echo "Install with:"
    echo "  brew install yq"
    echo ""
    echo "Or install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "❌ Error: 'jq' is required but not found"
    echo ""
    echo "Install with:"
    echo "  brew install jq"
    exit 1
fi

# Read profiles from profiles.toml
PROFILE_COUNT=$(yq eval '.profiles | length' "$PROFILES_TOML")

# Start building the JSON
echo '{"profiles":[]}' > "$OUTPUT_FILE"

# Function to check if hostname matches profile
should_select_profile() {
    local profile_index="$1"
    
    # Get hostname for this profile (if defined)
    local profile_hostname=$(yq eval ".profiles[$profile_index].hostname" "$PROFILES_TOML" 2>/dev/null)
    
    # Check if hostname matches (and is not null/empty)
    if [[ -n "$profile_hostname" ]] && [[ "$profile_hostname" != "null" ]] && [[ "$HOSTNAME" == "$profile_hostname" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Pre-scan to find if any profile matches hostname
MATCHED_PROFILE=""
for ((i=0; i<PROFILE_COUNT; i++)); do
    PROFILE_NAME=$(yq eval ".profiles[$i].name" "$PROFILES_TOML")
    if [[ $(should_select_profile "$i") == "true" ]]; then
        MATCHED_PROFILE="$PROFILE_NAME"
        echo "  ✓ Auto-selected profile: $PROFILE_NAME (hostname match)"
        break
    fi
done

# Process each profile
for ((i=0; i<PROFILE_COUNT; i++)); do
    PROFILE_NAME=$(yq eval ".profiles[$i].name" "$PROFILES_TOML")
    
    # Determine if this profile should be selected
    if [[ -n "$MATCHED_PROFILE" ]]; then
        # Hostname match found - only select the matched profile
        if [[ "$PROFILE_NAME" == "$MATCHED_PROFILE" ]]; then
            PROFILE_SELECTED="true"
        else
            PROFILE_SELECTED="false"
        fi
    else
        # No hostname match - use default from TOML
        PROFILE_SELECTED=$(yq eval ".profiles[$i].selected" "$PROFILES_TOML")
    fi
    RULE_COUNT=$(yq eval ".profiles[$i].rules | length" "$PROFILES_TOML")
    
    echo "  📋 Building profile: $PROFILE_NAME"
    
    # Collect all rules, devices, and virtual_hid_keyboard for this profile
    ALL_RULES="[]"
    DEVICES="[]"
    VHK="{}"
    
    for ((j=0; j<RULE_COUNT; j++)); do
        RULE_FILE=$(yq eval ".profiles[$i].rules[$j]" "$PROFILES_TOML")
        # Auto-append .json if not present
        if [[ ! "$RULE_FILE" == *.json ]]; then
            RULE_FILE="${RULE_FILE}.json"
        fi
        RULE_PATH="$RULES_DIR/$RULE_FILE"
        
        if [ ! -f "$RULE_PATH" ]; then
            echo "    ⚠️  Warning: Rule file not found: $RULE_FILE"
            continue
        fi
        
        echo "    📄 Loading $RULE_FILE"
        
        # Extract rules from the file and merge
        RULES=$(jq '.rules' "$RULE_PATH")
        ALL_RULES=$(echo "$ALL_RULES" | jq --argjson new "$RULES" '. + $new')
        
        # Extract devices if present (first one wins)
        if [ "$DEVICES" == "[]" ]; then
            FILE_DEVICES=$(jq '.devices // []' "$RULE_PATH")
            if [ "$FILE_DEVICES" != "[]" ]; then
                DEVICES="$FILE_DEVICES"
            fi
        fi
        
        # Extract virtual_hid_keyboard if present (first one wins)
        if [ "$VHK" == "{}" ]; then
            FILE_VHK=$(jq '.virtual_hid_keyboard // {}' "$RULE_PATH")
            if [ "$FILE_VHK" != "{}" ]; then
                VHK="$FILE_VHK"
            fi
        fi
    done
    
    # Build the profile JSON
    PROFILE=$(jq -n \
        --arg name "$PROFILE_NAME" \
        --argjson selected "$PROFILE_SELECTED" \
        --argjson rules "$ALL_RULES" \
        --argjson devices "$DEVICES" \
        --argjson vhk "$VHK" \
        '{
            "complex_modifications": {"rules": $rules},
            "devices": $devices,
            "name": $name,
            "selected": $selected,
            "virtual_hid_keyboard": $vhk
        }')
    
    # Add profile to the config
    jq --argjson profile "$PROFILE" '.profiles += [$profile]' "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp"
    mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
done

echo ""
echo "✅ Done! Generated configuration:"
jq -r '.profiles[] | "   [\(if .selected then "✓" else " " end)] \(.name): \(.complex_modifications.rules | length) rules"' "$OUTPUT_FILE"
echo ""
echo "💡 Karabiner-Elements will reload automatically"
