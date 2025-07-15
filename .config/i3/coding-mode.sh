#!/bin/bash
# Open YouTube Music on workspace 1
i3-msg 'workspace 1; exec firefox --new-window https://music.youtube.com'
sleep 2

# Switch to workspace 2 for coding
i3-msg 'workspace 2'
sleep 0.5

# Open nvim in the left pane
i3-msg 'exec alacritty -e bash -c "cd ~/projects && nvim ."'
sleep 1

# Split horizontally for claude
i3-msg 'split h'
sleep 0.5

# Open claude in interactive mode with proper shell
i3-msg 'exec alacritty --working-directory ~/projects/Hibrid-Chess-AI -e claude'
sleep 1

# Adjust the split size
i3-msg 'resize shrink width 10 px or 10 ppt'

# Ensure we're on workspace 2
i3-msg 'workspace 2'
