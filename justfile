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
  # home-manager switch --flake . -b backup
  nh darwin switch ./ -b backup

news:
  home-manager news --flake .

# rebuild nix darwin
[macos]
build:
  sudo nix --experimental-features 'nix-command flakes' run nix-darwin/nix-darwin-25.05 -- switch --option eval-cache false --flake ./#megabookpro --refresh
  # eventually: nh darwin switch ./

init:
  #!/usr/bin/env bash
  set -Eueo pipefail

  DOTFILES_DIR="$HOME/.dotfiles-nix"
  SUDO_USER=$(whoami)
  FLAKE=$(hostname -s)

  if ! command -v xcode-select >/dev/null; then
    echo ":: Installing xcode.."
    xcode-select --install
    sudo -u "$SUDO_USER" softwareupdate --install-rosetta --agree-to-license
    # sudo -u "$SUDO_USER" xcodebuild -license
  fi

  if [ -z "$DOTFILES_DIR" ]; then
    echo ":: Cloning bare dotfiles-nix repo to $DOTFILES_DIR.." && \
    echo "NOTE: we maintain our repo in $HOME/code/dotfiles-nix.." && \
      git clone --bare https://github.com/megalithic/dotfiles-nix "$DOTFILES_DIR"
  fi

  if ! command -v brew >/dev/null; then
    echo ":: Installing homebrew.." && \
      bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo ":: Running nix-darwin for the first time.." && \
    sudo nix --experimental-features 'nix-command flakes' run nix-darwin/nix-darwin-25.05 -- switch --option eval-cache false --flake "$DOTFILES_DIR#$FLAKE" --refresh

  # echo ":: Running home-manager for the first time.." && \
  #   sudo nix --experimental-features 'nix-command flakes' run home-manager/master -- switch --option eval-cache false --flake "$DOTFILES_DIR#$FLAKE" --refresh

# rebuild nix darwin
[macos]
rebuild:
  # darwin-rebuild switch --flake ./
  nh darwin switch ./


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
update:
  update-brew update-flake hm

# REF: https://docs.determinate.systems/troubleshooting/installation-failed-macos#run-the-uninstaller
[macos]
uninstall:
  sudo /nix/nix-installer uninstall
