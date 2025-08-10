#!/bin/bash
set -euo pipefail

PROJECTS_DIR="$HOME/projects"
AGENT_DIR="$PROJECTS_DIR/Hibrid-Chess-AI"
AGENT_TITLE="AGENT"

i3-msg 'workspace 2; layout splith' >/dev/null || true

i3-msg "exec --no-startup-id alacritty -e bash -lc 'cd \"$PROJECTS_DIR\" && exec nvim Hibrid-Chess-AI/hybridchess/cli.py'" >/dev/null || true
sleep 0.25

i3-msg 'split h; focus right' >/dev/null || true

i3-msg "exec --no-startup-id alacritty --title $AGENT_TITLE -e bash -lc 'cd \"$AGENT_DIR\" && exec cursor-agent'" >/dev/null || true
sleep 0.3

i3-msg "[title=\"$AGENT_TITLE\"] focus; resize set width 30 ppt; focus left" >/dev/null || true
