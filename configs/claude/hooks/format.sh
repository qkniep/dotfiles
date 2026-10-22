#!/usr/bin/env bash
# Claude Code PostToolUse hook: format a file after Claude edits/writes it.
# Reads the hook JSON on stdin, formats by extension if a matching formatter
# is on PATH. Always exits 0 so it never blocks the edit; formatters respect
# their own project config (.stylua.toml, rustfmt.toml, ...).
set -uo pipefail

file=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file" ] || exit 0

# Resolve symlinks to the file's real path. stylua (and friends) anchor their
# project-config search to the file's own directory tree, not $PWD — so a file
# reached through a symlink like ~/.config/nvim → the nix store would miss
# ~/dotfiles/.stylua.toml and silently fall back to built-in defaults.
file=$(readlink -f "$file" 2>/dev/null || echo "$file")
[ -f "$file" ] || exit 0

# The edition `cargo fmt` would pass for a Rust file: from the nearest
# Cargo.toml that names one. A workspace member inheriting its edition
# (`edition.workspace = true`) names none, so the search goes on up to the
# workspace's `[workspace.package]`. Without it, rustfmt parses and formats
# the file as edition 2015.
rust_edition() {
	local dir ed
	dir=$(dirname "$1")
	while :; do
		if [ -f "$dir/Cargo.toml" ]; then
			ed=$(sed -n 's/^[[:space:]]*edition[[:space:]]*=[[:space:]]*"\([0-9]*\)".*/\1/p' "$dir/Cargo.toml" | head -n 1)
			[ -n "$ed" ] && { echo "$ed"; return; }
		fi
		[ "$dir" = / ] && return
		dir=$(dirname "$dir")
	done
}

case "$file" in
	*.lua) command -v stylua  >/dev/null 2>&1 && stylua  "$file" ;;
	*.nix) command -v nixfmt  >/dev/null 2>&1 && nixfmt  "$file" ;;
	*.rs)
		if command -v rustfmt >/dev/null 2>&1; then
			ed=$(rust_edition "$file")
			rustfmt +nightly ${ed:+--edition "$ed"} "$file"
		fi
		;;
esac

exit 0
