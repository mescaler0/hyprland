# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"  # o "agnoster", "powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    history-substring-search
)

source $ZSH/oh-my-zsh.sh

# Autosuggestions config
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
bindkey '^[[Z' autosuggest-accept  # Shift+Tab per accettare

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.config/zsh/.zsh_history

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias vim='nvim'
alias update='sudo pacman -Syu'

# Path
export PATH="$HOME/.local/bin:$PATH"

