[[ $- != *i* ]] && return

export HISTCONTROL=erasedups
export HISTSIZE=10000
export HISTFILESIZE=10000
shopt -s histappend
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

alias ls='ls -Alh --color=auto'
alias grep='grep --color=auto'

alias pacu='sudo pacman -Syu'
alias paci='sudo pacman -S'
alias pacr='sudo pacman -Rns'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

export PATH="$HOME/.local/bin:$PATH"

files2clip() {
  find . -type d \( -name '.git' -o -name 'out' -o -name 'build' -o -name 'venv' -o -name '__pycache__' \) -prune -o -type f -print0 \
  | sort -z \
  | while IFS= read -r -d '' f; do
      p=${f#./}
      printf '%s:\n' "$p"
      if [ "$(basename -- "$p")" != "openings.txt" ]; then
        cat -- "$f"
      fi
      printf '\n\n'
    done \
  | xclip -selection clipboard
}

alias f2c='files2clip'
