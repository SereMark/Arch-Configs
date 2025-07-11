#!/bin/bash

# This script performs system maintenance and a fully synchronized configuration backup.
# It is designed to be run automatically on startup.
#
# Features:
# - Waits for an active network connection before running.
# - Checks for required command (yay) before execution.
# - Updates system packages using yay.
# - Creates a perfect mirror of configurations by cleaning the old backup
#   and copying the new one, correctly handling new, modified, and DELETED files.
# - Correctly handles file permissions for files copied with sudo.
# - Commits and pushes to Git only if actual changes are detected.
# - Logs all actions to ~/maintenance.log for easy debugging.

# --- Configuration ---
LOG_FILE="$HOME/.config/i3/maintenance.log"
GIT_REPO_URL="https://github.com/SereMark/Arch-Configs.git"
NETWORK_CHECK_HOST="8.8.8.8" # A reliable host to check for internet.

# --- Files and Directories to Back Up ---
# Add any other files or directories you want to back up to these lists.
HOME_FILES=(
  ".bashrc"
)
CONFIG_DIRS=(
  "alacritty"
  "fastfetch"
  "i3"
  "nvim"
)
ABSOLUTE_PATH_ITEMS=(
  "/etc/fonts/local.conf"
  "/etc/sudoers"
)

# --- Main Logic ---

# Get the absolute path of the script itself, so it can be copied reliably.
SCRIPT_PATH=$(readlink -f "$0")

# Start a clean log for this run.
echo "--- Log for maintenance run starting at $(date) ---" >"$LOG_FILE"

# Check sudo access at start
echo "[INFO] Checking sudo access..." >>"$LOG_FILE"
if ! sudo -n true 2>/dev/null; then
  echo "[WARNING] No passwordless sudo access. Some operations may fail." >>"$LOG_FILE"
fi

# --- Part 1: Network Check ---
echo "[INFO] Waiting for network connection..." >>"$LOG_FILE"
while ! ping -c 1 -W 1 "$NETWORK_CHECK_HOST" &>/dev/null; do
  sleep 5
done
echo "[SUCCESS] Network connection is active." >>"$LOG_FILE"

# --- Part 2: System Maintenance ---
echo "[INFO] Starting system update with yay..." >>"$LOG_FILE"
if command -v yay &>/dev/null; then
  sudo -n /usr/bin/yay -Syu --noconfirm >>"$LOG_FILE" 2>&1
  echo "[SUCCESS] System update finished." >>"$LOG_FILE"
else
  echo "[ERROR] yay command not found. Skipping update." >>"$LOG_FILE"
fi

# --- Part 3: Synchronized Configuration Backup ---
echo "[INFO] Starting synchronized configuration backup..." >>"$LOG_FILE"

# Create a main temporary directory to work in.
WORK_DIR=$(mktemp -d)
echo "[INFO] Created temporary working directory at $WORK_DIR" >>"$LOG_FILE"

# Set up a trap to automatically clean up the temp directory on script exit.
trap 'echo "[INFO] Cleaning up temporary directory $WORK_DIR." >> "$LOG_FILE"; rm -rf "$WORK_DIR"' EXIT

# --- Step 3.1: Clone the existing repository ---
echo "[INFO] Cloning repository into $WORK_DIR..." >>"$LOG_FILE"
if ! git clone "$GIT_REPO_URL" "$WORK_DIR" >>"$LOG_FILE" 2>&1; then
  echo "[ERROR] Failed to clone repository. Halting script." >>"$LOG_FILE"
  exit 1
fi

# --- Step 3.2: Clean the cloned repository of old configs (SELECTIVE) ---
# This step ensures that files deleted from your system are also deleted from the repo.
echo "[INFO] Cleaning old configurations from the local repository clone..." >>"$LOG_FILE"
cd "$WORK_DIR"

# Remove home files
for item in "${HOME_FILES[@]}"; do
  if [ -e "./$item" ]; then
    rm -rf "./$item" 2>>"$LOG_FILE"
    echo "[DEBUG] Removed old ./$item" >>"$LOG_FILE"
  fi
done

# Remove only specific config directories, not the entire .config
if [ -d "./.config" ]; then
  for item in "${CONFIG_DIRS[@]}"; do
    if [ -e "./.config/$item" ]; then
      rm -rf "./.config/$item" 2>>"$LOG_FILE"
      echo "[DEBUG] Removed old ./.config/$item" >>"$LOG_FILE"
    fi
  done
fi

# Remove only specific files from etc, not the entire directory
for item in "${ABSOLUTE_PATH_ITEMS[@]}"; do
  rel_path=".${item}"
  if [ -e "$rel_path" ]; then
    rm -f "$rel_path" 2>>"$LOG_FILE"
    echo "[DEBUG] Removed old $rel_path" >>"$LOG_FILE"
  fi
