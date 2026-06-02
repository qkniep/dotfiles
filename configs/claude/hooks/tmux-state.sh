#!/usr/bin/env bash
# Claude Code hook: drive the per-window @claude-state tmux option that the
# tabline reads (see tmux.conf). Called with one arg from the settings hooks:
#   start      — UserPromptSubmit:               turn begins -> "thinking" (yellow)
#   permission — Notification (permission_prompt): needs approval mid-turn -> "waiting" (red)
#   idle       — Notification (idle_prompt):       Claude idle/finished    -> "done" (red);
#                                                  also recovers the stuck "thinking" left by an
#                                                  Esc interrupt — Stop never fires on interrupt.
#   resume     — PostToolUse:                      a tool ran, work resumed -> "waiting" back to "thinking"
#   finish     — Stop / StopFailure:               turn ended  -> "done" (red, "come look")
#   end        — SessionStart / SessionEnd:        no live turn -> clear the option (dim)
#
# States: thinking (yellow), waiting (red — needs approval, sticky), done (red —
# finished; cleared when you focus the window, via a tmux session-window-changed
# hook in tmux.conf), unset (dim — untouched or ended). waiting and done both
# render red but are distinct so focusing a finished window resets it without
# dismissing a still-pending permission prompt.
#
# idle/finish in a focused, attached window clear the state instead of setting
# "done" — the user is already looking, so a "come look" marker would just go
# stale once they switch away.
#
# Notification kind (permission vs idle) is classified by the hook `matcher` in
# claude/*-settings.json, NOT by parsing stdin here. start/permission/idle/finish
# guard on the prior state so stray pings (e.g. an idle ping on a freshly
# launched, never-prompted pane) can't light it up.
set -u

[ -n "${TMUX_PANE:-}" ] || exit 0

action=${1:-}
state=$(tmux show-options -wqv -t "$TMUX_PANE" @claude-state 2>/dev/null)

# Turn finished: "done" if the window is in the background ("come look"),
# cleared outright if the user is already looking at it.
mark_done() {
	if [ "$(tmux display-message -p -t "$TMUX_PANE" '#{&&:#{window_active},#{session_attached}}')" = 1 ]; then
		tmux set-option -w -t "$TMUX_PANE" -u @claude-state
	else
		tmux set-option -w -t "$TMUX_PANE" @claude-state done
	fi
}

case "$action" in
	start)
		[ "$state" = thinking ] && exit 0
		tmux set-option -w -t "$TMUX_PANE" @claude-state thinking
		;;
	permission)
		[ "$state" = thinking ] || exit 0
		tmux set-option -w -t "$TMUX_PANE" @claude-state waiting
		;;
	idle)
		[ "$state" = thinking ] || exit 0
		mark_done
		;;
	resume)
		[ "$state" = waiting ] || exit 0
		tmux set-option -w -t "$TMUX_PANE" @claude-state thinking
		;;
	finish)
		case "$state" in
			thinking|waiting) mark_done ;;
			*) exit 0 ;;
		esac
		;;
	end)
		[ -n "$state" ] || exit 0
		tmux set-option -w -t "$TMUX_PANE" -u @claude-state
		;;
	*) exit 0 ;;
esac

tmux refresh-client -S
exit 0
