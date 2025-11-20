#!/usr/bin/env bash
# notify.sh - Notify programs that MacOS appearance has changed

set -e -u -o pipefail

# --- CONFIGURATION ---

# Base path for configuration files.
CONFIG_DIR="${HOME}/.config"

# Define the modules as pairs of script paths and function names.
# Each module has two entries: path followed by function name.

MODULES=(
    # --- EZA ---
    "eza/scripts/change_theme.sh"
    "switch_eza_theme"

    # --- ZELLIJ ---
    "zellij/scripts/change_theme.sh"
    "switch_zellij_theme"
)

# --- EXECUTION ---

if [[ $# -eq 0 ]]; then
  exit 1 
fi

THEME_ARG="$1" # 'light' or 'dark'

# Loop through modules in pairs (path, function)
i=0
while [[ $i -lt ${#MODULES[@]} ]]; do
    MODULE_PATH="${CONFIG_DIR}/${MODULES[$i]}"
    TARGET_FUNCTION="${MODULES[$((i + 1))]}"
    i=$((i + 2))

    # Check if the script file exists
    if [[ ! -f "$MODULE_PATH" ]]; then
      continue
    fi

    # Source the script to load functions
    source "$MODULE_PATH"
    
    # Check if the function exists and execute it
    if [[ $(type -t "$TARGET_FUNCTION") == "function" ]]; then
      "$TARGET_FUNCTION" "$THEME_ARG"
      
      # Unset the function to prevent name collisions
      unset -f "$TARGET_FUNCTION" 
    fi
done

exit 0