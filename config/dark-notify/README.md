# Dark Notify - Automatic Theme Switcher

This setup automatically switches themes for eza and zellij when macOS appearance changes between light and dark mode.

## Files

- `scripts/setup.sh` - Setup script that generates and installs the LaunchAgent
- `scripts/start.sh` - Main entry point that sets initial theme and starts dark-notify
- `scripts/notify.sh` - Called by dark-notify when appearance changes, updates all themes
- `agents/local.dark-notify.plist.template` - Template for LaunchAgent plist (used by setup script)

## Initial Setup

Run the setup script to install the LaunchAgent:

```bash
cd ~/.config/dark-notify/scripts
./setup.sh
```

This will:
1. Generate `agents/local.dark-notify.plist` from the template with your home directory
2. Copy it to `~/Library/LaunchAgents/`
3. Load the LaunchAgent so it starts running

## How It Works

1. **LaunchAgent** (`local.dark-notify.plist`) is loaded by macOS on login
2. **start.sh** runs and:
   - Gets the current macOS appearance (light/dark)
   - Calls `notify.sh` to set the initial theme
   - Starts `dark-notify` to watch for appearance changes
3. When appearance changes, `dark-notify` calls `notify.sh` with "light" or "dark"
4. **notify.sh** sources the theme change scripts and calls their functions:
   - `eza/scripts/change_theme.sh` → `switch_eza_theme()`
   - `zellij/scripts/change_theme.sh` → `switch_zellij_theme()`

## Adding New Applications

To add theme switching for another application:

1. Create a script in `~/.config/<app>/scripts/change_theme.sh` with a function like `switch_<app>_theme()`
2. Add it to the `MODULES` array in `notify.sh`:
   ```bash
   MODULES=(
       # ... existing modules ...
       "<app>/scripts/change_theme.sh"
       "switch_<app>_theme"
   )
   ```

## Uninstalling

```bash
launchctl unload ~/Library/LaunchAgents/local.dark-notify.plist
rm ~/Library/LaunchAgents/local.dark-notify.plist
```

## Portability

All scripts use `$HOME` or relative paths, making this setup portable across different machines. The `setup.sh` script automatically detects the current home directory and generates the LaunchAgent plist accordingly.

