#!/usr/bin/env bash
# Claude Code statusline. Receives the session JSON on stdin and prints one
# line: <dir>  <git branch+dirty>  [ctx %]  <model>  [output style].
# Wired in via "statusLine" in each profile's settings.json.
set -uo pipefail

input=$(cat)
get() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

model=$(get '.model.display_name // "?"')
model=${model/ (1M context)/ 1M}  # shorten the extended-context suffix
model_id=$(get '.model.id // empty')
cdir=$(get '.workspace.current_dir // .cwd // empty')
style=$(get '.output_style.name // empty')
transcript=$(get '.transcript_path // empty')

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

# Context-window usage %, from the transcript's most recent usage entry. The
# token total is the last prompt size (uncached input + cache read + cache
# write); the window is 1M for all models (Sonnet/Opus/Fable) except Haiku (200k).
ctx_pct=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
	tokens=$(tail -n 200 "$transcript" 2>/dev/null | jq -s '
		([.[] | select(.message.usage) | .message.usage] | last) as $u
		| if $u then (($u.input_tokens // 0)
			+ ($u.cache_read_input_tokens // 0)
			+ ($u.cache_creation_input_tokens // 0)) else empty end' 2>/dev/null)
	if [ -n "$tokens" ] && [ "$tokens" -gt 0 ] 2>/dev/null; then
		limit=1000000
		case "${model_id}${model}" in *[Hh]aiku*) limit=200000 ;; esac
		ctx_pct=$(( tokens * 100 / limit ))
	fi
fi

# ── Color palette ───────────────────────────────────────────────────────────
# Basic ANSI colors (16-color foregrounds), as named building blocks. Point a
# semantic color below at one of these to recolor that part of the line.
c_black=$'\033[30m'
c_red=$'\033[31m'
c_green=$'\033[32m'
c_yellow=$'\033[33m'
c_blue=$'\033[34m'
c_magenta=$'\033[35m'
c_cyan=$'\033[36m'
c_white=$'\033[37m'
c_bright_black=$'\033[90m'
c_bright_red=$'\033[91m'
c_bright_green=$'\033[92m'
c_bright_yellow=$'\033[93m'
c_bright_blue=$'\033[94m'
c_bright_magenta=$'\033[95m'
c_bright_cyan=$'\033[96m'
c_bright_white=$'\033[97m'
c_bold=$'\033[1m'
c_reset=$'\033[0m'

# Extended 256-color shades the line actually uses (finer than basic ANSI).
c256_green=$'\033[38;5;114m'         # soft green
c256_muted_orange=$'\033[38;5;173m'  # muted terracotta (dirty branch)
c256_gray=$'\033[38;5;245m'          # gray
c256_badge_text=$'\033[38;5;16m'     # near-black (badge text, for contrast on bright bg)
c256_muted_red=$'\033[38;5;174m'     # muted red
c256_muted_blue=$'\033[38;5;67m'     # muted steel blue
c256_light_blue=$'\033[38;5;75m'     # light blue
c_bg_bright_red=$'\033[101m'         # bright-red badge background (matches dir tint)
c_bg_bright_blue=$'\033[104m'        # bright-blue badge background (matches dir tint)

# Semantic colors (point these at palette entries above to restyle the line).
c_clean=$c256_green  # clean branch
c_dirty=$c_yellow    # dirty branch
c_dim=$c256_gray     # model / output style

# Powerline branch glyph (raw UTF-8 bytes for U+E0A0; needs a Nerd Font).
branch_glyph=$(printf '\xee\x82\xa0')

# Profile badge, keyed off CLAUDE_CONFIG_DIR (set by the claude-anza /
# claude-personal aliases). A bold reverse-video chip plus a per-profile dir
# tint so the whole line reads differently at a glance: work is red, personal
# is blue. Unknown profiles get no badge and the default blue.
case "${CLAUDE_CONFIG_DIR:-}" in
	*claude-anza*)
		badge="${c_bg_bright_red}${c256_badge_text} ANZA ${c_reset}"
		c_dir=$c_bright_red
		;;
	*claude-personal*)
		badge="${c_bg_bright_blue}${c256_badge_text} PERSONAL ${c_reset}"
		c_dir=$c_bright_blue
		;;
	*)
		badge=""
		c_dir=$c256_light_blue
		;;
esac

out="${c_dir}${dir}${c_reset}"
[ -n "$badge" ] && out="${badge} ${out}"
if [ -n "$branch" ]; then
	bc="$c_clean"; [ -n "$dirty" ] && bc="$c_dirty"
	out="${out}  ${bc}${branch}${dirty}${c_reset}"
fi
if [ -n "$ctx_pct" ]; then
	cc="$c256_green"
	[ "$ctx_pct" -ge 50 ] && cc="$c_yellow"
	[ "$ctx_pct" -ge 80 ] && cc="$c_red"
	out="${out}  ${cc}ctx ${ctx_pct}%${c_reset}"
fi
out="${out}  ${c_dim}${model}${c_reset}"
[ -n "$style" ] && [ "$style" != "default" ] && out="${out} ${c_dim}[${style}]${c_reset}"

printf '%s' "$out"
