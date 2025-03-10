#!/usr/bin/env bash
set -euo pipefail

# Script to update dotfiles and system (automated version)

# Function to detect hostname
detect_hostname() {
  hostname=$(hostname)
  if [[ -z "$hostname" ]]; then
    echo "Error: Unable to detect hostname. Exiting..."
    exit 1
  fi
  echo "==> Detected hostname: ${hostname}"
}

# Function to update dotfiles
update_dotfiles() {
  echo "==> Updating dotfiles..."
  cd "${HOME}/dotfiles"

  # Check for local changes
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "==> Local changes detected. Stashing..."
    git stash
  fi

  # Pull latest changes
  echo "==> Pulling latest changes..."
  git pull origin main
}

# Function to rebuild the system
rebuild_system() {
  local hostname=$1
  echo "==> Rebuilding system for hostname: ${hostname}..."
  sudo nixos-rebuild switch --flake ~/dotfiles/.#"$hostname"
}

# Main function
main() {
  detect_hostname
  update_dotfiles
  rebuild_system "$hostname"
  echo "==> Update complete!"
}

main
