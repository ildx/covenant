# Initialize Homebrew environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# Homebrew aliases
alias bu="brew update && brew upgrade && brew cleanup"  # Update, upgrade, and cleanup
alias bi="brew install"                                  # Install formula
alias bic="brew install --cask"                          # Install cask
alias bl="brew list"                                     # List installed packages
alias bn="brew uninstall"                                # Uninstall package
