#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$HOME/projects/Hibrid-Chess-AI"
FILE_TO_OPEN="$PROJECT_DIR/hybridchess/cli.py"

# Window classes and sizing
AGENT_CLASS="CursorAgent"
DEV_CLASS="DevTerm"
DESIRED_AGENT_WIDTH_PCT=30

# Resolve cursor-agent to an absolute path to avoid PATH issues in i3
if command -v cursor-agent >/dev/null 2>&1; then
  CURSOR_AGENT_BIN="$(command -v cursor-agent)"
elif [[ -x "$HOME/.local/bin/cursor-agent" ]]; then
  CURSOR_AGENT_BIN="$HOME/.local/bin/cursor-agent"
else
  CURSOR_AGENT_BIN=""
fi

# Fallback if file does not exist
if [[ ! -f "$FILE_TO_OPEN" ]]; then
  FILE_TO_OPEN="$PROJECT_DIR"
fi

# If cursor-agent isn't available, just launch Neovim to avoid failing silently
if [[ -z "$CURSOR_AGENT_BIN" ]]; then
  i3-msg "workspace 2; exec --no-startup-id alacritty --working-directory \"$PROJECT_DIR\" -e nvim \"$FILE_TO_OPEN\"" &>/dev/null || true
  exit 0
fi

# Launch Neovim on the left and cursor-agent on the right, using a login shell for env setup.
# Give the right window a unique WM_CLASS so we can reliably target it for resizing after it appears.
i3-msg "workspace 2; \
  exec --no-startup-id alacritty --class \"$DEV_CLASS,$DEV_CLASS\" --working-directory \"$PROJECT_DIR\" -e nvim \"$FILE_TO_OPEN\"; \
  split h; \
  exec --no-startup-id alacritty --class \"$AGENT_CLASS,$AGENT_CLASS\" --working-directory \"$PROJECT_DIR\" -e bash -lc \"$CURSOR_AGENT_BIN\"" &>/dev/null || true

# Wait briefly for the agent terminal to appear (avoid racing the focus/resize commands)
for attempt in {1..40}; do
  if i3-msg -t get_tree | grep -q "\"class\":\"$AGENT_CLASS\""; then
    break
  fi
  sleep 0.15
done

# Focus the agent pane, set its exact width, then return focus to the left editor
i3-msg "[class=\"$AGENT_CLASS\"] focus; resize set width ${DESIRED_AGENT_WIDTH_PCT} ppt; focus left" &>/dev/null || true
