#!/bin/bash

gh auth status &>/dev/null || exit 1

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

while ! ping -c 1 -W 1 8.8.8.8 &>/dev/null; do sleep 5; done

git clone https://github.com/SereMark/Arch-Configs.git "$WORK_DIR" --depth 1 &>/dev/null || exit 1

cd "$WORK_DIR" || exit
rm -rf .config .bashrc CLAUDE.md

[ -d "$HOME/.config/i3" ] && mkdir -p .config && cp -r "$HOME/.config/i3" .config/
[ -d "$HOME/.config/nvim" ] && mkdir -p .config && cp -r "$HOME/.config/nvim" .config/
[ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" .
[ -f "$HOME/.claude/CLAUDE.md" ] && cp "$HOME/.claude/CLAUDE.md" .

git add .
if [[ -n $(git status --porcelain) ]]; then
  git config user.name "Arch Config Backup"
  git config user.email "backup@localhost"
  git commit -m "Automated Backup" && git push origin main
fi
