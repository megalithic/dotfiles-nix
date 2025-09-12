# REF: Some useful resources
#
# https://nix.dev/
# https://nixos.org/guides/nix-pills/
# https://nix-community.github.io/awesome-nix/
# https://serokell.io/blog/practical-nix-flakes
# https://zero-to-nix.com/
# https://wiki.nixos.org/wiki/Flakes
# https://rconybea.github.io/web/nix/nix-for-your-own-project.html

{
  description = "megadotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Master nixpkgs is used for really bleeding edge packages. Warning
    # that this is extremely unstable and shouldn't be relied on. Its
    # mostly for testing.
    nixpkgs-master.url = "github:nixos/nixpkgs";
    nixpkgs-update.url = "github:ryantm/nixpkgs-update";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-plist-manager.url = "github:sushydev/nix-plist-manager";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # weechat-scripts = {
    #   url = "github:weechat/scripts";
    #   flake = false;
    # };

    # yazi = {
    #   url = "github:sxyazi/yazi";
    # };
    #
    # yazi-plugins = {
    #   url = "github:yazi-rs/plugins";
    #   flake = false;
    # };
    #
    # yazi-glow = {
    #   url = "github:Reledia/glow.yazi";
    #   flake = false;
    # };

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # gh-gfm-preview = {
    #   url = "github:thiagokokada/gh-gfm-preview";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    emmylua-analyzer-rust = {
      url = "github:EmmyLuaLs/emmylua-analyzer-rust";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jujutsu.url = "github:martinvonz/jj";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix = {
    #   url = "github:Mic92/sops-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };


  outputs =
    { self, nixpkgs, home-manager, nix-darwin, nixpkgs-update, ... }@inputs:
    let
      overlays = [
        inputs.jujutsu.overlays.default

        # This overlay makes unstable packages available through pkgs.unstable
        (final: prev: rec {
          unstable = import inputs.nixpkgs-unstable {
            inherit (prev) system;
            config.allowUnfree = true;
          };

          # gh CLI on stable has bugs.
          inherit (unstable.legacyPackages.${prev.system}) gh;

          # Want the latest version of these
          inherit (unstable.legacyPackages.${prev.system}) claude-code;
        })
      ];

      mkSystem = import ./lib/mksystem.nix {
        inherit nixpkgs overlays inputs;
      };

      mkInit =
        { system
        , script ? ''
                    echo "hi from echo"
                    cowsay "hi from cowsay"
                    pkgs.cowsay "hi from pkgs.cowsay"
                    bash -c "$(echo "echo from bash -c echo")"
                    bash -c "$(cowsay "cowsay from bash -c cowsay")"

            # git clone https://github.com/mhanberg/.dotfiles ~/.dotfiles
            # nix run home-manager/master -- switch --flake ~/.dotfiles
          ''
        ,
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          init = pkgs.writeShellApplication {
            name = "init";
            text = script;
          };
        in
        {
          type = "app";
          program = "${init}/bin/init";
        };
    in
    {
      apps."aarch64-darwin".default = mkInit {
        system = "aarch64-darwin";
        script = ''
                    echo "hi from echo"
                    cowsay "hi from cowsay"
                    pkgs.cowsay "hi from pkgs.cowsay"
                    bash -c "$(echo "echo from bash -c echo")"
                    bash -c "$(cowsay "cowsay from bash -c cowsay")"


          # git clone https://github.com/mhanberg/.dotfiles ~/.dotfiles
          # bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          # nix run nix-darwin -- switch --flake ~/.dotfiles
          # nix run home-manager/master -- switch --flake ~/.dotfiles
        '';
      };
      # apps."x86_64-linux".default = mkInit { system = "x86_64-linux"; };
      # apps."aarch64-linux".default = mkInit { system = "aarch64-linux"; };

      darwinConfigurations.megabookpro = mkSystem "megabookpro" {
        arch = "aarch64-darwin";
        username = "seth";
        darwin = true;
        version = "25.05";
      };
    };
}
