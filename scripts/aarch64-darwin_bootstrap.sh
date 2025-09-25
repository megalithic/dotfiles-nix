#!/usr/bin/env bash

set -Eueo pipefail

DOTFILES_NAME="dotfiles-nix"
DOTFILES_REPO="https://github.com/megalithic/$DOTFILES_NAME"
DOTFILES_DIR="$HOME/.$DOTFILES_NAME"
SUDO_USER=$(whoami)
FLAKE=$(hostname -s)

command cat << EOF

░
░  ┌┬┐┌─┐┌─┐┌─┐┬  ┬┌┬┐┬ ┬┬┌─┐
░  │││├┤ │ ┬├─┤│  │ │ ├─┤││   :: bits & bobs, dots & things.
░  ┴ ┴└─┘└─┘┴ ┴┴─┘┴ ┴ ┴ ┴┴└─┘
░  @megalithic 🗿
░

EOF

if ! command -v xcode-select > /dev/null 2>&1; then
  echo "░ :: -> Installing Xcode for $SUDO_USER.." &&
    xcode-select --install &&
    sudo -u "$SUDO_USER" softwareupdate --install-rosetta --agree-to-license
  # sudo -u "$SUDO_USER" xcodebuild -license
fi

if [ -d "$DOTFILES_DIR" ]; then
  BACKUP_DIR="$DOTFILES_DIR$(date +%s)"
  echo "░ :: -> Backing up existing $DOTFILES_NAME to $BACKUP_DIR.." &&
    mv "$DOTFILES_DIR" "$BACKUP_DIR"
fi

echo "░ :: -> Cloning $DOTFILES_NAME repo to $DOTFILES_DIR.." &&
  # git clone --bare $DOTFILES_REPO "$DOTFILES_DIR"
  # git init --bare "$DOTFILES_DIR"
  git clone $DOTFILES_REPO "$DOTFILES_DIR"

# NOTE: homebrew install handled by nix-homebrew
# if ! command -v brew > /dev/null 2>&1 && [ ! -f "/opt/homebrew/bin/brew" ]; then
#   echo "░ :: -> Installing homebrew.." &&
#     bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# fi

echo "░ :: -> Running nix-darwin for the first time for $FLAKE.." &&
  (sudo nix --experimental-features 'nix-command flakes' run nix-darwin -- switch --option eval-cache false --flake "$DOTFILES_DIR#$FLAKE" &&
    # echo "Running home-manager for the first time for $FLAKE.."
    # sudo nix --experimental-features 'nix-command flakes' run home-manager/master -- switch --flake "$DOTFILES_DIR#$FLAKE"
    echo "░ :: -> Setting $DOTFILES_DIR to bare repo.." &&
    pushd "$DOTFILES_DIR" > /dev/null &&
    git config --bool core.bare true &&
    popd > /dev/null &&
    echo "░ [✓] -> Completed installation of $DOTFILES_DIR flake..") || echo "░ [x] -> Errored while installing $DOTFILES_DIR flake.."
