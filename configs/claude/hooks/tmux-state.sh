#!/usr/bin/env bash
# Claude Code hook: drive the per-window @claude-state tmux option that the
# tabline reads (see tmux.conf). Called with one arg from settings hooks:
#   start  — UserPromptSubmit:    always set "thinking"
#   notify — Notification:        set "waiting" only mid-turn (state == thinking);
#                                 ignores idle pings that fire after Stop
#   done   — PostToolUse:         tool finished (permission granted + ran);
#                                 if state == waiting, revert to "thinking"
#   stop   — Stop/SessionEnd/...: unset the option
set -u

[ -n "${TMUX_PANE:-}" ] || exit 0

action=${1:-}
state=$(tmux show-options -wqv -t "$TMUX_PANE" @claude-state 2>/dev/null)

case "$action" in
	start)
		[ "$state" = thinking ] && exit 0
		tmux set-option -w -t "$TMUX_PANE" @claude-state thinking
		;;
	notify)
		[ "$state" = thinking ] || exit 0
		tmux set-option -w -t "$TMUX_PANE" @claude-state waiting
		;;
	done)
		[ "$state" = waiting ] || exit 0
		tmux set-option -w -t "$TMUX_PANE" @claude-state thinking
		;;
	stop)
		[ -n "$state" ] || exit 0
		tmux set-option -w -t "$TMUX_PANE" -u @claude-state
		;;
	*) exit 0 ;;
esac

tmux refresh-client -S
exit 0
