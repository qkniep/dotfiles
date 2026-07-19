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

	if command -q zoxide
		zoxide init fish | source
	end
	# starship init fish | source

	# atuin: SQLite shell history; rebinds Ctrl+R (and Up)
	if command -q atuin
		atuin init fish | source
	end

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

	# yazi wrapper: open the file manager, then cd to wherever you quit (q).
	# Use `Q` inside yazi to quit without changing directory.
	function y
		set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
		yazi $argv --cwd-file="$tmp"
		if read -z cwd <"$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
			builtin cd -- "$cwd"
		end
		rm -f -- "$tmp"
	end

	# Switch Ghostty + Neovim + tmux colorschemes together, live. Usage: theme <id>
	# Ghostty: writes a one-line override into the AppSupport config — macOS
	#   loads it after the nix-managed XDG config, so its `theme` wins — then
	#   reloads all windows via SIGUSR2.
	# Neovim: writes the id to nvim's state dir (init.lua reads it on startup)
	#   and switches running instances through their server sockets (set_theme
	#   is defined in init.lua).
	# tmux: writes a tab-pill color snippet (sourced by tmux.conf via `source -q`
	#   so it survives server restarts) and applies it to a running server.
	function theme --argument-names name
		set -l ids everblush everforest-light adwaita adwaita-dark kanagawa-wave srcery gruvbox-dark-hard
		set -l ghostty_names Everblush "Everforest Light Med" Adwaita "Adwaita Dark" "Kanagawa Wave" Srcery "Gruvbox Dark Hard"
		set -l light_ids everforest-light adwaita
		set -l idx (contains -i -- "$name" $ids)
		if test -z "$idx"
			echo "usage: theme <id>" >&2
			printf '  %s\n' $ids >&2
			return 1
		end

		set -l ghostty_dir "$HOME/Library/Application Support/com.mitchellh.ghostty"
		mkdir -p "$ghostty_dir"
		printf '# Written by the fish `theme` function; overrides the nix-managed config.\ntheme = %s\n' $ghostty_names[$idx] >"$ghostty_dir/config"
		pkill -USR2 -x ghostty

		mkdir -p ~/.local/state/nvim
		echo $name >~/.local/state/nvim/theme
		set -l tmpdir (test -n "$TMPDIR"; and echo $TMPDIR; or echo /tmp)
		for sock in $tmpdir/nvim.$USER/*/nvim.*.0
			nvim --server $sock --remote-expr "v:lua.set_theme('$name')" >/dev/null 2>&1
		end

		# tmux tab pills: dark pills on dark themes, light (ANSI white) on light
		set -l tab_bg black
		set -l tab_fg white
		if contains -- $name $light_ids
			set tab_bg white
			set tab_fg black
		end
		mkdir -p ~/.local/state/tmux
		printf 'set -g @tab-bg "%s"\nset -g @tab-fg "%s"\n' $tab_bg $tab_fg >~/.local/state/tmux/theme.conf
		if tmux has-session 2>/dev/null
			tmux source-file ~/.local/state/tmux/theme.conf
			tmux refresh-client -S 2>/dev/null
		end
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
    alias claude-anza "CLAUDE_CONFIG_DIR=$HOME/.claude-anza command claude"
    alias claude-personal "CLAUDE_CONFIG_DIR=$HOME/.claude-personal command claude"
    alias claude "CLAUDE_CONFIG_DIR=$HOME/.claude-personal command claude"

	# Tabline build indicator: while a build-like command runs, set
	# @build-state=running on the tmux window so the status line shows a
	# cyan segment (see tmux.conf). Intentionally narrow — only matches
	# commands the user explicitly considers "builds" (cargo subcommands,
	# nix build/flake check, system rebuilds, just recipes). Interactive
	# tools (nvim, less, …) never match.
	# Optional leading VAR=value assignments (bare, "double", or 'single'
	# quoted) are consumed before the command match, so e.g.
	#   CARGO_INCREMENTAL=0 RUSTFLAGS="-C opt-level=3" cargo nextest run
	# still trips the indicator. Wrapper commands (env/time/nice) aren't
	# covered — extend to a tokenized matcher if those start showing up.
	set -g _build_state_pattern '^\s*(?:[A-Za-z_][A-Za-z0-9_]*=(?:"[^"]*"|\'[^\']*\'|\S*)\s+)*(cargo\s+(build|test|check|clippy|doc|run|nextest)|nix\s+(build|flake\s+check)|nixos-rebuild|darwin-rebuild|home-manager\s+switch|just\s+(build|test|switch|update))(\s|$)'

	function _build_state_preexec --on-event fish_preexec
		test -n "$TMUX_PANE"; or return
		string match -rq -- $_build_state_pattern $argv[1]; or return
		tmux set-option -w -t "$TMUX_PANE" @build-state running
		tmux refresh-client -S
	end

	function _build_state_postexec --on-event fish_postexec
		test -n "$TMUX_PANE"; or return
		set -l state (tmux show-options -wqv -t "$TMUX_PANE" @build-state 2>/dev/null)
		test "$state" = running; or return
		tmux set-option -w -t "$TMUX_PANE" -u @build-state
		tmux refresh-client -S
	end
end

# opam configuration
source ~/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
