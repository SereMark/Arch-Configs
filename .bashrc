[[ $- != *i* ]] && return
export HISTCONTROL=erasedups
export HISTSIZE=10000
export HISTFILESIZE=10000
shopt -s histappend
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
alias ls='ls -Alh --color=auto'
alias grep='grep --color=auto'
alias pacu='sudo pacman -Syu'  # Update system (Upgrade)
alias paci='sudo pacman -S'    # Install a package
alias pacr='sudo pacman -Rns'  # Remove a package and its dependencies
