# Setup Oh My Zsh (The framework that manages the terminal's theme)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="setupx09-agnoster"

# Enable helpful terminal plugins
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Setup Node Version Manager (NVM) for JavaScript developers
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Add custom local programs to the system path so they can be run anywhere
export PATH="$HOME/.local/bin:$PATH"

# Display system info (Neofetch) with specific colors when opening a new terminal
fastfetch
