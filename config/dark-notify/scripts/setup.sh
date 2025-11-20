#!/usr/bin/env bash
# setup.sh - Setup script for dark-notify LaunchAgent
# This script generates the LaunchAgent plist file with the correct home directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="${SCRIPT_DIR}/agents"
TEMPLATE_FILE="${AGENTS_DIR}/local.dark-notify.plist.template"
OUTPUT_FILE="${AGENTS_DIR}/local.dark-notify.plist"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
TARGET_PLIST="${LAUNCH_AGENTS_DIR}/local.dark-notify.plist"

# Check if template exists
if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Error: Template file not found: $TEMPLATE_FILE" >&2
  exit 1
fi

# Generate the plist file by replacing the placeholder
echo "Generating LaunchAgent plist file..."
sed "s|__HOME_DIR__|${HOME}|g" "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "✓ Generated: $OUTPUT_FILE"

# Copy to LaunchAgents directory
echo "Installing LaunchAgent..."
mkdir -p "$LAUNCH_AGENTS_DIR"
cp "$OUTPUT_FILE" "$TARGET_PLIST"

echo "✓ Installed: $TARGET_PLIST"

# Unload existing agent if it exists
if launchctl list local.dark-notify &>/dev/null; then
  echo "Unloading existing LaunchAgent..."
  launchctl unload "$TARGET_PLIST" 2>/dev/null || true
fi

# Load the new agent
echo "Loading LaunchAgent..."
launchctl load "$TARGET_PLIST"

echo ""
echo "✓ Setup complete! The dark-notify LaunchAgent has been installed and started."
echo ""
echo "To verify it's running:"
echo "  launchctl list local.dark-notify"
echo ""
echo "To uninstall:"
echo "  launchctl unload $TARGET_PLIST"
echo "  rm $TARGET_PLIST"

