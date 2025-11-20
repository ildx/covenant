#!/usr/bin/env bash
# start.sh - Set initial theme and start dark-notify

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

# First, set the theme based on current appearance
CURRENT_THEME=$(/opt/homebrew/bin/dark-notify -e 2>&1 | tail -1)
if [[ -n "$CURRENT_THEME" ]]; then
  "${SCRIPT_DIR}/notify.sh" "$CURRENT_THEME"
fi

# Then start dark-notify to watch for changes
exec /opt/homebrew/bin/dark-notify -c "${SCRIPT_DIR}/notify.sh"