default:
  @just --list

# update your flake.lock
update-flake:
  #!/usr/bin/env bash
  set -euxo pipefail
  nix flake update
  if git diff --exit-code flake.lock > /dev/null 2>&1; then
    echo "no changes to flake.lock"
  else
    echo "committing flake.lock"
    git add flake.lock
    git commit -m "chore(nix): updates flake.lock"
  fi

# upgrades nix
upgrade-nix:
  sudo --preserve-env=PATH nix run \
     --experimental-features "nix-command flakes" \
     upgrade-nix \

# run home-manager switch
hm:
  home-manager switch --flake . -b backup

news:
  home-manager news --flake .

# rebuild nix darwin
[macos]
build:
  sudo nix --experimental-features 'nix-command flakes' run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake ./#megabookpro
  # eventually: nh darwin switch ./

init:
  #!/usr/bin/env bash
  set -Eueo pipefail

  DOTFILES_DIR="$HOME/.dotfiles-nix"
  SUDO_USER=$(whoami)
  FLAKE=$(hostname -s)

  if ! command -v xcode-select >/dev/null; then
    echo "installing xcode.."
    xcode-select --install
    sudo -u "$SUDO_USER" softwareupdate --install-rosetta --agree-to-license
    # sudo -u "$SUDO_USER" xcodebuild -license
  fi

  if [ -z "$DOTFILES_DIR" ]; then
    echo "cloning dotfiles to $DOTFILES_DIR.." && \
      git clone https://github.com/megalithic/dotfiles-nix "$DOTFILES_DIR"
  fi

  if ! command -v brew >/dev/null; then
    echo "installing homebrew.." && \
      bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "running nix-darwin for the first time.." && \
    sudo nix --experimental-features 'nix-command flakes' run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake "$DOTFILES_DIR#$FLAKE"

  echo "running home-manager for the first time.." && \
    sudo nix --experimental-features 'nix-command flakes' run home-manager/master -- switch --flake "$DOTFILES_DIR#$FLAKE"

# rebuild nix darwin
[macos]
rebuild:
  sudo darwin-rebuild switch --flake ./

# update and upgrade homebrew packages
[macos]
update-brew:
  brew update && brew upgrade

# fix shell files. this happens sometimes with nix-darwin
[macos]
fix-shell-files:
  #!/usr/bin/env bash
  set -euxo pipefail

  sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin
  sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
  sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin

# updates brew, flake, and runs home-manager
[macos]
update: update-brew update-flake hm
