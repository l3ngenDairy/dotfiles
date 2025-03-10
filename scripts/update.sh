#!/usr/bin/env bash
set -euo pipefail

# Script to update dotfiles and system

# Ask the user for the hostname
echo "==> Please enter your system's hostname:"
read -r hostname

# Validate that the hostname is not empty
if [[ -z "$hostname" ]]; then
  echo "Error: Hostname cannot be empty. Exiting..."
  exit 1
fi

echo "==> Updating dotfiles..."
cd "${HOME}/dotfiles"

# Check if there are local changes
if [[ -n "$(git status --porcelain)" ]]; then
  echo "==> Local changes detected. Stashing..."
  git stash
fi

# Update repository
echo "==> Pulling latest changes..."
git pull origin main

# Rebuild system
echo "==> Rebuilding system..."
sudo nixos-rebuild switch --flake ~/dotfiles/.#"$hostname"

echo "==> Update complete!"
