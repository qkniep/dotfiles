#!/usr/bin/env bash
# Claude Code PostToolUse hook: format a file after Claude edits/writes it.
# Reads the hook JSON on stdin, formats by extension if a matching formatter
# is on PATH. Always exits 0 so it never blocks the edit; formatters respect
# their own project config (.stylua.toml, rustfmt.toml, ...).
set -uo pipefail

file=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file" ] && [ -f "$file" ] || exit 0

case "$file" in
	*.lua) command -v stylua  >/dev/null 2>&1 && stylua  "$file" ;;
	*.nix) command -v nixfmt  >/dev/null 2>&1 && nixfmt  "$file" ;;
	*.rs)  command -v rustfmt >/dev/null 2>&1 && rustfmt +nightly "$file" ;;
esac

exit 0
