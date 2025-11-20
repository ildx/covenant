#!/usr/bin/env bash

set -e -u -o pipefail

ZELLIJ_CONFIG="${HOME}/.config/zellij/config.kdl"
ZELLIJ_THEME_LIGHT="catppuccin-latte"
ZELLIJ_THEME_DARK="catppuccin-frappe"

switch_zellij_theme() {
  local theme="$1"
  local THEME=""

  # Invalid argument
  if [[ "$theme" != "light" && "$theme" != "dark" ]]; then
    echo "Error: Invalid theme '$theme'. Expected 'light' or 'dark'." >&2
    return 1
  fi

  # Set theme
  if [[ "$theme" == "light" ]]; then
    THEME="$ZELLIJ_THEME_LIGHT"
  else
    THEME="$ZELLIJ_THEME_DARK"
  fi

  # Ensure theme_dir is set (uncomment if needed)
  if ! grep -q "^theme_dir" "$ZELLIJ_CONFIG"; then
    # Check if it's commented out
    if grep -q "^// theme_dir" "$ZELLIJ_CONFIG"; then
      # Uncomment theme_dir line
      sed -i '' -E "s|^// theme_dir.*|theme_dir \"${HOME}/.config/zellij/themes\"|" "$ZELLIJ_CONFIG"
    else
      # Add theme_dir before the theme line (or at end of file)
      # Find a good insertion point - before the theme line if it exists
      if grep -q "^// theme" "$ZELLIJ_CONFIG"; then
        sed -i '' -E "/^\/\/ theme/a\\
theme_dir \"${HOME}/.config/zellij/themes\"
" "$ZELLIJ_CONFIG"
      else
        # Add at end of file
        echo "" >> "$ZELLIJ_CONFIG"
        echo "theme_dir \"${HOME}/.config/zellij/themes\"" >> "$ZELLIJ_CONFIG"
      fi
    fi
  fi

  # Update or add theme line
  if grep -q "^theme " "$ZELLIJ_CONFIG"; then
    # Theme line exists, update it
    sed -i '' -E "s|^theme .*|theme \"$THEME\"|" "$ZELLIJ_CONFIG"
  elif grep -q "^// theme" "$ZELLIJ_CONFIG"; then
    # Theme line is commented, uncomment and set it
    sed -i '' -E "s|^// theme .*|theme \"$THEME\"|" "$ZELLIJ_CONFIG"
  else
    # Theme line doesn't exist, add it
    # Add after theme_dir if it exists, or at a reasonable location
    if grep -q "^theme_dir" "$ZELLIJ_CONFIG"; then
      sed -i '' -E "/^theme_dir/a\\
theme \"$THEME\"
" "$ZELLIJ_CONFIG"
    else
      # Add before the commented theme section
      sed -i '' -E "/^\/\/ Choose the theme/i\\
theme \"$THEME\"
" "$ZELLIJ_CONFIG"
    fi
  fi
}

# Only execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ $# -eq 0 ]]; then
    echo "Error: Missing theme argument." >&2
    exit 1
  fi
  switch_zellij_theme "$1"
fi