#!/bin/bash

# --- Configuration ---

# Set to exit immediately if a command exits with a non-zero status.
set -e

# The URL of the GitHub repository to push the configurations to.
GIT_REPO_URL="https://github.com/SereMark/Arch-Configs.git"

# The directory where the backup will be temporarily stored.
# Using mktemp to create a secure temporary directory.
BACKUP_DIR=$(mktemp -d)

# A list of files and directories to be backed up.
# Paths are relative to the home directory (~).
CONFIG_FILES=(
    ".bashrc"
)

# A list of directories in .config to be backed up.
CONFIG_DIRS=(
    "alacritty"
    "fastfetch"
    "i3"
    "nvim"
)

# A list of files with absolute paths.
ABSOLUTE_PATH_FILES=(
    "/etc/fonts/local.conf"
)

# --- Functions ---

# Function to log messages to the console.
log() {
    echo "[INFO] $1"
}

# Function to log errors to the console.
error() {
    echo "[ERROR] $1" >&2
}

# Function to clean up the temporary directory on exit.
cleanup() {
    log "Cleaning up temporary directory: $BACKUP_DIR"
    rm -rf "$BACKUP_DIR"
}

# Trap the EXIT signal to ensure cleanup runs, even on errors.
trap cleanup EXIT

# --- Main Script Logic ---

log "Starting configuration backup..."
log "Temporary backup directory: $BACKUP_DIR"

# 1. Copy files from the home directory
log "Copying files from home directory..."
for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$HOME/$file" ]; then
        log "  -> Copying $HOME/$file"
        cp "$HOME/$file" "$BACKUP_DIR/"
    else
        error "File not found, skipping: $HOME/$file"
    fi
done

# 2. Copy directories from ~/.config
log "Copying directories from ~/.config..."
if [ -d "$HOME/.config" ]; then
    mkdir -p "$BACKUP_DIR/.config"
    for dir in "${CONFIG_DIRS[@]}"; do
        if [ -d "$HOME/.config/$dir" ]; then
            log "  -> Copying $HOME/.config/$dir"
            cp -r "$HOME/.config/$dir" "$BACKUP_DIR/.config/"
        else
            error "Directory not found, skipping: $HOME/.config/$dir"
        fi
    done
else
    error "~/.config directory not found. Skipping all .config backups."
fi


# 3. Copy files with absolute paths, preserving directory structure
log "Copying files from absolute paths..."
for file_path in "${ABSOLUTE_PATH_FILES[@]}"; do
    if [ -f "$file_path" ];
    then
        # Create the parent directory structure within the backup directory
        DEST_DIR="$BACKUP_DIR$(dirname "$file_path")"
        mkdir -p "$DEST_DIR"
        log "  -> Copying $file_path to $DEST_DIR"
        cp "$file_path" "$DEST_DIR/"
    else
        error "File not found, skipping: $file_path"
    fi
done


# 4. Copy the script itself into the backup directory
log "Copying this script to the backup directory..."
cp "$0" "$BACKUP_DIR/backup_configs.sh"


# 5. Initialize Git, commit, and push
log "Performing Git operations..."
cd "$BACKUP_DIR"

# Note: Git needs to be installed and you must have push access to the repo.
# Authentication might be handled via SSH keys or a credential helper.
git init -b main
git config user.name "Arch Config Backup"
git config user.email "backup@localhost"

git add .
COMMIT_MESSAGE="Automated config backup: $(date)"
git commit -m "$COMMIT_MESSAGE"

log "Pushing to remote repository: $GIT_REPO_URL"
git remote add origin "$GIT_REPO_URL"
# Use -f (force) to overwrite the repository's history.
# This makes the repo a snapshot of the latest backup.
git push -u -f origin main

log "Backup successful!"
log "Pushed commit: '$COMMIT_MESSAGE'"

# The 'trap' will handle the cleanup automatically.
exit 0
