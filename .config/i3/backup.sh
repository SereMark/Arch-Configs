#!/bin/bash

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

while ! ping -c 1 -W 1 "8.8.8.8" &>/dev/null; do sleep 5; done

git clone --depth 1 "https://github.com/SereMark/Arch-Configs.git" "$WORK_DIR" &>/dev/null || exit 1

(
  cd "$WORK_DIR" || exit
  rm -rf .config/fastfetch .config/i3 &>/dev/null
  mkdir -p .config &>/dev/null
  [ -d "$HOME/.config/fastfetch" ] && cp -r "$HOME/.config/fastfetch" .config/ &>/dev/null
  [ -d "$HOME/.config/i3" ] && cp -r "$HOME/.config/i3" .config/ &>/dev/null

  git add . &>/dev/null
  [[ -n $(git status --porcelain) ]] && {
    git config user.name "Arch Config Backup" &>/dev/null
    git config user.email "backup@localhost" &>/dev/null
    git commit -m "Automated Backup" &>/dev/null && git push origin main &>/dev/null
  }
)
