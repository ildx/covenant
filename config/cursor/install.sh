#!/bin/bash

# Install script for Cursor configuration
# - Creates symlinks for settings and keybindings
# - Installs extensions from TOML file

set -e

# Colors for output
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
RESET='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
CURSOR_USER_DIR="${HOME}/Library/Application Support/Cursor/User"
EXTENSIONS_TOML="${CONFIG_DIR}/extensions.toml"

echo -e "${BOLD}${BLUE}=== Cursor Configuration Setup ===${RESET}\n"

# Check if Cursor is installed
if ! command -v cursor &> /dev/null; then
    echo -e "${RED}✗ Cursor is not installed or not in PATH${RESET}"
    echo -e "${GRAY}  Please install Cursor first or add it to your PATH${RESET}"
    exit 1
fi

echo -e "${GREEN}✓ Cursor found${RESET}\n"

# ============================================================================
# 1. Create/Update Symlinks
# ============================================================================

echo -e "${BOLD}${BLUE}1. Setting up configuration symlinks${RESET}\n"

# Create Cursor User directory if it doesn't exist
if [ ! -d "$CURSOR_USER_DIR" ]; then
    echo -e "${YELLOW}  Creating Cursor User directory...${RESET}"
    mkdir -p "$CURSOR_USER_DIR"
fi

# Function to create symlink
create_symlink() {
    local source_file=$1
    local target_file=$2
    local file_name=$3
    
    # Check if source exists
    if [ ! -f "$source_file" ]; then
        echo -e "${RED}  ✗ Source file not found: ${source_file}${RESET}"
        return 1
    fi
    
    # If target exists and is a symlink, remove it
    if [ -L "$target_file" ]; then
        echo -e "${GRAY}  Removing existing symlink: ${file_name}${RESET}"
        rm "$target_file"
    # If target exists and is a regular file, back it up
    elif [ -f "$target_file" ]; then
        echo -e "${YELLOW}  Backing up existing file: ${file_name}${RESET}"
        mv "$target_file" "${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create symlink
    ln -s "$source_file" "$target_file"
    echo -e "${GREEN}  ✓ Symlinked: ${file_name}${RESET}"
}

# Create symlinks for settings and keybindings
create_symlink "${CONFIG_DIR}/settings.json" "${CURSOR_USER_DIR}/settings.json" "settings.json"
create_symlink "${CONFIG_DIR}/keybindings.json" "${CURSOR_USER_DIR}/keybindings.json" "keybindings.json"

echo ""

# ============================================================================
# 2. Install Extensions
# ============================================================================

echo -e "${BOLD}${BLUE}2. Installing extensions${RESET}\n"

# Check if extensions.toml exists
if [ ! -f "$EXTENSIONS_TOML" ]; then
    echo -e "${RED}✗ Extensions file not found: ${EXTENSIONS_TOML}${RESET}"
    exit 1
fi

# Get list of currently installed extensions
echo -e "${GRAY}  Checking installed extensions...${RESET}"
INSTALLED_EXTENSIONS=$(cursor --list-extensions 2>/dev/null || echo "")

# Parse TOML file and extract extensions
# This is a simple parser that looks for lines like: "extension-id",
EXTENSIONS=$(grep -E '^\s*"[^"]+",?\s*$' "$EXTENSIONS_TOML" | sed 's/[",]//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ -z "$EXTENSIONS" ]; then
    echo -e "${YELLOW}  No extensions found in ${EXTENSIONS_TOML}${RESET}"
    exit 0
fi

# Count extensions
TOTAL=$(echo "$EXTENSIONS" | wc -l | tr -d ' ')
INSTALLED=0
SKIPPED=0
FAILED=0

echo -e "${GRAY}  Found ${TOTAL} extensions to process${RESET}\n"

# Install each extension
while IFS= read -r extension; do
    # Skip empty lines
    [ -z "$extension" ] && continue
    
    # Check if already installed
    if echo "$INSTALLED_EXTENSIONS" | grep -q "^${extension}$"; then
        echo -e "${GRAY}  ⊙ ${extension} (already installed)${RESET}"
        ((SKIPPED++))
    else
        echo -e "${BLUE}  ↓ Installing ${extension}...${RESET}"
        if cursor --install-extension "$extension" --force > /dev/null 2>&1; then
            echo -e "${GREEN}  ✓ ${extension}${RESET}"
            ((INSTALLED++))
        else
            echo -e "${RED}  ✗ Failed to install ${extension}${RESET}"
            ((FAILED++))
        fi
    fi
done <<< "$EXTENSIONS"

# ============================================================================
# Summary
# ============================================================================

echo -e "\n${BOLD}${BLUE}=== Summary ===${RESET}\n"
echo -e "${GREEN}  ✓ Configuration files symlinked${RESET}"
echo -e "${GREEN}  ✓ Extensions processed: ${TOTAL}${RESET}"
echo -e "${BLUE}    • Installed: ${INSTALLED}${RESET}"
echo -e "${GRAY}    • Skipped (already installed): ${SKIPPED}${RESET}"

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}    • Failed: ${FAILED}${RESET}"
fi

echo -e "\n${BOLD}${GREEN}Done! Restart Cursor to apply all changes.${RESET}\n"

