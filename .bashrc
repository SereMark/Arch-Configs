#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Don't save duplicate commands
export HISTCONTROL=erasedups
# Increase history size
export HISTSIZE=10000
export HISTFILESIZE=10000
# Append to the history file, don't overwrite it
shopt -s histappend
# Allow searching history by typing a command and pressing Up/Down arrows
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Make 'ls' show hidden files (-A), use list format (-l), human-readable sizes (-h), and colors
alias ls='ls -Alh --color=auto'
# Add color to grep output
alias grep='grep --color=auto'

# Pacman shortcuts for system management
alias pacu='sudo pacman -Syu'  # Update system (Upgrade)
alias paci='sudo pacman -S'    # Install a package
alias pacr='sudo pacman -Rns'  # Remove a package and its dependencies

# Shortcuts for moving up directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Function to get the current git branch name
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
# Clean prompt with git integration: [user@hostname directory](branch)$
PS1='[\u@\h \W]$(parse_git_branch)\$ '

# Path configuration
export PATH=~/.npm-global/bin:$PATH
