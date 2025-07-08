#!/bin/bash
i3-msg 'workspace 1; exec brave --new-window https://music.youtube.com'
sleep 1
i3-msg 'workspace 2'
sleep 0.5
i3-msg 'exec alacritty -e bash -c "cd ~/projects && nvim ."'
sleep 1
i3-msg 'split h'
sleep 0.5
i3-msg 'exec alacritty -e bash -c "cd ~/projects/Hibrid-Chess-AI && claude"'
sleep 0.5
i3-msg 'resize shrink width 10 px or 10 ppt'
sleep 1
i3-msg 'workspace 2'
