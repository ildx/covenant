# Cursor configuration
export CURSOR_CONFIG_DIR="$HOME/.config/cursor"

# Export currently installed extensions to extensions.txt
alias cde="cursor --list-extensions | sort > \$CURSOR_CONFIG_DIR/extensions.txt"
