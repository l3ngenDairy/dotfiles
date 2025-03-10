#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script for new machine setup

echo "==> Setting up dotfiles..."

# Ensure nix is installed
if ! command -v nix >/dev/null 2>&1; then
  echo "==> Installing Nix..."
  sh <(curl -L https://nixos.org/nix/install) --daemon
fi

# Ensure flakes are enabled
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
  mkdir -p ~/.config/nix
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Clone the repository if running from a downloaded script
if [[ ! -d "${HOME}/dotfiles" ]]; then
  echo "==> Cloning dotfiles repository..."
  git clone https://github.com/l3ngenDairy/dotfiles  "${HOME}/dotfiles"
  cd "${HOME}/dotfiles"
else
  cd "${HOME}/dotfiles"
fi
echo '==> Adding hardware-configuration'
sudo nixos-generate-config --root /

# Install default configuration
echo "==> Installing system configuration..."
sudo nixos-rebuild switch --flake ".#default" --impure

echo "==> Dotfiles setup complete!"
