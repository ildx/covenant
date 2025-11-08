# Covenant

Personal dotfiles for macOS, structured for Merlin (TBA).

<img width="1456" height="816" alt="image" src="https://github.com/user-attachments/assets/88a435cb-2ddf-4709-bb99-d6a41871a2a9" />

## Structure

```
covenant/
├── merlin.toml          # Root config: preinstall tools, profiles
├── config/
│   └── <tool>/
│       ├── merlin.toml  # Tool instructions
│       ├── config/      # Files to symlink
│       └── scripts/     # Setup scripts (optional)
```

## Files

### Root

**`merlin.toml`**
- System requirements (preinstall)
- Profiles per machine/use case
- Global settings

### Tool

**`config/<tool>/merlin.toml`**
- Dependencies
- Symlink definitions
- Scripts to run

**`config/<tool>/config/`**
- Config files to symlink

**`config/<tool>/scripts/`** *(optional)*
- Custom setup scripts

**`config/<tool>/*.toml`** *(optional)*
- Tool-specific data (e.g., `brew.toml`, `profiles.toml`)

## Link Patterns

```toml
# Directory (implicit source = "config/")
[[link]]
target = "~/.config/tool"

# File (explicit)
[[link]]
source = "config/.zshrc"
target = "~/.zshrc"

# Multiple files
[[link]]
target = "~/base/path"
files = [
  { source = "config/file.json", target = "file.json" }
]

# Directory to directory
[[link]]
source = "config/themes"
target = "~/themes"
```

## Tools

- [**brew**](https://brew.sh) - Homebrew package manager
- [**cursor**](https://cursor.sh) - AI code editor
- [**eza**](https://github.com/eza-community/eza) - Modern ls replacement
- [**ghostty**](https://ghostty.org) - Terminal emulator
- [**git**](https://git-scm.com) - Version control
- [**karabiner**](https://karabiner-elements.pqrs.org) - Keyboard customizer
- [**lazygit**](https://github.com/jesseduffield/lazygit) - Terminal UI for git
- [**mas**](https://github.com/mas-cli/mas) - Mac App Store CLI
- **misc** - Miscellaneous configs
- [**mise**](https://mise.jdx.dev) - Runtime version manager
- [**zellij**](https://zellij.dev) - Terminal multiplexer
- [**zsh**](https://www.zsh.org) - Z shell
