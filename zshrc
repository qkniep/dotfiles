export ZSH="$HOME/.oh-my-zsh"

eval "$(starship init zsh)"

CASE_SENSITIVE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line if you want to disable marking untracked files under VCS as dirty.
# This makes repository status check for large repositories much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
	git
	sudo
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# PATH Environment Variable
PATH=$HOME/.cargo/bin:$PATH
PATH=$GOPATH/bin:$PATH
PATH=$HOME/flutter/bin:$PATH
PATH=$HOME/flutter/bin/cache/dart-sdk/bin:$PATH
PATH=$HOME/flutter/.pub-cache/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

# VI Mode
bindkey -v
export KEYTIMEOUT=1

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
else
	export EDITOR='nvim'
fi

alias vim="/usr/bin/nvim"
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias myip="curl https://ipecho.io/plain; echo"
