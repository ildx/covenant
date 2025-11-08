#!/bin/bash

# Install script for Cursor extensions
# Merlin handles symlinking via merlin.toml
# This script ONLY installs extensions from extensions.txt

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
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
EXTENSIONS_FILE="${CONFIG_DIR}/extensions.txt"

echo -e "${BOLD}${BLUE}=== Cursor Extensions Setup ===${RESET}\n"

# Check if Cursor is installed
if ! command -v cursor &> /dev/null; then
    echo -e "${RED}✗ Cursor is not installed or not in PATH${RESET}"
    echo -e "${GRAY}  Please install Cursor first or add it to your PATH${RESET}"
    exit 1
fi

echo -e "${GREEN}✓ Cursor found${RESET}\n"

# Check if extensions.txt exists
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo -e "${RED}✗ Extensions file not found: ${EXTENSIONS_FILE}${RESET}"
    exit 1
fi

# Get list of currently installed extensions
echo -e "${GRAY}  Checking installed extensions...${RESET}"
INSTALLED_EXTENSIONS=$(cursor --list-extensions 2>/dev/null || echo "")

# Read extensions from file
EXTENSIONS=$(cat "$EXTENSIONS_FILE")

if [ -z "$EXTENSIONS" ]; then
    echo -e "${YELLOW}  No extensions found in ${EXTENSIONS_FILE}${RESET}"
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
echo -e "${GREEN}  ✓ Extensions processed: ${TOTAL}${RESET}"
echo -e "${BLUE}    • Installed: ${INSTALLED}${RESET}"
echo -e "${GRAY}    • Skipped (already installed): ${SKIPPED}${RESET}"

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}    • Failed: ${FAILED}${RESET}"
fi

echo -e "\n${BOLD}${GREEN}Done! Restart Cursor to apply all changes.${RESET}\n"

