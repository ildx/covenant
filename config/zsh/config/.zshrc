#------------------------------------------------------
# ZSH Configuration
#------------------------------------------------------

CONFIG_DIR="$HOME/.config"
DEFAULTS_DIR="$CONFIG_DIR/zsh/defaults"

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $CONFIG_DIR/zsh/omp.toml)"
fi

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

source $DEFAULTS_DIR/alias.zsh
source $DEFAULTS_DIR/color.zsh
source $DEFAULTS_DIR/plugins.zsh

configs=(brew cursor eza lazygit mise zellij)
for c in $configs; do
  [[ -f $CONFIG_DIR/$c/$c.zsh ]] && source $CONFIG_DIR/$c/$c.zsh
done