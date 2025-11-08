#!/bin/bash

# Generate default Zellij configuration
# Merlin handles directory creation via symlinking

set -e

echo "🔧 Generating default Zellij configuration..."

# Check if zellij is installed
if ! command -v zellij &> /dev/null; then
    echo "❌ Error: zellij is not installed"
    echo "   Install with: brew install zellij"
    exit 1
fi

# Dump default config
zellij setup --dump-config > ~/.config/zellij/config.kdl

echo "✅ Done! Default config generated at ~/.config/zellij/config.kdl"

