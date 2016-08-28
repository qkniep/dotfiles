# if not running interactively, do nothing
[ -z "$PS1" ] && return


# --------------------------------------------------------------
# History
# --------------------------------------------------------------

HISTCONTROL=ignoreboth  # ignore duplicates and commands starting with space
HISTSIZE=1000           # limit history list to 1000 items
HISTFILESIZE=2000       # limit histiry file to 2000 items
shopt -s histappend     # append to the history file, don't overwrite it
shopt -s checkwinsize   # check window size after command
#shopt -s globstar


# --------------------------------------------------------------
# Colors
# --------------------------------------------------------------

force_color_prompt=yes  # use colored prompt

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"


# --------------------------------------------------------------
# Aliases
# --------------------------------------------------------------

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi


# --------------------------------------------------------------
# Environment Variables
# --------------------------------------------------------------

export TERM=xterm-256color


# --------------------------------------------------------------
# Functions
# --------------------------------------------------------------

# add an "=" command to quickly execute bash and print the answer
=() {
	echo "$(($@))"
}

# extract any archive with one command
extract() {
	if [ -z "$1" ]; then
		echo "usage: extract <file_to_extract>"
	else
		if [ -f $1 ]; then
			case $1 in
				*.tar.bz2)   tar xvjf $1    ;;
				*.tar.gz)    tar xvzf $1    ;;
				*.tar.xz)    tar xvJf $1    ;;
				*.lzma)      unlzma $1      ;;
				*.bz2)       bunzip2 $1     ;;
				*.rar)       unrar x -ad $1 ;;
				*.gz)        gunzip $1      ;;
				*.tar)       tar xvf $1     ;;
				*.tbz2)      tar xvjf $1    ;;
				*.tgz)       tar xvzf $1    ;;
				*.zip)       unzip $1       ;;
				*.Z)         uncompress $1  ;;
				*.7z)        7z x $1        ;;
				*.xz)        unxz $1        ;;
				*.exe)       cabextract $1  ;;
				*)           echo "unknown file format" ;;
			esac
		else
			echo "file does not exist: $1"
		fi
	fi
}
