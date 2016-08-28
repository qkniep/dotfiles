# some ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# add an "alert" alias for long running commands (example: "sleep 10; alert")
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# public IP
alias myip="curl http://ipecho.net/plain; echo"
