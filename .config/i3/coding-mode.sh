#!/bin/bash

# Open YouTube Music on workspace 1 (continue if Firefox unavailable)
i3-msg 'workspace 1; exec firefox --new-window https://music.youtube.com' &>/dev/null || true

# Switch to workspace 2 and setup coding environment in batched commands (continue on failure)
i3-msg "workspace 2; exec alacritty -e bash -c \"cd \$HOME/projects && nvim Hibrid-Chess-AI/main.cpp\"; split h; exec alacritty --working-directory \$HOME/projects/Hibrid-Chess-AI -e claude; resize shrink width 10 px or 10 ppt" &>/dev/null || true
