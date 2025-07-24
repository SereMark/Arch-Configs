#!/bin/bash

sleep 10

gh auth status &>/dev/null || exit 1

HASH_FILE="$HOME/.cache/backup_hash"
CURRENT_HASH=$(find "$HOME/.config/i3" "$HOME/.config/nvim" "$HOME/.bashrc" "$HOME/.claude/CLAUDE.md" "$HOME/projects/pyproject.toml" "$HOME/projects/pyrightconfig.json" -type f -exec md5sum {} \; 2>/dev/null | sort | md5sum | cut -d' ' -f1)

[ -f "$HASH_FILE" ] && [ "$(cat "$HASH_FILE" 2>/dev/null)" = "$CURRENT_HASH" ] && exit 0

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

curl -s --connect-timeout 3 --max-time 5 https://api.github.com/zen >/dev/null || exit 0

git clone https://github.com/SereMark/Arch-Configs.git "$WORK_DIR" --depth 1 --single-branch --branch main &>/dev/null || exit 1

cd "$WORK_DIR" || exit 1

if [ -d "$HOME/.config/i3" ] && [ "$(ls -A "$HOME/.config/i3" 2>/dev/null)" ]; then
    rm -rf .config/i3 2>/dev/null
    mkdir -p .config
    cp -r "$HOME/.config/i3" .config/
fi

if [ -d "$HOME/.config/nvim" ] && [ "$(ls -A "$HOME/.config/nvim" 2>/dev/null)" ]; then
    rm -rf .config/nvim 2>/dev/null
    mkdir -p .config
    cp -r "$HOME/.config/nvim" .config/
fi

[ -f "$HOME/.bashrc" ] && { rm -f .bashrc 2>/dev/null; cp "$HOME/.bashrc" . 2>/dev/null; }
[ -f "$HOME/.claude/CLAUDE.md" ] && { rm -f CLAUDE.md 2>/dev/null; cp "$HOME/.claude/CLAUDE.md" . 2>/dev/null; }

if [ -f "$HOME/projects/pyproject.toml" ]; then
    mkdir -p projects
    rm -f projects/pyproject.toml 2>/dev/null
    cp "$HOME/projects/pyproject.toml" projects/ 2>/dev/null
fi

if [ -f "$HOME/projects/pyrightconfig.json" ]; then
    mkdir -p projects  
    rm -f projects/pyrightconfig.json 2>/dev/null
    cp "$HOME/projects/pyrightconfig.json" projects/ 2>/dev/null
fi

git add . 2>/dev/null || exit 1
if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
  git config user.name "Arch Config Backup" 2>/dev/null || exit 1
  git config user.email "backup@localhost" 2>/dev/null || exit 1
  git commit -m "Automated Backup" &>/dev/null && git push origin main --quiet &>/dev/null && {
    mkdir -p "$(dirname "$HASH_FILE")" 2>/dev/null
    echo "$CURRENT_HASH" > "$HASH_FILE" 2>/dev/null
  }
else
  mkdir -p "$(dirname "$HASH_FILE")" 2>/dev/null
  echo "$CURRENT_HASH" > "$HASH_FILE" 2>/dev/null
fi
