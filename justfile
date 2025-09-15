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
  sudo nix --experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ./#megabookpro
  # eventually: nh darwin switch ./

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
