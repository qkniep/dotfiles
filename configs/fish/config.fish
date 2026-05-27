fish_add_path -p ~/.local/share/solana/install/active_release/bin
fish_add_path -p ~/.qlty/bin
fish_add_path -p ~/.yarn/bin
fish_add_path -p ~/.cargo/bin
fish_add_path -p ~/.deno/bin
fish_add_path -p ~/.amp/bin
fish_add_path -p ~/.opencode/bin
fish_add_path -p ~/go/bin
fish_add_path -p ~/.local/share/gem/ruby/3.0.0/bin
fish_add_path -p ~/.local/bin

function nvm
    bass source ~/.nvm/nvm.sh -- no-use ';' nvm $argv
end

if status is-interactive
	set -g fish_term24bit 1

	zoxide init fish | source
	# starship init fish | source

	function fish_greeting
		set --local user_str (set_color -i blue; echo -n $USER; set_color normal)
		set --local time_str (set_color yellow; date +%T; set_color normal)
		#echo " Hello $user_str, welcome back!"
		#echo " The time is $time_str and this machine is called $hostname."
		#echo There are updates available: (set_color -i green; pacman -Qu | wc -l; set_color normal) on pacman and (set_color -i green; paru -Qu | wc -l; set_color normal) on paru
	end

	function wttr
		curl -fGsS "https://wttr.in/$argv?AFqtp"
	end

	function system-update
		switch (uname)
			case Darwin
				pushd ~/dotfiles; just update; just switch; popd
			case Linux
				if test -e /etc/NIXOS
					pushd ~/dotfiles
					just update
					sudo nixos-rebuild switch --flake .
					popd
				else
					sudo apt update; and sudo apt upgrade -y
					pushd ~/dotfiles
					nix flake update
					home-manager switch --flake .
					popd
				end
		end
		rustup update
		cargo install-update -a
	end

	# Vim Key Bindings
	fish_vi_key_bindings
	set fish_cursor_default block
	set fish_cursor_insert block

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
	alias vim "nvim"
	alias l "eza -la -s size"
	alias ls "eza"
	alias cat "bat"
	alias du "dust"
	alias top "btm"
	alias myip "curl https://ipecho.io/plain; echo"
	#alias alert 'notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
    alias claude-anza "CLAUDE_CONFIG_DIR=$HOME/.claude-anza claude"
    alias claude-personal "CLAUDE_CONFIG_DIR=$HOME/.claude-personal claude"

	# forgit installs `gi` -> `git-forgit ignore`, which fires when typing "git "
	abbr --erase gi 2>/dev/null
end

# opam configuration
source ~/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
