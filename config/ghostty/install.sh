#!/bin/bash

# Install script for Ghostty themes
# - Creates symlinks for custom themes to Ghostty's theme directory

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
THEMES_DIR="${SCRIPT_DIR}/config/themes"
GHOSTTY_THEMES_DIR="/Applications/Ghostty.app/Contents/Resources/ghostty/themes"

echo -e "${BOLD}${BLUE}=== Ghostty Themes Setup ===${RESET}\n"

# Check if Ghostty is installed
if [ ! -d "/Applications/Ghostty.app" ]; then
    echo -e "${RED}✗ Ghostty is not installed${RESET}"
    echo -e "${GRAY}  Please install Ghostty first${RESET}"
    exit 1
fi

echo -e "${GREEN}✓ Ghostty found${RESET}\n"

# Check if themes directory exists
if [ ! -d "$THEMES_DIR" ]; then
    echo -e "${RED}✗ Themes directory not found: ${THEMES_DIR}${RESET}"
    exit 1
fi

# Check if there are any theme files
if [ -z "$(ls -A "$THEMES_DIR" 2>/dev/null | grep -v '^\.')" ]; then
    echo -e "${YELLOW}No theme files found in ${THEMES_DIR}${RESET}"
    echo -e "${GRAY}Add theme files to this directory and run the script again${RESET}\n"
    exit 0
fi

# Check if Ghostty themes directory exists
if [ ! -d "$GHOSTTY_THEMES_DIR" ]; then
    echo -e "${RED}✗ Ghostty themes directory not found: ${GHOSTTY_THEMES_DIR}${RESET}"
    echo -e "${GRAY}  This might indicate an incompatible Ghostty version${RESET}"
    exit 1
fi

# ============================================================================
# Symlink Themes
# ============================================================================

echo -e "${BOLD}${BLUE}Symlinking custom themes${RESET}\n"

TOTAL=0
INSTALLED=0
SKIPPED=0

# Process each theme file
for theme_file in "$THEMES_DIR"/*; do
    # Skip if not a file
    [ ! -f "$theme_file" ] && continue
    
    ((TOTAL++))
    
    theme_name=$(basename "$theme_file")
    target_file="${GHOSTTY_THEMES_DIR}/${theme_name}"
    
    # If target exists and is a symlink pointing to our file, skip
    if [ -L "$target_file" ] && [ "$(readlink "$target_file")" = "$theme_file" ]; then
        echo -e "${GRAY}  ⊙ ${theme_name} (already linked)${RESET}"
        ((SKIPPED++))
    else
        # If target exists, back it up (unless it's already a symlink)
        if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
            echo -e "${YELLOW}  Backing up existing theme: ${theme_name}${RESET}"
            mv "$target_file" "${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
        elif [ -L "$target_file" ]; then
            # Remove old symlink
            rm "$target_file"
        fi
        
        # Create symlink
        ln -s "$theme_file" "$target_file"
        echo -e "${GREEN}  ✓ ${theme_name}${RESET}"
        ((INSTALLED++))
    fi
done

# ============================================================================
# Summary
# ============================================================================

echo -e "\n${BOLD}${BLUE}=== Summary ===${RESET}\n"

if [ $TOTAL -eq 0 ]; then
    echo -e "${YELLOW}  No theme files found in ${THEMES_DIR}${RESET}"
else
    echo -e "${GREEN}  ✓ Themes processed: ${TOTAL}${RESET}"
    echo -e "${BLUE}    • Linked: ${INSTALLED}${RESET}"
    echo -e "${GRAY}    • Skipped (already linked): ${SKIPPED}${RESET}"
    
    echo -e "\n${GRAY}  Run 'ghostty --list-themes' to see all available themes${RESET}"
fi

echo -e "\n${BOLD}${GREEN}Done!${RESET}\n"

