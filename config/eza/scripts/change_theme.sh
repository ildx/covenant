#!/usr/bin/env bash

set -e -u -o pipefail

EZA_DIR="${HOME}/.config/eza"
EZA_THEME_LIGHT="catppuccin-latte-sky"
EZA_THEME_DARK="catppuccin-frappe-lavender"

switch_eza_theme() {
  local theme="$1"
  local THEME=""

  # Invalid argument
  if [[ "$theme" != "light" && "$theme" != "dark" ]]; then
    echo "Error: Invalid theme '$theme'. Expected 'light' or 'dark'." >&2
    return 1
  fi

  # Set theme
  if [[ "$theme" == "light" ]]; then
    THEME="$EZA_THEME_LIGHT"
  else
    THEME="$EZA_THEME_DARK"
  fi

  # Link
  ln -sf "${EZA_DIR}/themes/${THEME}.yml" "${EZA_DIR}/theme.yml"
}

# Only execute if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ $# -eq 0 ]]; then
    echo "Error: Missing theme argument." >&2
    exit 1
  fi
  switch_eza_theme "$1"
fi