#
# ~/.bashrc - Upgraded for better UX
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- BETTER HISTORY ---
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

# --- ALIASES ---
# Make 'ls' show hidden files (-A), use list format (-l), human-readable sizes (-h), and colors
alias ls='ls -Alh --color=auto'
# Add color to grep output
alias grep='grep --color=auto'

# Pacman shortcuts for system management
alias pacu='sudo pacman -Syu'  # Update system (Upgrade)
alias paci='sudo pacman -S'    # Install a package
alias pacr='sudo pacman -Rns'  # Remove a package and its dependencies
alias pacs='pacman -Ss'        # Search for a package

# --- SMARTER NAVIGATION ---
# Automatically cd into a directory if a command is not found
shopt -s autocd
# Shortcuts for moving up directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- PROMPT ---
# Function to get the current git branch name
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
# Clean prompt with git integration: [user@hostname directory](branch)$
PS1='[\u@\h \W]$(parse_git_branch)\$ '
export PATH=~/.npm-global/bin:$PATH
export PATH=~/.npm-global/bin:$PATH
