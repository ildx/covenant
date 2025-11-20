# Set eza theme based on system appearance
update_eza_theme() {
  dark_mode=$(osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')
  if [[ "$dark_mode" == "true" ]]; then
    theme="catppuccin-frappe-lavender"
  else
    theme="catppuccin-latte-sky"
  fi
  ln -sf "$HOME/.config/eza/themes/$theme.yml" "$HOME/.config/eza/theme.yml"
}

preexec() {
  update_eza_theme
  echo # Add a newline before output
}