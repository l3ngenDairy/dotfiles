#!/usr/bin/env bash
set -euo pipefail

# Script to update dotfiles and system

# Function to prompt for hostname
get_hostname() {
  echo "==> Please enter your system's hostname:"
  read -r hostname
  if [[ -z "$hostname" ]]; then
    echo "Error: Hostname cannot be empty. Exiting..."
    exit 1
  fi
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

# Function to perform a dry run (build without switching)
dry_run() {
  local hostname=$1
  echo "==> Performing dry run for hostname: ${hostname}..."
  sudo nixos-rebuild build --flake ~/dotfiles/.#"$hostname"
}

# Main function
main() {
  get_hostname
  update_dotfiles

  # Ask if the user wants a dry run
  echo "==> Do you want to perform a dry run (build without switching)? [y/N]"
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    dry_run "$hostname"
  else
    rebuild_system "$hostname"
  fi

  echo "==> Update complete!"
}

main
