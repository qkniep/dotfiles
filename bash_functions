#!/bin/bash

# quickly execute bash and print the answer
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
