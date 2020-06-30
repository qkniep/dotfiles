# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="/Users/qkniep/.oh-my-zsh"

fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

#ZSH_THEME="pure"
#ZSH_THEME="sunrise"

CASE_SENSITIVE="true"
ENABLE_CORRECTION="true"

# HYPHEN_INSENSITIVE="true"
# DISABLE_AUTO_UPDATE="true"
# DISABLE_UPDATE_PROMPT="true"
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

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
