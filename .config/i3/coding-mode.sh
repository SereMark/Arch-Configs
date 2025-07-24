#!/bin/bash

# Quick duplicate detection - exit if coding session already exists
i3-msg -t get_tree | grep -q "nvim.*projects" && exit 0

# Open YouTube Music on workspace 1 (continue if Firefox unavailable)
i3-msg 'workspace 1; exec firefox --new-window https://music.youtube.com' &>/dev/null || true

# Detect current or most recent project
PROJECT_DIR="$HOME/projects"
if [ -d "$HOME/projects/Hibrid-Chess-AI" ]; then
    CURRENT_PROJECT="$HOME/projects/Hibrid-Chess-AI"
else
    CURRENT_PROJECT="$HOME/projects"
fi

# Switch to workspace 2 and setup coding environment in batched commands (continue on failure)
i3-msg "workspace 2; exec alacritty -e bash -c \"cd $PROJECT_DIR && nvim .\"; split h; exec alacritty --working-directory $CURRENT_PROJECT -e claude; resize shrink width 10 px or 10 ppt" &>/dev/null || true
