#!/bin/bash

# Get GitHub token from secure file or environment
if [ -z "$GITHUB_TOKEN" ]; then
    TOKEN_FILE="$HOME/.local/share/secrets/github-token"
    if [ -f "$TOKEN_FILE" ]; then
        GITHUB_TOKEN=$(cat "$TOKEN_FILE")
    fi
fi

# Check if token is available
if [ -z "$GITHUB_TOKEN" ]; then
    echo "GitHub token not found. To set it up:"
    echo "1. Create token at: https://github.com/settings/tokens"
    echo "2. Store it with:"
    echo "   mkdir -p ~/.local/share/secrets && chmod 700 ~/.local/share/secrets"
    echo "   echo 'your_token_here' > ~/.local/share/secrets/github-token"
    echo "   chmod 600 ~/.local/share/secrets/github-token"
    exit 1
fi

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

while ! ping -c 1 -W 1 "8.8.8.8" &>/dev/null; do sleep 5; done

git clone --depth 1 "https://${GITHUB_TOKEN}@github.com/SereMark/Arch-Configs.git" "$WORK_DIR" &>/dev/null || exit 1

(
  cd "$WORK_DIR" || exit
  rm -rf .config .bashrc CLAUDE.md
  
  [ -d "$HOME/.config" ] && cp -r "$HOME/.config" .
  [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" .
  [ -f "$HOME/.claude/CLAUDE.md" ] && cp "$HOME/.claude/CLAUDE.md" .
  
  git add .
  if [[ -n $(git status --porcelain) ]]; then
    git config user.name "Arch Config Backup"
    git config user.email "backup@localhost"
    git commit -m "Automated Backup" && git push origin main
  fi
) &>/dev/null
