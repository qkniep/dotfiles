fish_add_path -p ~/.yarn/bin
fish_add_path -p ~/.cargo/bin
fish_add_path -p ~/go/bin
fish_add_path -p ~/.local/share/gem/ruby/3.0.0/bin
fish_add_path -p ~/.local/bin

if status is-interactive
	set -g fish_term24bit 1

	zoxide init fish | source
	starship init fish | source

	function fish_greeting
		echo Hello (set_color -i blue; echo -n $USER; set_color normal), welcome back!
		echo The time is (set_color yellow; date +%T; set_color normal) and this machine is called $hostname.
		#echo There are updates available: (set_color -i green; pacman -Qu | wc -l; set_color normal) on pacman and (set_color -i green; yay -Qu | wc -l; set_color normal) on yay.
	end

	function wttr
		curl -fGsS "https://wttr.in/$argv?AFqtp"
	end

	function system-update
		sudo pacman -Syyu
		yay -Syyu
		rustup update
	end

	# Vim Key Bindings
	fish_vi_key_bindings
	set fish_cursor_default block
	set fish_cursor_insert line

	# Syntax Highlighting
	set fish_color_normal white
	set fish_color_param white
	set fish_color_command green
	set fish_color_keyword orange
	set fish_color_error red --bold
	set fish_color_valid_path yellow
	set fish_color_quote brgreen
	set fish_color_escape orange
	set fish_color_end brmagenta

	# Aliases
	alias vim "/usr/bin/nvim"
	alias l "/usr/bin/exa -la -s size"
	alias ls "/usr/bin/exa"
	alias cat "/usr/bin/bat"
	alias du "/usr/bin/dust"
	alias top "/usr/bin/btm"
	alias myip "curl https://ipecho.io/plain; echo"
	#alias alert 'notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
end