done

# Remove old script
if [ -e "./startup_maintenance.sh" ]; then
  rm -f "./startup_maintenance.sh" 2>>"$LOG_FILE"
  echo "[DEBUG] Removed old startup_maintenance.sh" >>"$LOG_FILE"
fi

echo "[SUCCESS] Old configurations cleaned selectively." >>"$LOG_FILE"

# --- Step 3.3: Copy current configurations into the repository ---
echo "[INFO] Copying current configurations into the repository..." >>"$LOG_FILE"

# Copy files from the home directory
for item in "${HOME_FILES[@]}"; do
  if [ -e "$HOME/$item" ]; then
    cp -rf "$HOME/$item" "./" 2>>"$LOG_FILE"
    echo "[DEBUG] Copied $HOME/$item" >>"$LOG_FILE"
  else
    echo "[WARNING] $HOME/$item not found" >>"$LOG_FILE"
  fi
done

# Copy directories from ~/.config
if [ -d "$HOME/.config" ]; then
  mkdir -p "./.config"
  for item in "${CONFIG_DIRS[@]}"; do
    if [ -e "$HOME/.config/$item" ]; then
      cp -rf "$HOME/.config/$item" "./.config/" 2>>"$LOG_FILE"
      echo "[DEBUG] Copied $HOME/.config/$item" >>"$LOG_FILE"
    else
      echo "[WARNING] $HOME/.config/$item not found" >>"$LOG_FILE"
    fi
  done
fi

# Copy items with absolute paths using the sudoers-allowed pattern
for item in "${ABSOLUTE_PATH_ITEMS[@]}"; do
  DEST_PATH="./$(dirname "$item")"
  mkdir -p "$DEST_PATH"

  # Check if the source file exists and is readable
  if sudo test -r "$item" 2>>"$LOG_FILE"; then
    echo "[INFO] Copying $item..." >>"$LOG_FILE"

    # First copy to /tmp using the allowed sudo command pattern
    TEMP_FILE="/tmp/backup_$(basename "$item")_$$"

    # Use the exact command pattern allowed in sudoers
    if sudo /usr/bin/cp -rf "$item" "$TEMP_FILE" 2>>"$LOG_FILE"; then
      # Now move from /tmp to final destination (no sudo needed since we own the temp file)
      if mv "$TEMP_FILE" "$DEST_PATH/$(basename "$item")" 2>>"$LOG_FILE"; then
        echo "[SUCCESS] Copied $item" >>"$LOG_FILE"
      else
        echo "[ERROR] Failed to move $item from temp location" >>"$LOG_FILE"
        rm -f "$TEMP_FILE" 2>>"$LOG_FILE"
      fi
    else
      echo "[ERROR] Failed to copy $item to temp location (sudo command failed)" >>"$LOG_FILE"
    fi
  else
    echo "[WARNING] Cannot read $item - file missing or no permission" >>"$LOG_FILE"
  fi
done

# Finally, copy this script itself using its absolute path.
cp -f "$SCRIPT_PATH" "./startup_maintenance.sh" 2>>"$LOG_FILE"
echo "[DEBUG] Copied startup_maintenance.sh" >>"$LOG_FILE"

echo "[SUCCESS] Current configurations copied." >>"$LOG_FILE"

# --- Step 3.4: Verify critical files were backed up ---
echo "[INFO] Verifying backup integrity..." >>"$LOG_FILE"
for item in "${ABSOLUTE_PATH_ITEMS[@]}"; do
  rel_path=".${item}"
  if [ -f "$rel_path" ]; then
    echo "[VERIFIED] $item successfully backed up" >>"$LOG_FILE"
  else
    echo "[ERROR] $item NOT found in backup!" >>"$LOG_FILE"
  fi
done

# --- Step 3.5: Check for changes and push if necessary ---
cd "$WORK_DIR"
# Add all changes to git
git add . >>"$LOG_FILE" 2>&1

if [[ -n $(git status --porcelain) ]]; then
  echo "[INFO] Changes detected. Committing and pushing to remote..." >>"$LOG_FILE"
  git config user.name "Arch Config Backup"
  git config user.email "backup@localhost"
  # Commit changes
  git commit -m "Automated Backup: $(date)" -q >>"$LOG_FILE" 2>&1
  if git push origin main >>"$LOG_FILE" 2>&1; then
    echo "[SUCCESS] Push complete." >>"$LOG_FILE"
  else
    echo "[ERROR] Git push failed!" >>"$LOG_FILE"
  fi
else
  echo "[INFO] No changes detected. Repository is already up to date." >>"$LOG_FILE"
fi

echo "--- Maintenance run finished at $(date) ---" >>"$LOG_FILE"
exit 0
