#!/usr/bin/env bash
# Claude Code statusline. Receives the session JSON on stdin and prints one
# line: <dir>  <git branch+dirty>  <model>  [output style]  [session cost].
# Wired in via "statusLine" in each profile's settings.json.
set -uo pipefail

input=$(cat)
get() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

model=$(get '.model.display_name // "?"')
cdir=$(get '.workspace.current_dir // .cwd // empty')
style=$(get '.output_style.name // empty')
cost=$(get '.cost.total_cost_usd // 0')

# Home-relative path.
if [ -z "$cdir" ]; then
	dir="?"
elif [ "$cdir" = "$HOME" ]; then
	dir="~"
elif [ "${cdir#"$HOME"/}" != "$cdir" ]; then
	dir="~/${cdir#"$HOME"/}"
else
	dir="$cdir"
fi

# Git branch + dirty marker, only inside a work tree.
branch="" dirty=""
if [ -n "$cdir" ] && git -C "$cdir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	branch=$(git -C "$cdir" symbolic-ref --quiet --short HEAD 2>/dev/null \
		|| git -C "$cdir" rev-parse --short HEAD 2>/dev/null)
	[ -n "$(git -C "$cdir" status --porcelain 2>/dev/null)" ] && dirty="*"
fi

# Colors + powerline branch glyph (raw UTF-8 bytes for U+E0A0; needs a Nerd Font).
c_dir=$'\033[38;5;75m'    # blue
c_clean=$'\033[38;5;114m' # green
c_dirty=$'\033[38;5;215m' # orange
c_dim=$'\033[38;5;245m'   # gray
c_reset=$'\033[0m'
branch_glyph=$(printf '\xee\x82\xa0')

out="${c_dir}${dir}${c_reset}"
if [ -n "$branch" ]; then
	bc="$c_clean"; [ -n "$dirty" ] && bc="$c_dirty"
	out="${out}  ${bc}${branch_glyph} ${branch}${dirty}${c_reset}"
fi
out="${out}  ${c_dim}${model}${c_reset}"
[ -n "$style" ] && [ "$style" != "default" ] && out="${out} ${c_dim}[${style}]${c_reset}"

printf '%s' "$out"
