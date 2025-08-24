[[ $- != *i* ]] && return

export HISTCONTROL=erasedups
export HISTSIZE=10000
export HISTFILESIZE=10000
shopt -s histappend
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

alias ls='ls -Alh --color=auto'
alias pacu='sudo pacman -Syu'
alias paci='sudo pacman -S'
alias pacr='sudo pacman -Rns'

export PATH="$HOME/.local/bin:$PATH"

files2clip() {
  find . \
    -type d \( -name .git -o -name out -o -name build -o -name venv -o -name __pycache__ \) -prune -o \
    -type f ! -name '*openings.txt' ! -name 'log.txt' -print0 \
  | sort -z \
  | while IFS= read -r -d '' f; do
      p=${f#./}
      printf '%s:\n' "$p"
      cat -- "$f"
      printf '\n\n'
    done \
  | xclip -selection clipboard
}


gacp() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repository."; return 1
  fi
  if [ "$#" -eq 0 ]; then
    echo 'Usage: gacp "commit message"'; return 1
  fi

  git add . && git commit -m "$*" && git push
}
