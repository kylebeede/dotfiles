#!/usr/bin/env bash
# One-command setup for dotfiles

# Find the dotfiles directory
DOTFILES_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Show help message
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  cat <<EOF
Usage: ./script/setup.sh [options]

Options:
  -h, --help     Show this help message
  --no-brew      Skip Homebrew package installations
  --quick        Skip Git setup and other interactive prompts

This script will:
1. Set up your dotfiles configuration
2. Install required packages (on macOS)
3. Configure your shell environment

Just clone this repo to ~/.dotfiles and run this script!
EOF
  exit 0
fi

# Get options
NO_BREW=0
QUICK=0

for arg in "$@"; do
  case $arg in
    --no-brew) NO_BREW=1 ;;
    --quick) QUICK=1 ;;
  esac
done

# Export options for subscripts
export NO_BREW QUICK

# Make sure we're in the dotfiles root directory
cd "$DOTFILES_ROOT" || exit 1

# Run bootstrap to set up symlinks and basic structure
echo "==> Setting up dotfiles structure"
if [ -f "$DOTFILES_ROOT/script/bootstrap" ]; then
  bash "$DOTFILES_ROOT/script/bootstrap"
else
  echo "Error: bootstrap script not found at $DOTFILES_ROOT/script/bootstrap"
  exit 1
fi

# Run install if brew packages are requested
if [[ $NO_BREW -eq 0 ]]; then
  echo "==> Installing packages"
  if [ -f "$DOTFILES_ROOT/script/install" ]; then
    bash "$DOTFILES_ROOT/script/install"
  else
    echo "Error: install script not found at $DOTFILES_ROOT/script/install"
    exit 1
  fi
fi

# Success message with next steps
cat <<EOF

==> Dotfiles installation complete!
EOF
