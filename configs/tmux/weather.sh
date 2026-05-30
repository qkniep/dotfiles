#!/usr/bin/env bash
# Sanitizing wrapper around xamut/tmux-weather.
#
# The upstream scripts/weather.sh shells out to wttr.in and echoes back
# whatever it gets (and caches it for ~15 min). When wttr.in is rate-limited
# or down it returns a long error blurb, e.g.
#   render failed: response missing current_condition array [][47.43,8.57]...
# which then overflows the status bar. A real "%t" reading is short and carries
# a degree sign (e.g. "+15°C"), so pass that through and collapse anything else
# to "??".

plugin="$HOME/.config/tmux/plugins/tmux-weather/scripts/weather.sh"

out="$("$plugin" 2>/dev/null)"

if [[ "$out" == *°* && ${#out} -le 12 ]]; then
  printf '%s' "$out"
else
  printf '??'
fi
