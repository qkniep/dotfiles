export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export ZSH="/Users/qkniep/.oh-my-zsh"

eval "$(starship init zsh)"

CASE_SENSITIVE="true"
ENABLE_CORRECTION="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

plugins=(
	git
	sudo
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


# User Configuration

# PATH Environment Variable
PATH=$HOME/.cargo/bin:$PATH
PATH=$HOME/go/bin:$PATH
PATH=$HOME/flutter/bin:$PATH
PATH=$HOME/flutter/bin/cache/dart-sdk/bin:$PATH
PATH=$HOME/flutter/.pub-cache/bin:$PATH
PATH=$HOME/Library/Android/sdk/tools:$PATH
PATH=$HOME/Library/Android/sdk/platform-tools:$PATH

# VI Mode
bindkey -v
export KEYTIMEOUT=1

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
else
	export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Base16 Shell Color Themes
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# pyenv Python Version Manager
if command -v pyenv 1>/dev/null 2>&1; then
	eval "$(pyenv init -)"
fi

alias vim="/usr/local/bin/nvim"
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias myip="curl http://ipecho.net/plain; echo"
