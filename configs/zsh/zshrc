eval "$(starship init zsh)"

# OMZ Settings
CASE_SENSITIVE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"

plugins=(
	git
	sudo
	zsh-autosuggestions
	zsh-syntax-highlighting
)

export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# PATH Environment Variable
PATH=$HOME/.yarn/bin:$PATH
PATH=$HOME/.cargo/bin:$PATH
PATH=$HOME/go/bin:$PATH
PATH=$HOME/flutter/bin:$PATH
PATH=$HOME/flutter/bin/cache/dart-sdk/bin:$PATH
PATH=$HOME/flutter/.pub-cache/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

# VI Mode
bindkey -v
export KEYTIMEOUT=1

# Locales
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
else
	export EDITOR='nvim'
fi

# Aliases
alias vim="/usr/bin/nvim"
alias l="/usr/bin/exa -la -s size"
alias ls="/usr/bin/exa"
alias cat="/usr/bin/bat"
alias du="/usr/bin/dust"
alias top="/usr/bin/btm"

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias myip="curl https://ipecho.io/plain; echo"
