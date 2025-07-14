#!/bin/bash

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

while ! ping -c 1 -W 1 "8.8.8.8" &>/dev/null; do sleep 5; done

git clone --depth 1 "https://github.com/SereMark/Arch-Configs.git" "$WORK_DIR" &>/dev/null || exit 1

(
  cd "$WORK_DIR" || exit
  rm -rf .config/i3 .config/nvim CLAUDE.md
  mkdir -p .config
  [ -d "$HOME/.config/i3" ] && cp -r "$HOME/.config/i3" .config/
  [ -d "$HOME/.config/nvim" ] && cp -r "$HOME/.config/nvim" .config/
  [ -f "$HOME/.claude/CLAUDE.md" ] && cp "$HOME/.claude/CLAUDE.md" .
  
  git add .
  if [[ -n $(git status --porcelain) ]]; then
    git config user.name "Arch Config Backup"
    git config user.email "backup@localhost"
    git commit -m "Automated Backup" && git push origin main
  fi
) &>/dev/null
