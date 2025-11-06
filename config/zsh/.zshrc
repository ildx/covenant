# OH MY!
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/zsh/omp.toml)"
fi

# Config
C="$HOME/.config"
source $Z/aliases.zsh
source $Z/colorman.zsh
source $Z/profile.zsh
source $Z/plugins.zsh

# Other
Z="$C/zsh/config"
source $C/cursor/config/cursor.zsh
source $C/eza/config/eza.zsh
source $C/mise/config/mise.zsh
source $C/zellij/config/zellij.zsh